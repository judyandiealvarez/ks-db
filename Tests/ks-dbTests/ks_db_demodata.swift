//
//  ks_db_demodata.swift
//  ks-db
//
//  Created by Shadowchamber on 24/12/24.
//

import Appl
import GRDB

extension Appl.Dependencies.KSDB
{
    func initDemoData() throws
    {
        try self.start()
        
        let dbQueue = try DatabaseQueue(path: self.path)
        
        try dbQueue.write
        {
            db in
            // Appl.Dependencies.DB.Entities.Barcode()
        }
    }
}
