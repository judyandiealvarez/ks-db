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
        var recId: Int64
        var id: UUID
        var createdOn: Date
        var updatedOn: Date
        var createdBy: String
        var updatedBy: String
        var toBeDeleted: Bool
        var uploaded: Bool

        static let items = hasMany(Item.self)

        var descriptionText: String
    }
}
