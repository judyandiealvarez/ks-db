import Foundation
import Appl
import GRDB
import Dependencies

extension Appl.Dependencies {
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
                var insertedBarcode = try Appl.Dependencies.KSDB.Entities.Barcode(
                    code: "53674567"
                )
                .inserted(ksdb)

                insertedBarcode.code += "0"

              try insertedBarcode.update(ksdb)
            }
        }

        /// The DatabaseMigrator that defines the database schema.
        ///
        /// See <https://swiftpackageindex.com/groue/grdb.swift/documentation/grdb/migrations>
        private var migrator: DatabaseMigrator {
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
