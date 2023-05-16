//
//  iOSContentView.swift
//  DeeplinkBuddy
//
//  Created by Dinh Quang Hieu on 26/10/2022.
//

import SwiftUI

struct iOSContentView: View {

  var body: some View {
    TabView {
      AllDeeplinksView()
        .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
        .tabItem {
          Label("All deeplinks", systemImage: "link")
        }
      iOSSettingsView()
        .tabItem {
          Label("Settings", systemImage: "gear")
        }
    }
  }
}

struct iOSContentView_Previews: PreviewProvider {
  static var previews: some View {
    iOSContentView()
  }
}
