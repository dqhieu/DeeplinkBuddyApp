//
//  DeeplinkBuddyApp.swift
//  DeeplinkBuddy
//
//  Created by Dinh Quang Hieu on 14/09/2022.
//

import SwiftUI
#if os(macOS)
import AppKit
#endif
#if os(iOS)
import RevenueCat
#endif
@main
struct DeeplinkBuddyApp: App {

  let persistenceController = PersistenceController.shared
  #if os(macOS)
  #if STORE
  @AppStorage("didSelectXcode") var didSelectXcode = false
  #endif
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
    }
    #if os(macOS)
    Settings {
      PreferencesView()
    }
    #endif
  }

}
