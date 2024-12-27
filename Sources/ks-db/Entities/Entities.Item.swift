//
//  Entities.Item.swift
//  ks-db
//
//  Created by Shadowchamber on 23/12/24.
//

import Appl
import Foundation
import GRDB

extension Appl.Dependencies.KSDB.Entities {
    public struct Item: TableRecord, Codable {
        var recId: Int64 = 0
        var id: UUID = UUID()
        var createdOn: Date = Date()
        var updatedOn: Date = Date()
        var createdBy: String = "me"
        var updatedBy: String = "me"
        var toBeDeleted: Bool = false
        var uploaded: Bool = false

        var name: String
        var code: String
        var descriptionText: String

        static let itemBarcodes = hasMany(ItemBarcode.self)
        static let itemCategories = hasMany(ItemCategory.self)
        static let itemImages = hasMany(ItemImage.self)
    }
}
