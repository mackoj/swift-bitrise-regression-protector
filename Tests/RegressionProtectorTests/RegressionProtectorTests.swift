import RegressionProtector
import XCTest
import SnapshotTesting

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
    
    func testIsLimitKeyPresentAndAdd() {
        guard let reg = rp else {
            XCTAssertNil(rp)
            return
        }
        
        do {
            var isLimitKeyPresent = try reg.isLimitKeyPresent(#function)
            XCTAssertFalse(isLimitKeyPresent)
            try reg.add(limitKey: #function, limitValue: 5)
            isLimitKeyPresent = try reg.isLimitKeyPresent(#function)
            XCTAssertTrue(isLimitKeyPresent)
        } catch {
            print(error)
        }
    }
    
    func testShouldWeUpdateOrRejectValue() {
        guard let reg = rp else {
            XCTAssertNil(rp)
            return
        }
        
        do {
            try reg.add(limitKey: #function, limitValue: 5)

            let val = try reg.shouldWeUpdateOrRejectValue(limitKey: #function, limitValue: 6, sign: RegressionProtector.Sign.inferiorTo)
            XCTAssertFalse(val)

            let val2 = try reg.shouldWeUpdateOrRejectValue(limitKey: #function, limitValue: 4, sign: RegressionProtector.Sign.inferiorTo)
            XCTAssertTrue(val2)

            let val3 = try reg.shouldWeUpdateOrRejectValue(limitKey: #function, limitValue: 4, sign: RegressionProtector.Sign.inferiorTo)
            XCTAssertTrue(val3)

            try reg.updateLimit(#function, 3)
            let val4 = try reg.shouldWeUpdateOrRejectValue(limitKey: #function, limitValue: 4, sign: RegressionProtector.Sign.inferiorTo)
            XCTAssertFalse(val4)
            
            let val5 = try reg.shouldWeUpdateOrRejectValue(limitKey: #function, limitValue: 4, sign: RegressionProtector.Sign.superiorTo)
            XCTAssertTrue(val5)


            let val6 = try reg.shouldWeUpdateOrRejectValue(limitKey: #function, limitValue: 4, sign: RegressionProtector.Sign.superiorTo)
            XCTAssertTrue(val6)

            let val7 = try reg.shouldWeUpdateOrRejectValue(limitKey: #function, limitValue: 5, sign: RegressionProtector.Sign.superiorTo)
            XCTAssertTrue(val7)

            let val8 = try reg.shouldWeUpdateOrRejectValue(limitKey: #function, limitValue: 3, sign: RegressionProtector.Sign.superiorTo)
            XCTAssertFalse(val8)
        } catch {
            print(error)
        }
    }
    
    static var allTests = [
        ("testInstance", testInstance),
        ("testIsLimitKeyPresentAndAdd", testIsLimitKeyPresentAndAdd),
        ("testShouldWeUpdateOrRejectValue", testShouldWeUpdateOrRejectValue),
    ]
}
