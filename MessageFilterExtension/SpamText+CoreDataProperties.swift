//
//  SpamText+CoreDataProperties.swift
//  SMSFilter
//
//  Created by Rafeeq Ebrahim on 03/01/19.
//  Copyright © 2019 Rafeeq Ebrahim. All rights reserved.
//
//

import Foundation
import CoreData


extension SpamText {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SpamText> {
        return NSFetchRequest<SpamText>(entityName: "SpamText")
    }

    @NSManaged public var text: String?

}
