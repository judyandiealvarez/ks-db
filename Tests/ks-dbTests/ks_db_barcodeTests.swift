//
//  ks_db_barcodeTests.swift
//  ks-db
//
//  Created by Shadowchamber on 28/12/24.
//

import Testing
@testable import ks_db
import Appl
import Dependencies
import GRDB

@Test func barcode_crud() async throws
{
    // Write your test here and use APIs like `#expect(...)` to check expected conditions.

    do
    {
        let db = DependencyValues.test.data
        try db.start()
        
            //let dbQueue = try DatabaseQueue(path: self.path)
    }
    catch let error
    {
        print(error.localizedDescription)
    }
}



