//
//  Entities.Category.swift
//  ks-db
//
//  Created by Shadowchamber on 23/12/24.
//

import Appl
import Foundation
import GRDB

extension Appl.Dependencies.KSDB.Entities {
    public struct Category: TableRecord, Codable {
        var recId: Int64 = 0
        var id: UUID = UUID()
        var createdOn: Date = Date()
        var updatedOn: Date = Date()
        var createdBy: String = "me"
        var updatedBy: String = "me"
        var toBeDeleted: Bool = false
        var uploaded: Bool = false

        var name: String

        var imageRefRecId: Int64
        var parentRefRecId: Int64?

        static let image = hasOne(Image.self)
        static let parent = belongsTo(Category.self)
        static let items = hasMany(Item.self)
        static let subCategories = hasMany(Category.self)
    }
}
