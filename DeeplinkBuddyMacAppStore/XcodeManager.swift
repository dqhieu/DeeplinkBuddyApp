//
//  XcodeManager.swift
//  DeeplinkBuddyMacAppStore
//
//  Created by Dinh Quang Hieu on 21/01/2023.
//

import Foundation
import AppKit

class XcodeManager: ObservableObject {

  @Published var xcodePath = ""

  static var shared = XcodeManager()

  init() {
    xcodePath = xcodeURL?.path ?? ""
  }

  var xcodeURL: URL? {
    guard let data = UserDefaults.standard.data(forKey: "xcodePathBookmarkData") else { return nil }
    var isStale = false
    guard let xcodeURL = try? URL(
      resolvingBookmarkData: data,
      options: .withSecurityScope,
      relativeTo: nil,
      bookmarkDataIsStale: &isStale
    ) else { return nil }
    xcodePath = xcodeURL.path
    return xcodeURL
  }

  func askForXcode(completion: () -> Void) {
    let panel = NSOpenPanel()
    panel.canChooseDirectories = false
    panel.canChooseFiles = true
    let response = panel.runModal()
    if response == .OK, let url = panel.url {
      let xcodeURL = url
      let canAccess = xcodeURL.startAccessingSecurityScopedResource()
      if canAccess, let bookmarkData = try? xcodeURL.bookmarkData(options: .withSecurityScope) {
        UserDefaults.standard.set(bookmarkData, forKey: "xcodePathBookmarkData")
        completion()
      }
      xcodeURL.stopAccessingSecurityScopedResource()
    }
  }

  func getXcodePath() -> String? {
    guard var xcode = xcodeURL else { return nil }
    xcode.appendPathComponent("Contents/Developer/usr/bin/simctl", isDirectory: false)
    return xcode.path
  }
}
