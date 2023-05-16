//
//  TargetDeviceView.swift
//  DeeplinkBuddy
//
//  Created by Dinh Quang Hieu on 04/10/2022.
//

import SwiftUI

#if os(macOS)
enum TargetDevice: RawRepresentable {

  typealias RawValue = String

  case mac
  case simulator(udid: String?)

  init?(rawValue: String) {
    switch rawValue {
    case "mac":
      self = .mac
    case "booted":
      self = .simulator(udid: nil)
    default:
      self = .simulator(udid: rawValue)
    }
  }

  var rawValue: String {
    switch self {
    case .mac: return "mac"
    case .simulator(let udid): return udid ?? "booted"
    }
  }

  var simulatorUdid: String? {
    switch self {
    case .mac: return nil
    case .simulator(let udid): return udid
    }
  }

  var isSimulator: Bool {
    switch self {
    case .mac: return false
    case .simulator: return true
    }
  }
}

struct TargetDeviceView: View {

  @ObservedObject var simulatorManager = SimulatorManager.shared

  @AppStorage("targetDevice") var targetDevice: TargetDevice = .simulator(udid: nil)

  var body: some View {
    Menu {
      if simulatorManager.simulators.isEmpty {
        Button {
          targetDevice = .simulator(udid: nil)
        } label: {
          HStack {
            Image(systemName: "iphone")
            Text("Simulator")
          }
        }
      } else {
        ForEach(simulatorManager.simulators, id: \.self) { simulator in
          Button {
            targetDevice = .simulator(udid: simulator.udid)
          } label: {
            HStack {
              Image(systemName: "iphone")
              Text(simulator.name)
            }
          }
        }
      }
      Button {
        targetDevice = .mac
      } label: {
        HStack {
          Image(systemName: "laptopcomputer")
          Text("My Mac")
        }
      }
      Divider()
      Button {
        simulatorManager.refresh()
      } label: {
        Text("Refresh")
      }
    } label: {
      if targetDevice.isSimulator {
        HStack {
          Image(systemName: "iphone")
          Text(simulatorManager.findTargetSimulatorName(targetDevice.simulatorUdid))
        }
      } else {
        HStack {
          Image(systemName: "laptopcomputer")
          Text("My Mac")
        }
      }
    }
    .onAppear {

    }
  }
}
#endif
