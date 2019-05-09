import Foundation
import RegressionProtector

extension Collection {
    
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

func start(limitKey : String, limitValue : Int, sign : RegressionProtector.Sign, dbPath : String, dbFilePath : String) {
    do {
        if FileManager.default.fileExists(atPath: dbFilePath) == false {
            if try RegressionProtector.createDB(dbFilePath, folderPath: dbPath) == false {
                print("Failed to create db file")
                exit(0)
            }
        }
        
        guard let rp = RegressionProtector(dbFilePath) else { exit(1) }
        let isTableCreate = try rp.isLimitKeyPresent(limitKey)
        if isTableCreate == false {
            try rp.add(limitKey: limitKey, limitValue: limitValue)
        }
        let state = try rp.shouldWeUpdateOrRejectValue(limitKey: limitKey, limitValue: limitValue, sign: sign)
        let mode : Int32 = (state == true) ? 0 : 1
        exit(mode)
    } catch {
        print(error)
        exit(1)
    }
    exit(0)
}


let arguments = CommandLine.arguments.dropFirst()
guard arguments.count == 4 else {
    print("Bad Argument")
    exit(1)
}

guard
    let limitKey = arguments[safe: 1],
    let stringValue = arguments[safe: 2],
    let limitValue = Int(stringValue),
    let signString = arguments[safe: 3],
    let sign = RegressionProtector.Sign(rawValue: signString),
    let dbFilePath = arguments[safe: 4],
    let url = URL(string: dbFilePath)
    else
{
    print("Bad Argument")
    exit(1)
}

start(
    limitKey: limitKey,
    limitValue: limitValue,
    sign: sign,
    dbPath: url.deletingLastPathComponent().absoluteString,
    dbFilePath: dbFilePath
)
