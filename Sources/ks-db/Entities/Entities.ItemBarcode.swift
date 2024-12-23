//
//  Entities.ItemBarcode.swift
//  ks-db
//
//  Created by Shadowchamber on 23/12/24.
//

import Appl
import Foundation
import GRDB

extension Appl.Dependencies.DB.Entities {
    
    struct ItemBarcode: TableRecord, Codable {
        static let item = belongsTo(Item.self)
        static let barcode = belongsTo(Barcode.self)
        
        var id: UUID
        var itemId: UUID
        var barcodeId: UUID
        var toBeDeleted: Bool
        var uploaded: Bool
    }
}
