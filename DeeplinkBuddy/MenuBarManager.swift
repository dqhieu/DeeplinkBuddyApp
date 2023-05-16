//
//  MenuBarManager.swift
//  DeeplinkBuddy
//
//  Created by Dinh Quang Hieu on 07/10/2022.
//

#if os(macOS)
import Foundation
import AppKit
import SwiftUI

class MenuBarManager: NSObject, NSMenuDelegate {

  static let shared = MenuBarManager()

  var didSetup = false
  var deeplinks: [Deeplink] = []

  var statusItem: NSStatusItem!
  var menu: NSMenu!

  func setup() {
    if didSetup { return }
    didSetup = true
    statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    if let button = statusItem.button {
      button.image = NSImage(systemSymbolName: "link", accessibilityDescription: nil)

      menu = NSMenu()
      statusItem.menu = menu
      menu.delegate = self
    }

  }

  @objc func didSelectDeeplink(_ sender: NSMenuItem) {
    let task = Process()
    task.launchPath = "/usr/bin/env"
    task.arguments = ["xcrun", "simctl", "openurl", "booted", deeplinks[sender.tag].value]
    try? task.run()
    task.waitUntilExit()
  }

  @objc func didTapReopen() {
    let url = URL(fileURLWithPath: Bundle.main.resourcePath!)
    let path = url.deletingLastPathComponent().deletingLastPathComponent().absoluteString
    let task = Process()
    task.launchPath = "/usr/bin/open"
    task.arguments = [path]
    task.launch()
  }

  @objc func didTapPreferences() {
    if #available(macOS 13, *) {
      NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
    } else {
      NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
    }
  }

  @objc func didTapQuit() {
    NSApplication.shared.terminate(self)
  }

  func menuWillOpen(_ menu: NSMenu) {
    deeplinks = PersistenceController.shared.getDeeplinks()
    menu.removeAllItems()
    if deeplinks.isEmpty {
      menu.addItem(NSMenuItem(title: "No deeplinks", action: nil, keyEquivalent: ""))
    } else {
      for (index, deeplink) in deeplinks.enumerated() {
        let keyEquivalent = index < 9 ? String(index + 1) : index == 9 ? "0" : ""
        let item = NSMenuItem(title: deeplink.name, action: #selector(didSelectDeeplink), keyEquivalent: keyEquivalent)
        item.tag = index
        menu.addItem(item)
        item.target = self
      }
    }
    menu.addItem(NSMenuItem.separator())
    let mainWindowItem = NSMenuItem(title: "Reopen", action: #selector(didTapReopen), keyEquivalent: "")
    menu.addItem(mainWindowItem)
    let preferenceItem = NSMenuItem(title: "Preferences", action: #selector(didTapPreferences), keyEquivalent: ",")
    menu.addItem(preferenceItem)
    let quitItem = NSMenuItem(title: "Quit", action: #selector(didTapQuit), keyEquivalent: "")
    menu.addItem(quitItem)
    [mainWindowItem, preferenceItem, quitItem].forEach { $0.target = self }
  }

}
#endif
