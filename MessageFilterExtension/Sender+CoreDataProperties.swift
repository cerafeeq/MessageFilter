//
//  Sender+CoreDataProperties.swift
//  SMSFilter
//
//  Created by Rafeeq Ebrahim on 03/01/19.
//  Copyright © 2019 Rafeeq Ebrahim. All rights reserved.
//
//

import Foundation
import CoreData


extension Sender {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Sender> {
        return NSFetchRequest<Sender>(entityName: "Sender")
    }

    @NSManaged public var name: String?

}
