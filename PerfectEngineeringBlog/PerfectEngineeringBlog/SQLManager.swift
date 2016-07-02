//
//  SQLManager.swift
//  PerfectEngineeringBlog
//
//  Created by yansong li on 2016-07-02.
//  Copyright © 2016 YANSONG LI. All rights reserved.
//

import Foundation
import PerfectLib

/// SQLManager
public class SQLManager {
    /// Shared instance
    public static let DefaultManager = SQLManager()
    /// The sqliteDB to provided connect to this DB.
    public var sqliteDB: SQLite {
        get {
           return dbHandler
        }
    }
    /// The private variable keeps db handler.
    private let dbHandler: SQLite
    
    private init?() {
        var path = NSSearchPathForDirectoriesInDomains(
            .DesktopDirectory, .UserDomainMask, true
            ).first! + "PerfectEngineeringTestDB"
        
        do {
            try NSFileManager.defaultManager().createDirectoryAtPath(
                path, withIntermediateDirectories: true, attributes: nil
            )
        }catch {
            print("Fail to creat directory \(path)")
        }
        
        path += "/db.sqlite3"
        do {
            dbHandler = try SQLite(path)
        } catch {
            print("Fail creating database at \(path)")
            return nil
        }
    }
    
    deinit {
        dbHandler.close()
    }
}