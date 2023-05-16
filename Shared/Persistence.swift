//
//  Persistence.swift
//  DeeplinkBuddy
//
//  Created by Dinh Quang Hieu on 14/09/2022.
//

import CoreData
import SwiftUI

struct PersistenceController {

  @AppStorage("iCloudSyncEnabled") var iCloudSyncEnabled = true

  static let shared = PersistenceController()
  
  let container: NSPersistentCloudKitContainer
  
  init() {
    container = NSPersistentCloudKitContainer(name: "DeeplinkBuddy")
    if iCloudSyncEnabled {
      #warning("Change containerIdentifier")
      let option = NSPersistentCloudKitContainerOptions(containerIdentifier: "iCloud.com.hieudinh.DeeplinkBuddy")
      container.persistentStoreDescriptions.first?.cloudKitContainerOptions = option
      container.viewContext.automaticallyMergesChangesFromParent = true
    } else {
      container.persistentStoreDescriptions.first?.cloudKitContainerOptions = nil
      container.viewContext.automaticallyMergesChangesFromParent = false
      container.persistentStoreDescriptions.first?.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
    }

    container.loadPersistentStores(completionHandler: { (storeDescription, error) in

    })
  }

  func getDeeplinks() -> [Deeplink] {
    let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Deeplink")
    return (try? container.viewContext.fetch(request) as? [Deeplink]) ?? []
  }
}
