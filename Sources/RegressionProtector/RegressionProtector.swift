import Foundation
import SQLite

public struct RegressionProtector {
    var database : Connection
    var limits = Table("limits")
    let limitKey = Expression<String>("limitKey")
    let limitValue = Expression<Int>("limitValue")

    public init?(
        _ databasePath : String
        )  {
        
        do {
            database = try Connection(databasePath)
        } catch {
            print(error)
            return nil
        }
    }
    
    public static func createDB(_ filePath : String, folderPath : String) throws -> Bool {
        try FileManager.default.createDirectory(atPath: folderPath, withIntermediateDirectories: true, attributes: nil)
        if FileManager.default.createFile(atPath: filePath, contents: nil, attributes: nil) {
            let db = try Connection(filePath)
            let limits = Table("limits")
            let id = Expression<Int64>("id")
            let limitKey = Expression<String>("limitKey")
            let limitValue = Expression<Int>("limitValue")
            
            try db.run(limits.create { t in
                t.column(id, primaryKey: true)
                t.column(limitKey)
                t.column(limitValue)
            })
            return true
        }
        return false
    }

    public func isLimitKeyPresent(
        _ limitKey : String
        ) throws -> Bool {
        
        guard let scalar = try database.scalar("SELECT COUNT(*) FROM limits WHERE limitKey = '\(limitKey)'") as? Int64 else { return false }
        if scalar == 1 { return true }
        return false
    }
    
    public func add(
        limitKey key : String,
        limitValue value : Int
        ) throws {
        
        let insert = limits.insert(limitKey <- key, limitValue <- value)
        try database.run(insert)
    }
    
    public func shouldWeUpdateOrRejectValue(
        limitKey key : String,
        limitValue value : Int,
        sign : String
        ) throws -> Bool {
        
        guard let numberOfFoundValue = try database.scalar("SELECT COUNT(*) FROM limits WHERE limitValue \(sign) \(value) AND limitKey = '\(key)'") as? Int64 else { return false }
        
        guard let numberOfEqualValue = try database.scalar("SELECT COUNT(*) FROM limits WHERE limitValue = \(value) AND limitKey = '\(key)'") as? Int64 else { return false }
        
        switch (numberOfFoundValue, numberOfEqualValue) {
        case (0, 0):
            let update = limits.filter(limitKey == key).update(limitValue <- value)
            try database.run(update)
            print("We have update the saved value to \(value).")
            return true
        case (0, 1):
            print("The new value(\(value)) is equal to the stored value.")
            return true
        case (1, 0), (1, 1):
            let stmt = try database.scalar("SELECT limitValue FROM limits WHERE limitKey = '\(key)'") as? Int64
            let ustmt = stmt ?? 999999
            print("The test \"\(value) \(sign) \(ustmt)\" failed")
            return false
        default:
            print("Impossible 🧐")
            return false
        }
    }
    
}
