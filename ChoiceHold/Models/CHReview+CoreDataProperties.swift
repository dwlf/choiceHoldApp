//
//  CHReview+CoreDataProperties.swift
//  ChoiceHold
//
//  Created by Lloyd Dewolf on 6/9/23.
//
//

import Foundation
import CoreData


extension CHReview {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CHReview> {
        return NSFetchRequest<CHReview>(entityName: "CHReview")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var notes: String?
    @NSManaged public var rating: Int16
    @NSManaged public var topic: String?
    @NSManaged public var book: CHBook2?

}

extension CHReview : Identifiable {

}
