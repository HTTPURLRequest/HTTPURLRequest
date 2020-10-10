import XCTest
@testable import HTTPURLRequest

class DecodableTests: XCTestCase {
    func test_decoding_createsCorrectDecodable() {
        let jsonData = Data(jsonString.utf8)
        let actualTestJSON = try? TestJSON(decoding: jsonData)
        let expectedTestJSON = try? JSONDecoder().decode(TestJSON.self, from: jsonData)
        
        XCTAssertNotNil(actualTestJSON)
        XCTAssertEqual(actualTestJSON, expectedTestJSON)
    }
}
