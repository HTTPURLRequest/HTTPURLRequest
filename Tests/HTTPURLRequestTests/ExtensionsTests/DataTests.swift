import XCTest
@testable import HTTPURLRequest

class DataTests: XCTestCase {
    var sut: Data!

    func test_utf8String_createsCorrectString() {
        let string = "TEST"
        self.sut = Data(string.utf8)
        
        XCTAssertEqual(string, self.sut.utf8String)
    }
}
