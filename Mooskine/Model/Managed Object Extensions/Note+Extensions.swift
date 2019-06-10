//
//  Note+Extensions.swift
//  Mooskine
//
//  Created by Ge on 6/9/19.
//  Copyright © 2019 Udacity. All rights reserved.
//

import Foundation
import CoreData

extension Note{
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        creationDate = Date()
    }
}
