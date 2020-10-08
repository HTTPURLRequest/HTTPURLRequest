import XCTest
@testable import HTTPURLRequest

class HTTPURLResponseTests: XCTestCase {
    var sut: HTTPURLResponse!

    func test_localizedStatusCode_createsCorrectString() {
        let url = URL(string: "http://example.com/")!
        self.sut = HTTPURLResponse(url: url, statusCode: 200)
        let statusCode = self.sut.statusCode
        let localizedString = HTTPURLResponse.localizedString(forStatusCode: statusCode)
        let localizedStatusCode = "\(statusCode) - \(localizedString)"
        
        XCTAssertEqual(self.sut.localizedStatusCode, localizedStatusCode)
    }
}
