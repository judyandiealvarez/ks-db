import Foundation
import Appl
import GRDB
import Dependencies

extension Appl.Dependencies {
    public struct DB : Sendable {
        func start() throws {
            let dbQueue = try DatabaseQueue()

            try dbQueue.write { db in
                try db.create(table: "barcode", ifNotExists: true) { t in
                    t.autoIncrementedPrimaryKey("recId")
                    t.column("id", .text)
                    t.column("createdOn", .datetime).notNull()
                    t.column("updatedOn", .datetime).notNull()
                    t.column("createdBy", .text).notNull()
                    t.column("updatedBy", .text).notNull()
                    t.column("toBeDeleted", .boolean).notNull()
                    t.column("uploaded", .boolean).notNull()
                    
                    t.column("code", .integer).notNull()
                }
                
                try db.create(table: "item", ifNotExists: true) { t in
                    t.autoIncrementedPrimaryKey("recId")
                    t.column("id", .text)
                    t.column("name", .text).notNull()
                    t.column("code", .integer).notNull()
                    t.column("container", .blob).notNull()
                    t.column("descriptionText", .text).notNull()
                    t.column("timeStamp", .datetime).notNull()
                    t.column("toBeDeleted", .boolean).notNull()
                    t.column("uploaded", .boolean).notNull()
                }
                
                try db.create(table: "image", ifNotExists: true) { t in
                    t.autoIncrementedPrimaryKey("recId")
                    t.column("id", .text)
                    t.column("toBeDeleted", .boolean).notNull()
                    t.column("uploaded", .boolean).notNull()
                }
                
                try db.create(table: "category", ifNotExists: true) { t in
                    t.autoIncrementedPrimaryKey("recId")
                    t.column("id", .text)
                    t.column("name", .text).notNull()
                    t.column("imageId", .text).notNull()
                        .references("imageId", onDelete: .cascade)
                    t.column("parentId", .text)
                        .references("category", onDelete: .cascade)
                    t.column("toBeDeleted", .boolean).notNull()
                    t.column("uploaded", .boolean).notNull()
                }
                
                try db.create(table: "itemBarcode", ifNotExists: true) { t in
                    t.autoIncrementedPrimaryKey("recId")
                    t.column("id", .text)
                    t.column("itemId", .text).notNull()
                        .references("item", onDelete: .cascade)
                    t.column("barcodeId", .text).notNull()
                        .references("barcode", onDelete: .cascade)
                    t.column("toBeDeleted", .boolean).notNull()
                    t.column("uploaded", .boolean).notNull()
                }
                
                try db.create(table: "itemCategory", ifNotExists: true) { t in
                    t.autoIncrementedPrimaryKey("recId")
                    t.column("id", .text)
                    t.column("itemId", .text).notNull()
                        .references("item", onDelete: .cascade)
                    t.column("categoryId", .text).notNull()
                        .references("category", onDelete: .cascade)
                    t.column("toBeDeleted", .boolean).notNull()
                    t.column("uploaded", .boolean).notNull()
                }
                
                try db.create(table: "itemImage", ifNotExists: true) { t in
                    t.autoIncrementedPrimaryKey("recId")
                    t.column("id", .text)
                    t.column("itemId", .text).notNull()
                        .references("item", onDelete: .cascade)
                    t.column("imageId", .text).notNull()
                        .references("image", onDelete: .cascade)
                    t.column("toBeDeleted", .boolean).notNull()
                    t.column("uploaded", .boolean).notNull()
                }
                
                /*try db.create(table: "books", ifNotExists: true) { t in
                    t.autoIncrementedPrimaryKey("id")
                    t.column("title", .text).notNull()
                    t.column("authorID", .integer)
                        .notNull()
                        .references("authors", onDelete: .cascade) // Create a foreign key reference
                }*/
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
