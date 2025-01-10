import Foundation
import Appl
import GRDB
import Dependencies

extension Appl.Dependencies {
    public typealias KSDBImage = Appl.Dependencies.KSDB.Entities.Image
    public typealias KSDBItemImage = Appl.Dependencies.KSDB.Entities.ItemImage
    public typealias KSDBCategory = Appl.Dependencies.KSDB.Entities.Category
    public typealias KSDBItem = Appl.Dependencies.KSDB.Entities.Item
    public typealias KSDBItemCategory = Appl.Dependencies.KSDB.Entities.ItemCategory
    public typealias KSDBBarcode = Appl.Dependencies.KSDB.Entities.Barcode

    public struct KSDB: Sendable {
        public let path: String
        public init(_ path: String = URL.documentsDirectory.appending(path: "ksdb.sqlite").path()) {
            self.path = path
        }

        fileprivate func addAuditFields(_ tableDefinition: TableDefinition) {
            tableDefinition.column("createdOn", .datetime).notNull().defaults(sql: "CURRENT_TIMESTAMP")
            tableDefinition.column("updatedOn", .datetime).notNull().defaults(sql: "CURRENT_TIMESTAMP")
            tableDefinition.column("createdBy", .text).notNull().defaults(sql: "me")
            tableDefinition.column("updatedBy", .text).notNull().defaults(sql: "me")
        }

        fileprivate func addUploadFields(_ tableDefinition: TableDefinition) {
            tableDefinition.column("toBeDeleted", .boolean).notNull().defaults(sql: "0")
            tableDefinition.column("uploaded", .boolean).notNull().defaults(to: "0")
        }

        fileprivate func generateUuidSql() -> String {
            return "(lower(hex(randomblob(4))) || '-' || lower(hex(randomblob(2))) " +
                   "|| '-4' || substr(lower(hex(randomblob(2))),2) || '-' || " +
                   "substr('89ab',abs(random()) % 4 + 1, 1) " +
                   "|| substr(lower(hex(randomblob(2))),2) || '-' || lower(hex(randomblob(6))))"
        }

        fileprivate func addIdFields(_ tableDefinition: TableDefinition) {
            tableDefinition.autoIncrementedPrimaryKey("recId")
            tableDefinition.column("id", .text).unique().defaults(sql: generateUuidSql())
        }

        fileprivate func addDefaultFields(_ tableDefinition: TableDefinition) {
            addIdFields(tableDefinition)
            addAuditFields(tableDefinition)
            addUploadFields(tableDefinition)
        }

        public func start() throws {

            let databaseQueue = try DatabaseQueue(
              path: path,
              configuration: Self.makeConfiguration()
            )

            try migrator.migrate(databaseQueue)

            try databaseQueue.write { ksdb in
                var insertedBarcode = try Appl.Dependencies.KSDB.Entities.Barcode("53674567").inserted(ksdb)

                insertedBarcode.code += "0"

              try insertedBarcode.update(ksdb)
            }
        }

        /// The DatabaseMigrator that defines the database schema.
        ///
        /// See <https://swiftpackageindex.com/groue/grdb.swift/documentation/grdb/migrations>
        var migrator: DatabaseMigrator {
            var migrator = DatabaseMigrator()

    #if DEBUG
            migrator.eraseDatabaseOnSchemaChange = true
    #endif

            migrator.registerMigration("v1") { kdb in
                try kdb.create(table: "barcode", ifNotExists: true) { tableDefinition in
                    addDefaultFields(tableDefinition)

                    tableDefinition.column("code", .text).notNull().unique()
                }

                try kdb.create(table: "item", ifNotExists: true) { tableDefinition in
                    addDefaultFields(tableDefinition)

                    tableDefinition.column("name", .text).notNull().unique()
                    tableDefinition.column("code", .integer).notNull().unique()
                    tableDefinition.column("descriptionText", .text).notNull()
                }

                try kdb.create(table: "image", ifNotExists: true) { tableDefinition in
                    addDefaultFields(tableDefinition)
                }

                try kdb.create(table: "category", ifNotExists: true) { tableDefinition in
                    addDefaultFields(tableDefinition)

                    tableDefinition.column("name", .text).notNull().unique()

                    tableDefinition.column("imageRefRecId", .text).notNull()
                        .references("image", onDelete: .restrict)
                    tableDefinition.column("parentRefRecId", .text)
                        .references("category", onDelete: .cascade)
                }

                // Relation tables

                try kdb.create(table: "itemBarcode", ifNotExists: true) { tableDefinition in
                    addDefaultFields(tableDefinition)

                    tableDefinition.column("itemRefRecId", .text).notNull()
                        .references("item", onDelete: .cascade)
                    tableDefinition.column("barcodeRefRecId", .text).notNull()
                        .references("barcode", onDelete: .cascade)
                }

                try kdb.create(table: "itemCategory", ifNotExists: true) { tableDefinition in
                    addDefaultFields(tableDefinition)

                    tableDefinition.column("itemRefRecId", .text).notNull()
                        .references("item", onDelete: .cascade)
                    tableDefinition.column("categoryRefRecId", .text).notNull()
                        .references("category", onDelete: .cascade)
                }

                try kdb.create(table: "itemImage", ifNotExists: true) { tableDefinition in
                    addDefaultFields(tableDefinition)

                    tableDefinition.column("itemRefRecId", .text).notNull()
                        .references("item", onDelete: .cascade)
                    tableDefinition.column("imageRefRecId", .text).notNull()
                        .references("image", onDelete: .cascade)
                }
            }

            // Migrations for future application versions will be inserted here:
            // migrator.registerMigration(...) { db in
            //     ...
            // }

            return migrator
        }

        func fetchItemsAll() throws -> [KSDBItem] {
            let databaseQueue = try DatabaseQueue(
              path: path,
              configuration: Self.makeConfiguration()
            )

            return try databaseQueue.read { ksdb in
                try KSDBItem.fetchAll(ksdb) // , sql: "SELECT * FROM item")
            }
        }

        func categoryExists(id: UUID) throws -> Bool {
            let databaseQueue = try DatabaseQueue(
              path: path,
              configuration: Self.makeConfiguration()
            )

            return try databaseQueue.read { ksdb in
                let request = KSDBCategory.filter(Column("id") == id.uuidString)
                let record = try KSDBCategory.fetchOne(ksdb, request)
                return record != nil
            }
        }

        func imageExists(id: UUID) throws -> Bool {
            let databaseQueue = try DatabaseQueue(
              path: path,
              configuration: Self.makeConfiguration()
            )

            return try databaseQueue.read { ksdb in
                let request = KSDBItem.filter(Column("id") == id.uuidString)
                // let request: SQLRequest<Player> = """
                //        SELECT * FROM image WHERE id = '\(id.uuidString)' LIMIT 1
                // """
                let record = try KSDBItem.fetchOne(ksdb, request)
                // try KSDBItem.fetchOne(ksdb, sql: "SELECT * FROM image WHERE id = '?' LIMIT 1",
                // arguments: [id.uuidString])

                return record != nil
            }
        }

        func imageExistsByGuidStr(guid: String) throws -> Bool {
            let databaseQueue = try DatabaseQueue(
              path: path,
              configuration: Self.makeConfiguration()
            )

            return try databaseQueue.read { ksdb in
                let request = KSDBCategory.filter(Column("id") == guid)
                let record = try KSDBCategory.fetchOne(ksdb, request)
                return record != nil
            }
        }

        func addTestItem(parentCategory: KSDBCategory?) throws {

        }

        func addCategoryWithImage(
            categoryName: String,
            imageData: Data?,
            parentCategoryId: UUID?
        ) throws -> KSDBCategory {
            return KSDBCategory(
                categoryName,
                imageRefRecId: 0,
                parentRefRecId: 0
            )
        }

        func fetchCategoriesById(id: UUID) -> [KSDBCategory] {
            return [KSDBCategory]()
        }

        func fetchCategoriesFromCoreData() async throws -> [KSDBCategory] {
            return [KSDBCategory]()
        }

        func fetchItemsFromCoreData() async throws -> [KSDBItem] {
            return [KSDBItem]()
        }

        func addImage(imageData: Data) throws {

        }

        func addImageWithId(id: UUID, imageData: Data, uploaded: Bool) throws {

        }

        func addImageWithGuid(guid: String, imageData: Data) {

        }

        func fetchNullableCategoryById(id: UUID) throws -> KSDBCategory? {
            return nil
        }

        func fetchNullableItemById(id: UUID) throws -> KSDBItem? {
            return nil
        }

        func fetchNullableItemImageById(id: UUID) throws -> KSDBItemImage? {
            return nil
        }

        func fetchNullableItemCategoryById(id: UUID) throws -> KSDBItemCategory? {
            return nil
        }

        func fetchImageById(id: UUID) throws -> KSDBImage {
            return KSDBImage()
        }

        func fetchCategoryById(id: UUID) throws -> KSDBCategory {
            return KSDBCategory("", imageRefRecId: 0, parentRefRecId: 0)
        }

        func fetchItemById(id: UUID) throws -> KSDBItem {
            return KSDBItem(name: "", code: "", descriptionText: "")
        }

        func fetchItemCategoryById(id: UUID) throws -> KSDBItemCategory {
            return KSDBItemCategory(itemRefRecId: 0, categoryRefRecId: 0)
        }

        func fetchItemImageById(id: UUID) throws -> KSDBItemImage {
            return KSDBItemImage(itemRefRecId: 0, imageRefRecId: 0)
        }

        func fetchItemImagesByItemId(id: UUID) throws -> [KSDBItemImage] {
            return [KSDBItemImage]()
        }

        func fetchFirstItemImageByItemId(id: UUID) throws -> KSDBItemImage {
            return KSDBItemImage(itemRefRecId: 0, imageRefRecId: 0)
        }

        func fetchFirstNullabelItemImageByItemId(id: UUID) throws -> KSDBItemImage? {
            return nil
        }
    }
}

extension Appl.Dependencies.KSDB {
    // Uncomment for enabling SQL logging
    // private static let sqlLogger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "SQL")

    /// Returns a database configuration suited for `AppDatabase`.
    ///
    /// - parameter config: A base configuration.
    static func makeConfiguration(_ config: Configuration = Configuration()) -> Configuration {
        // var config = config
        //
        // Add custom SQL functions or collations, if needed:
        // config.prepareDatabase { db in
        //     db.add(function: ...)
        // }
        //
        // Uncomment for enabling SQL logging if the `SQL_TRACE` environment variable is set.
        // See <https://swiftpackageindex.com/groue/grdb.swift/documentation/grdb/database/trace(options:_:)>
        // if ProcessInfo.processInfo.environment["SQL_TRACE"] != nil {
        //     config.prepareDatabase { db in
        //         let dbName = db.description
        //         db.trace { event in
        //             // Sensitive information (statement arguments) is not
        //             // logged unless config.publicStatementArguments is set
        //             // (see below).
        //             sqlLogger.debug("\(dbName): \(event)")
        //         }
        //     }
        // }
        //
        // #if DEBUG
        // // Protect sensitive information by enabling verbose debugging in
        // // DEBUG builds only.
        // // See <https://swiftpackageindex.com/groue/grdb.swift/documentation
        // // /grdb/configuration/publicstatementarguments>
        // config.publicStatementArguments = true
        // #endif

        return config
    }
}

extension DependencyValues {
    public var data: Appl.Dependencies.KSDB {
        get { self[Appl.Dependencies.KSDB.self] }
        set { self[Appl.Dependencies.KSDB.self] = newValue }
    }
}

extension Appl.Dependencies.KSDB: DependencyKey {
    /// let config = AppDatabase.makeConfiguration()
    /// let dbQueue = try DatabaseQueue(configuration: config)
    /// let appDatabase = try AppDatabase(dbQueue)
    public static let liveValue: Self = {
        let appDatabase = Appl.Dependencies.KSDB("ksdb.sqlite")
        return appDatabase
    }()
}

extension Appl.Dependencies.KSDB: TestDependencyKey {
    public static let previewValue = Self.noop
    public static let testValue = Self.noop
}

extension Appl.Dependencies.KSDB {
    public static let noop = Self(":memory:")
}
