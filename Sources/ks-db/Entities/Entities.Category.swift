//
//  Entities.Category.swift
//  ks-db
//
//  Created by Shadowchamber on 23/12/24.
//

import Appl
import Foundation
import GRDB

extension Appl.Dependencies.DB.Entities {
    
    struct Category: TableRecord, Codable {
        static let items = hasMany(Item.self) 
        
        var recId: Int
        var id: UUID
        var code: Int32
        var container: UUID
        var descriptionText: String
        var timeStamp: Date
        var toBeDeleted: Bool
        var uploaded: Bool
    }
}

