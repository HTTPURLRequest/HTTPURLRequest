import XCTest
@testable import HTTPURLRequest

class URLTests: XCTestCase {
    var sut: URL!

    func test_url_createsCorrectURL() throws {
        let path = "http://example.com/"
        self.sut = path.url
        let expectedRequest = URLRequest(url: self.sut)
        let actualRequest = self.sut.urlRequest
        
        XCTAssertNotNil(actualRequest)
        XCTAssertEqual(actualRequest, expectedRequest)
    }
}
