import Testing
@testable import ks_db
import Appl
import Dependencies

@Test func example() async throws
{
    // Write your test here and use APIs like `#expect(...)` to check expected conditions.

    do
    {
        let db = DependencyValues.test.data
        try db.initDemoData()
    }
    catch let error
    {
        print(error.localizedDescription)
    }
    
    

    //let dbQueue = try DatabaseQueue(path: "ksdb.sqlite")

    /*try dbQueue.write { db in
    try db.execute(sql: """
        CREATE TABLE player (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            score INT)
        """)
    
    try db.execute(
        sql: "INSERT INTO player (name, score) VALUES (?, ?)",
        arguments: ["Barbara", 1000])
    
    try db.execute(
        sql: "UPDATE player SET score = :score WHERE id = :id",
        arguments: ["score": 1000, "id": 1])
    }*/
}



