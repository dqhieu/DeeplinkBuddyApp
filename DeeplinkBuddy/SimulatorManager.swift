//
//  SimulatorManager.swift
//  DeeplinkBuddy
//
//  Created by Dinh Quang Hieu on 04/10/2022.
//

import Foundation

#if os(macOS)
import AppKit
import SwiftUI

struct SimulatorResponse: Codable {
  let devices: [String: [Simulator]]
}

struct Simulator: Codable, Hashable {
  let udid: String
  let name: String
  let state: String
}

class SimulatorManager: ObservableObject {

  static var shared = SimulatorManager()

  @Published var simulators: [Simulator] = []

  init() {}

  #if STORE
  func refresh() {
    DispatchQueue.global(qos: .background).async { [weak self] in
      guard let path = XcodeManager.shared.getXcodePath() else { return }
      let task = Process()
      task.launchPath = path
      task.arguments = ["list", "devices", "-j", "-e"] // xcrun simctl list devices -j -e
      let pipe = Pipe()
      task.standardOutput = pipe
      _ = XcodeManager.shared.xcodeURL?.startAccessingSecurityScopedResource()
      do {
        Tracker.startLoadingSimulator()
        try task.run()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        task.waitUntilExit()
        let response = try JSONDecoder().decode(SimulatorResponse.self, from: data)
        DispatchQueue.main.async { [weak self] in
          self?.simulators = response.devices.values.flatMap { $0 }.filter { $0.state == "Booted" }
          Tracker.finishLoadingSimulator(count: response.devices.count, booted: self?.simulators.count ?? 0)
          XcodeManager.shared.xcodeURL?.stopAccessingSecurityScopedResource()
        }
      } catch {
        XcodeManager.shared.xcodeURL?.stopAccessingSecurityScopedResource()
      }
    }
  }
  #else
  func refresh() {
    Tracker.startLoadingSimulator()
    DispatchQueue.global(qos: .background).async { [weak self] in
      let task = Process()
      task.launchPath = "/usr/bin/env"
      task.arguments = ["xcrun", "simctl", "list", "devices", "-j", "-e"] // xcrun simctl list devices -j -e
      let pipe = Pipe()
      task.standardOutput = pipe
      do {
        try task.run()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        task.waitUntilExit()
        let response = try JSONDecoder().decode(SimulatorResponse.self, from: data)
        DispatchQueue.main.async { [weak self] in
          self?.simulators = response.devices.values.flatMap { $0 }.filter { $0.state == "Booted" }
          Tracker.finishLoadingSimulator(count: response.devices.count, booted: self?.simulators.count ?? 0)
        }
      } catch {
      }
    }
  }
  #endif

  func findTargetSimulator(_ simulatorUdid: String?) -> Simulator? {
    if simulators.isEmpty {
      return nil
    }
    if simulators.count == 1 {
      return simulators[0]
    }
    return simulators.first(where: { $0.udid == simulatorUdid }) ?? simulators.first
  }

  func findTargetSimulatorName(_ simulatorUdid: String?) -> String {
    return findTargetSimulator(simulatorUdid)?.name ?? "Simulator"
  }

  #if STORE
  func runDeeplink(_ deeplink: String, simulatorUDID: String) -> String {
    guard let path = XcodeManager.shared.getXcodePath() else { return "" }
    let task = Process()
    task.launchPath = path
    task.arguments = ["openurl", simulatorUDID, deeplink]
    let pipe = Pipe()
    task.standardError = pipe
    task.standardOutput = pipe

    _ = XcodeManager.shared.xcodeURL?.startAccessingSecurityScopedResource()
    do {
      try task.run()
      let data = pipe.fileHandleForReading.readDataToEndOfFile()
      task.waitUntilExit()
      XcodeManager.shared.xcodeURL?.stopAccessingSecurityScopedResource()
      return String(decoding: data, as: UTF8.self)
    } catch {
      XcodeManager.shared.xcodeURL?.stopAccessingSecurityScopedResource()
      return error.localizedDescription
    }
  }
  #else
  func runDeeplink(_ deeplink: String, simulatorUDID: String) -> String {
    let task = Process()
    task.launchPath = "/usr/bin/env"
    task.arguments = ["xcrun", "simctl", "openurl", simulatorUDID, deeplink]
    let pipe = Pipe()
    task.standardError = pipe
    task.standardOutput = pipe
    do {
      try task.run()
      task.waitUntilExit()
      let data = pipe.fileHandleForReading.readDataToEndOfFile()
      return String(decoding: data, as: UTF8.self)
    } catch {
      return error.localizedDescription
    }
  }
  #endif
}

#endif
