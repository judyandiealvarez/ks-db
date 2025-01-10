//
//  Entities.Barcode.swift
//  ks-db
//
//  Created by Shadowchamber on 23/12/24.
//

import Appl
import Foundation
import GRDB

extension Appl.Dependencies.KSDB.Entities {
    public struct Barcode: TableRecord, Codable, MutablePersistableRecord, FetchableRecord, PersistableRecord {
        var recId: Int64 = 0
        var id: UUID = UUID()
        var createdOn: Date = Date()
        var updatedOn: Date = Date()
        var createdBy: String = "me"
        var updatedBy: String = "me"
        var toBeDeleted: Bool = false
        var uploaded: Bool = false

        public var code: String

        static let itemBarcode = hasOne(ItemBarcode.self)

        public init(_ code: String) {
            self.code = code
        }

        /*public mutating func didInsert(_ inserted: InsertionSuccess) {
            recId = inserted.rowID
        }*/
    }
}
