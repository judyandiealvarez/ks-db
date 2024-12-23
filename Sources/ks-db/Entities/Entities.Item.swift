//
//  Entities.Item.swift
//  ks-db
//
//  Created by Shadowchamber on 23/12/24.
//

import Appl
import Foundation
import GRDB

extension Appl.Dependencies.DB.Entities {
    
    struct Item: TableRecord, Codable {
        static let itemBarcodes = hasMany(ItemBarcode.self)
        static let itemCategories = hasMany(ItemCategory.self)
        static let itemImages = hasMany(ItemImage.self)
        
        var id: UUID
        var name: String
        var code: Int32
        var container: UUID
        var descriptionText: String
        var timeStamp: Date
        var toBeDeleted: Bool
        var uploaded: Bool
    }
}
