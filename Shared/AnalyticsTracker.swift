//
//  AnalyticsTracker.swift
//  DeeplinkBuddy
//
//  Created by Dinh Quang Hieu on 26/12/2022.
//

import Foundation
import Mixpanel

class Tracker {
  static func runDeeplink(targetDevice: String) {
    Mixpanel.mainInstance().track(
      event: "Run Deeplink",
      properties: ["targetDevice": targetDevice]
    )
  }

  static func createDeeplink() {
    Mixpanel.mainInstance().track(
      event: "Create Deeplink",
      properties: [:]
    )
  }

  static func duplicateDeeplink() {
    Mixpanel.mainInstance().track(
      event: "Duplicate Deeplink",
      properties: [:]
    )
  }

  static func removeDeeplink() {
    Mixpanel.mainInstance().track(
      event: "Remove Deeplink",
      properties: [:]
    )
  }

  static func startLoadingSimulator() {
    Mixpanel.mainInstance().time(event: "Load Simulator")
  }

  static func finishLoadingSimulator(count: Int, booted: Int) {
    Mixpanel.mainInstance().track(
      event: "Load Simulator",
      properties: ["count": count, "booted": booted]
    )
  }

  static func showQRCode() {
    Mixpanel.mainInstance().track(
      event: "Show QR Code",
      properties: [:]
    )
  }

  static func addParam(count: Int) {
    Mixpanel.mainInstance().track(
      event: "Add Param",
      properties: ["count": count]
    )
  }

  static func removeParam(count: Int) {
    Mixpanel.mainInstance().track(
      event: "Remove Param",
      properties: ["count": count]
    )
  }

  static func enableParam(count: Int) {
    Mixpanel.mainInstance().track(
      event: "Enable Param",
      properties: ["count": count]
    )
  }

  static func disableParam(count: Int) {
    Mixpanel.mainInstance().track(
      event: "Disable Param",
      properties: ["count": count]
    )
  }

  static func removeAllParams(count: Int) {
    Mixpanel.mainInstance().track(
      event: "Remove All Params",
      properties: ["count": count]
    )
  }

  static func enableAllParams(count: Int) {
    Mixpanel.mainInstance().track(
      event: "Enable All Params",
      properties: ["count": count]
    )
  }

  static func disableAllParams(count: Int) {
    Mixpanel.mainInstance().track(
      event: "Disable All Params",
      properties: ["count": count]
    )
  }
}
