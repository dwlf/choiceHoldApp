//
//  CHBook2+CoreDataProperties.swift
//  ChoiceHold
//
//  Created by Lloyd Dewolf on 6/9/23.
//
//

import Foundation
import CoreData


extension CHBook2 {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CHBook2> {
        return NSFetchRequest<CHBook2>(entityName: "CHBook2")
    }

    @NSManaged public var author: String?
    @NSManaged public var id: UUID?
    @NSManaged public var isbn: String?
    @NSManaged public var language: String?
    @NSManaged public var pubYearStr: String?
    @NSManaged public var title: String?
    @NSManaged public var reviews: NSSet?

}

// MARK: Generated accessors for reviews
extension CHBook2 {

    @objc(addReviewsObject:)
    @NSManaged public func addToReviews(_ value: CHReview)

    @objc(removeReviewsObject:)
    @NSManaged public func removeFromReviews(_ value: CHReview)

    @objc(addReviews:)
    @NSManaged public func addToReviews(_ values: NSSet)

    @objc(removeReviews:)
    @NSManaged public func removeFromReviews(_ values: NSSet)

}

extension CHBook2 : Identifiable {

}
