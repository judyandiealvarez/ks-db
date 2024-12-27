//
//  Entities.ItemImage.swift
//  ks-db
//
//  Created by Shadowchamber on 23/12/24.
//

import Appl
import Foundation
import GRDB

extension Appl.Dependencies.KSDB.Entities {
    public struct ItemImage: TableRecord, Codable {
        var recId: Int64 = 0
        var id: UUID = UUID()
        var createdOn: Date = Date()
        var updatedOn: Date = Date()
        var createdBy: String = "me"
        var updatedBy: String = "me"
        var toBeDeleted: Bool = false
        var uploaded: Bool = false

        var itemRefRecId: Int64
        var imageRefRecId: Int64

        static let item = belongsTo(Item.self)
        static let image = belongsTo(Image.self)
    }
}
