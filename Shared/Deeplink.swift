//
//  Deeplink.swift
//  DeeplinkBuddy
//
//  Created by Dinh Quang Hieu on 14/09/2022.
//

import CoreData

@objc(Deeplink)
public class Deeplink: NSManagedObject {

  @nonobjc
  public class func fetchRequest() -> NSFetchRequest<Deeplink> {
    return NSFetchRequest<Deeplink>(entityName: "Deeplink")
  }

  @NSManaged public var name: String
  @NSManaged public var value: String
  @NSManaged public var createdDate: Date
}

extension Deeplink: Identifiable {}
