//
//  CHBook+CoreDataProperties.swift
//  ChoiceHold
//
//  Created by Lloyd Dewolf on 6/2/23.
//
//

import Foundation
import CoreData


extension CHBook {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CHBook> {
        return NSFetchRequest<CHBook>(entityName: "CHBook")
    }

    @NSManaged public var rating: Int16
    @NSManaged public var title: String?

}

extension CHBook : Identifiable {

}
