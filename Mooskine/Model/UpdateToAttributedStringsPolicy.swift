//
//  UpdateToAttributedStringsPolicy.swift
//  Mooskine
//
//  Created by Ge on 6/10/19.
//  Copyright © 2019 Udacity. All rights reserved.
//

import Foundation
import CoreData

class updateToAttributedStringPolicy: NSEntityMigrationPolicy {
    override func createDestinationInstances(forSource sInstance: NSManagedObject, in mapping: NSEntityMapping, manager: NSMigrationManager) throws {
        // Call super
        try super.createDestinationInstances(forSource: sInstance, in: mapping, manager: manager)
        
         // Get the (updated) destination Note instance we're modifying
        guard let destination = manager.destinationInstances(forEntityMappingName: mapping.name, sourceInstances: [sInstance]).first else { return }
        
        if let text = sInstance.value(forKey: "text") as? String {
             destination.setValue(NSAttributedString(string: text), forKey: "attributedText")
        }
    }
    
    
}
