import RegressionProtector
import XCTest

final class RegressionProtectorTests: XCTestCase {
    let dbFilePath = ".test/test.sqlite3"
    let dbPath = ".test"
    var rp : RegressionProtector?
    override func setUp() {
        do {
            try RegressionProtector.createDB(dbFilePath, folderPath: dbPath)
        } catch {
            print(error)
        }
     rp = RegressionProtector(dbFilePath)
    }
    
    func testInstance() {
        XCTAssertNotNil(RegressionProtector(dbFilePath))
    }
    
    static var allTests = [
        ("testInstance", testInstance),
    ]
}
