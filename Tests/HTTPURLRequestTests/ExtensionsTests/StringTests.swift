import XCTest
@testable import HTTPURLRequest

class StringTests: XCTestCase {
    var sut: String!

    func test_url_createsCorrectURL() {
        self.sut = "http://example.com"
        let expectedURL = URL(string: self.sut)
        let actualURL = self.sut.url
        
        XCTAssertNotNil(actualURL)
        XCTAssertEqual(actualURL, expectedURL)
    }
}
