//
//  DeeplinkBuddyApp.swift
//  DeeplinkBuddy
//
//  Created by Dinh Quang Hieu on 14/09/2022.
//

import SwiftUI
#if os(macOS)
import AppKit
#if canImport(Sparkle)
import Sparkle
#endif
import Mixpanel
import TelemetryClient
let mixpanel = Mixpanel.mainInstance()
#endif
#if os(iOS)
import RevenueCat
#endif
@main
struct DeeplinkBuddyApp: App {

  let persistenceController = PersistenceController.shared
  #if os(macOS)
  #if !STORE
  private let updaterController: SPUStandardUpdaterController
  #endif
  #if STORE
  @AppStorage("didSelectXcode") var didSelectXcode = false
  #endif

  init() {
    // If you want to start the updater manually, pass false to startingUpdater and call .startUpdater() later
    // This is where you can also pass an updater delegate if you need one
    #if !STORE
    updaterController = SPUStandardUpdaterController(startingUpdater: true, updaterDelegate: nil, userDriverDelegate: nil)
    #endif
    #if DEBUG
    #warning("Change Mixpanel token")
    Mixpanel.initialize(token: "YOUR_MIXPANEL_TOKEN", useUniqueDistinctId: true)
    #else
    #warning("Change Mixpanel token")
    Mixpanel.initialize(token: "YOUR_MIXPANEL_TOKEN", useUniqueDistinctId: true)
    #endif
    #warning("Change Telemetry App ID")
    let configuration = TelemetryManagerConfiguration(appID: "YOUR_TELEMETRY_APP_ID")
    configuration.defaultUser = mixpanel.distinctId
    TelemetryManager.initialize(with: configuration)
  }
  #endif

  #if os(iOS)
  init() {
    #warning("Change RevenueCat API KEY")
    Purchases.configure(withAPIKey: "YOUR_REVENUE_CAT_API_KEY")
  }
  #endif

  var body: some Scene {
    WindowGroup {
      #if os(macOS)
      #if STORE
      if didSelectXcode {
        AllDeeplinksView()
          .onAppear {
            MenuBarManager.shared.setup()
          }
          .environment(\.managedObjectContext, persistenceController.container.viewContext)
      } else {
        OnboardingView()
      }
      #else
      AllDeeplinksView()
        .onAppear {
          MenuBarManager.shared.setup()
        }
        .environment(\.managedObjectContext, persistenceController.container.viewContext)
      #endif
      #endif
      #if os(iOS)
      iOSContentView()
      #endif
    }
    .commands {
      CommandGroup(replacing: .newItem, addition: { })
      CommandGroup(replacing: .appInfo) {
        Button("About Deeplink Buddy") {
          #if os(macOS)
          NSApplication.shared.orderFrontStandardAboutPanel(
            options: [
              NSApplication.AboutPanelOptionKey(rawValue: "Copyright"): "© 2023 Dinh Quang Hieu"
            ]
          )
          #endif
        }
      }
      CommandGroup(after: .appInfo) {
        #if !STORE
        CheckForUpdatesView(updater: updaterController.updater)
        #endif
      }
    }
    #if os(macOS)
    Settings {

      #if !STORE
      PreferencesView(updater: updaterController.updater)
      #else
      PreferencesView()
      #endif
    }
    #endif
  }

}
