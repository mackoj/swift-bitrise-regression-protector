import Foundation
import RegressionProtector

let limitKey = "warning"
let limitValue = 6
let sign = "<"
let dbPath = "/Users/jeffreymacko/AppOps/tools/limiter/.ci"
let dbFilePath = "/Users/jeffreymacko/AppOps/tools/limiter/.ci/ci.sqlite3"

func main(limitKey : String, limitValue : Int, sign : String, dbPath : String, dbFilePath : String) {
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

main(limitKey: limitKey, limitValue: limitValue, sign: sign, dbPath: dbPath, dbFilePath: dbFilePath)
