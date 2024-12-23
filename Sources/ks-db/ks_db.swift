import Foundation
import Appl
import GRDB
import Dependencies

extension Appl.Dependencies {
    public struct DB : Sendable {
        fileprivate func addAuditFields(_ t: TableDefinition) {
            t.column("createdOn", .datetime).notNull()
            t.column("updatedOn", .datetime).notNull()
            t.column("createdBy", .text).notNull()
            t.column("updatedBy", .text).notNull()
        }
        
        fileprivate func addUploadFields(_ t: TableDefinition) {
            t.column("toBeDeleted", .boolean).notNull()
            t.column("uploaded", .boolean).notNull()
        }
        
        fileprivate func addIdFields(_ t: TableDefinition) {
            t.autoIncrementedPrimaryKey("recId")
            t.column("id", .text)
        }
        
        fileprivate func addDefaultFields(_ t: TableDefinition) {
            addIdFields(t)
            addAuditFields(t)
            addUploadFields(t)
        }
        
        func start() throws {
            let dbQueue = try DatabaseQueue() // path: "/Users/shadowchamber/Projects/ks-db/ksdb.sqlite")

            try dbQueue.write { db in
                try db.create(table: "barcode", ifNotExists: true) { t in
                    addDefaultFields(t)
                    
                    t.column("code", .text).notNull()
                }
                
                try db.create(table: "item", ifNotExists: true) { t in
                    addDefaultFields(t)
                    
                    t.column("name", .text).notNull()
                    t.column("code", .integer).notNull()
                    t.column("descriptionText", .text).notNull()
                }
                
                try db.create(table: "image", ifNotExists: true) { t in
                    addDefaultFields(t)
                }
                
                try db.create(table: "category", ifNotExists: true) { t in
                    addDefaultFields(t)
                    
                    t.column("name", .text).notNull()
                    
                    t.column("imageId", .text).notNull()
                        .references("image", onDelete: .restrict)
                    t.column("parentId", .text)
                        .references("category", onDelete: .cascade)
                }
                
                try db.create(table: "itemBarcode", ifNotExists: true) { t in
                    addDefaultFields(t)
                    
                    t.column("itemId", .text).notNull()
                        .references("item", onDelete: .cascade)
                    t.column("barcodeId", .text).notNull()
                        .references("barcode", onDelete: .cascade)
                }
                
                try db.create(table: "itemCategory", ifNotExists: true) { t in
                    addDefaultFields(t)
                    
                    t.column("itemId", .text).notNull()
                        .references("item", onDelete: .cascade)
                    t.column("categoryId", .text).notNull()
                        .references("category", onDelete: .cascade)
                }
                
                try db.create(table: "itemImage", ifNotExists: true) { t in
                    addDefaultFields(t)
                    
                    t.column("itemId", .text).notNull()
                        .references("item", onDelete: .cascade)
                    t.column("imageId", .text).notNull()
                        .references("image", onDelete: .cascade)
                }
            }
        }
    }
}

extension DependencyValues {
    public var data: Appl.Dependencies.DB {
        get { self[Appl.Dependencies.DB.self] }
        set { self[Appl.Dependencies.DB.self] = newValue }
    }
}

extension Appl.Dependencies.DB: DependencyKey {
    public static let liveValue: Self = {
        return Self()
    }()
}

extension Appl.Dependencies.DB: TestDependencyKey {
    public static let previewValue = Self.noop
    public static let testValue = Self.noop
}

extension Appl.Dependencies.DB {
    public static let noop = Self()
}
