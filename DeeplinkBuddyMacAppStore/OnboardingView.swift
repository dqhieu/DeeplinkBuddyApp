//
//  OnboardingView.swift
//  DeeplinkBuddyMacAppStore
//
//  Created by Dinh Quang Hieu on 21/01/2023.
//

import SwiftUI

struct OnboardingView: View {

  @AppStorage("didSelectXcode") var didSelectXcode = false

  var body: some View {
    ZStack {
      Circle()
        .fill(Color.blue)
        .frame(width: 100, height: 100)
        .blur(radius: 80)
      VStack(spacing: 20) {
        HStack {
          if let appImage = NSImage(named: "AppIcon"),
             let xcodeImage = NSImage(named: "Xcode_Icon") {
            Image(nsImage: appImage)
              .resizable()
              .scaledToFit()
              .frame(width: 64, height: 64)
            Text("❤️")
            Image(nsImage: xcodeImage)
              .resizable()
              .scaledToFit()
              .frame(width: 64, height: 64)
          }
        }
        Text("Deeplink Buddy needs access permission to your Xcode location in order to get the list of simulators and run deeplink on the simulator")
          .multilineTextAlignment(.center)
        Button {
          XcodeManager.shared.askForXcode {
            self.didSelectXcode = true
          }
        } label: {
          Text("Select Xcode")
        }
      }
      .padding()
    }
    .frame(width: 400, height: 220)
    .fixedSize()
  }
}

struct OnboardingView_Previews: PreviewProvider {
  static var previews: some View {
    OnboardingView()
  }
}
