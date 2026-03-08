//
//  PreferencesView.swift
//  DeeplinkBuddy
//
//  Created by Dinh Quang Hieu on 28/09/2022.
//

#if os(macOS)
import SwiftUI

struct PreferencesView: View {
  @State private var showRelaunch = false
  @State private var iCloudSyncEnabledFirstValue: Bool = true
  @State private var feedback = ""
  @AppStorage("iCloudSyncEnabled") var iCloudSyncEnabled = true

  var body: some View {
    TabView {
      VStack {
        Toggle(isOn: $iCloudSyncEnabled) {
          VStack(alignment: .leading) {
            Text("iCloud sync")
            Text("A relaunch is required when you change this option")
              .foregroundColor(.secondary)
            if showRelaunch {
              Button {
                showRelaunch = false
                Process.launchedProcess(launchPath: "/usr/bin/open", arguments: ["-n", Bundle.main.bundlePath])
                NSApplication.shared.terminate(self)
              } label: {
                Text("Relaunch")
              }
            }
          }
        }
        .onChange(of: iCloudSyncEnabled) { newValue in
          if iCloudSyncEnabledFirstValue != newValue {
            showRelaunch = true
          } else {
            showRelaunch = false
          }
        }
      }
      .tabItem {
        Label("iCloud", systemImage: "icloud")
      }

      #if STORE
      VStack {
        HStack {
          Text("Xcode path")
          TextField("", text: .constant(XcodeManager.shared.xcodeURL?.path ?? ""))

          Button {
            XcodeManager.shared.askForXcode(completion: {})
          } label: {
            if XcodeManager.shared.xcodePath.isEmpty {
              Text("Select")
            } else {
              Text("Change")
            }
          }
        }
        Text("Deeplink Buddy needs access permission to your Xcode location to be able to get the list of simulators and run deeplink on the simulator")
          .foregroundColor(.secondary)
          .multilineTextAlignment(.leading)
          .frame(minHeight: 60)
      }
      .tabItem {
        Label("Xcode", systemImage: "hammer")
      }
      #endif

      VStack {
        TextEditor(text: $feedback)
          .font(.body)
          .overlay(
            RoundedRectangle(cornerRadius: 6)
              .stroke(Color.gray.opacity(0.5), lineWidth: 0.5)
          )
          .frame(height: 100)
          .frame(maxWidth: .infinity)
          .background(Color(NSColor.textBackgroundColor))
          .cornerRadius(6)
        HStack {
          Button {
            feedback = ""
          } label: {
            Text("Clear")
          }

          Spacer()
          Button {
            if let fb = feedback.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed),
               let url = URL(string: "https://twitter.com/messages/compose?recipient_id=2808665022&text=\(fb)") {
              NSWorkspace.shared.open(url)
            }
          } label: {
            Text("Send via Twitter")
          }
          Button {
            if let service = NSSharingService(named: NSSharingService.Name.composeEmail) {
              service.recipients = ["support@deeplinkbuddy.com"]
              service.subject = "Deeplink Buddy Feedback"
              service.perform(withItems: [feedback])
            }
          } label: {
            Text("Send via email")
          }
        }
      }
      .tabItem {
        Label("Feedback", systemImage: "envelope")
      }
      VStack(spacing: 12) {
        if let image = NSImage(named: "AppIcon") {
          Image(nsImage: image)
            .resizable()
            .scaledToFit()
            .frame(width: 64, height: 64)
        }
        Text("Deeplink Buddy")
          .font(.title2)
          .bold()
        Text("Version \(appVersion)")
          .font(.callout)
        Text("© 2023 Dinh Quang Hieu")
          .font(.callout)
      }
      .padding(.bottom)
      .tabItem {
        Label("About", systemImage: "info.circle")
      }
      #if DEBUG
      VStack {
        Button {
          if let bundleID = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
          }
          NSApplication.shared.terminate(self)
        } label: {
          Text("Reset settings")
        }

      }
      .tabItem {
        Label("DEBUG", systemImage: "hammer")
      }
      #endif
    }
    .padding()
    .frame(width: 400)
    .onAppear {
      iCloudSyncEnabledFirstValue = iCloudSyncEnabled
    }
  }

  var appVersion: String {
    let source: String = {
      #if STORE
      return "A"
      #else
      return "D"
      #endif
    }()
    var result = ""
    if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
      result = appVersion
    }
    if let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
      result += " (\(buildNumber + source))"
    }

    return result
  }
}
#endif
