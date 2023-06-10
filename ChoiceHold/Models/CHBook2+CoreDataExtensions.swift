//
//  CHBook2+CoreDataExtensions.swift
//  ChoiceHold
//
//  Created by Lloyd Dewolf on 6/9/23.
//

import Foundation
import CoreData

// MARK: Generated accessors for reviews
extension CHBook2 {

    static func isDuplicateISBNExists(_ isbn: String, in collection: [CHBook2]) -> Bool {
        return collection.contains { $0.isbn == isbn }
    }

}
