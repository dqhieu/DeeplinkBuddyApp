//
//  iOSSettingsView.swift
//  DeeplinkBuddy
//
//  Created by Dinh Quang Hieu on 26/10/2022.
//

import SwiftUI
import SafariServices

struct iOSSettingsView: View {

  @AppStorage("iCloudSyncEnabled") var iCloudSyncEnabled = true
  @State private var showChangeLog: Bool = false

  @ObservedObject var purchaseManager = PurchaseManager.shared
  @State private var showTipSuccessAlert = false
  @State private var showTipFailureAlert = false

  var body: some View {
    NavigationView {
      Form {
        Section {
          HStack {
            Text("iCloud sync")
            Spacer()
            Toggle("", isOn: $iCloudSyncEnabled)
          }
        } header: {
          Text("iCloud")
        } footer: {
          Text("A relaunch is required when you change this option")
        }

        if !purchaseManager.packages.isEmpty {
          Section {
            ForEach(purchaseManager.packages, id: \.self) { package in
              Button {
                purchaseManager.purchase(package: package) { success in
                  if success {
                    showTipSuccessAlert = true
                  } else {
                    showTipFailureAlert = true
                  }
                }
              } label: {
                HStack {
                  Text(package.title)
                  Spacer()
                  Text(package.localizedPriceString)
                    .foregroundColor(.primary)
                }
              }
            }
          } header: {
            Text("Tip Jar")
          }
          .alert("Thank you for your tip", isPresented: $showTipSuccessAlert) {
            Button("OK", role: .cancel) { }
          }
          .alert("Something went wrong", isPresented: $showTipFailureAlert) {
            Button("OK", role: .cancel) { }
          }
        }

        Section {
          if let url = URL(string: "https://deeplinkbuddy.com/") {
            Link("💻 Deeplink Buddy for macOS", destination: url)
          }
        }

        Section {
          if let url = URL(string: "https://deeplinkbuddy.com/changelog?tab=ios") {
            Button {
              showChangeLog = true
            } label: {
              Text("📘 Changelog")
            }
            .fullScreenCover(isPresented: $showChangeLog, content: {
              SFSafariViewWrapper(url: url)
                .edgesIgnoringSafeArea(.all)
            })
          }
          if let url = URL(string: "twitter://user?screen_name=dqhieu"), UIApplication.shared.canOpenURL(url) {
            Link("👨🏻‍💻 Developer Twitter", destination: url)
          } else if let url = URL(string: "https://twitter.com/dqhieu"), UIApplication.shared.canOpenURL(url) {
            Link("👨🏻‍💻 Developer Twitter", destination: url)
          }
          #warning("Change Support email")
          if let url = URL(string: "mailto:youremail") {
            Link("✉️ Send feedback", destination: url)
          }
          if let writeReviewURL = URL(string: "https://apps.apple.com/app/id6443472268?action=write-review") {
            Link("📝 Review on the App Store", destination: writeReviewURL)
          }
        } header: {
          Text("About")
        } footer: {
          footer
        }
      }
      .navigationTitle("Deeplink Buddy")
    }
    .task {
      if purchaseManager.packages.isEmpty {
        purchaseManager.fetchProducts()
      }
    }
  }

  var footer: some View {
    VStack {
      Text("v\(appVersion)")
      Spacer()
      Text("Made with ❤️ and ☕️ by Dinh Quang Hieu 🐈")
        .multilineTextAlignment(.center)
      Spacer()
      Text("If you enjoy using the app, please take a moment to rate and write a review. Thank you!")
        .multilineTextAlignment(.center)
    }
    .padding(.vertical)
  }

  var appVersion: String {
    var text = ""
    if let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String {
      text = "\(version)"
    }
    return text
  }
}

struct iOSSettingsView_Previews: PreviewProvider {
  static var previews: some View {
    iOSSettingsView()
  }
}

struct SFSafariViewWrapper: UIViewControllerRepresentable {
  let url: URL

  func makeUIViewController(context: UIViewControllerRepresentableContext<Self>) -> SFSafariViewController {
    return SFSafariViewController(url: url)
  }

  func updateUIViewController(_ uiViewController: SFSafariViewController, context: UIViewControllerRepresentableContext<SFSafariViewWrapper>) {
    return
  }
}
