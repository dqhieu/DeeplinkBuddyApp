//
//  PurchaseManager.swift
//  DeeplinkBuddyMobile
//
//  Created by Dinh Quang Hieu on 01/11/2022.
//

import Foundation
import RevenueCat
import SwiftUI

class PurchaseManager: ObservableObject {

  @Published var packages: [Package] = []

  static let shared = PurchaseManager()

  func fetchProducts() {
    Purchases.shared.getOfferings { [weak self] offerings, error in
      guard let offerings = offerings else {
        return
      }

      DispatchQueue.main.async {
        withAnimation(.spring()) {
          self?.packages = offerings.current?.availablePackages ?? []
        }
      }
    }
  }

  func purchase(package: Package, completion: @escaping (Bool) -> Void) {
    Purchases.shared.purchase(package: package) { _, customerInfo, error, _ in
      DispatchQueue.main.async {
        if customerInfo != nil, error == nil {
          completion(true)
        } else {
          completion(false)
        }
      }
    }
  }
}

extension Package {
  var title: String {
    switch storeProduct.productIdentifier {
    case "snack.tip":
      return "🍟 Snack-sized tip"
    case "coffee.tip":
      return "☕️ Coffee-sized tip"
    case "lunch.tip":
      return "🍔 Lunch-sized tip"
    default:
      return "💰 Tip"
    }
  }
}
