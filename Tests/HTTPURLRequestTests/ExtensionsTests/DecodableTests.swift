import XCTest
@testable import HTTPURLRequest

class DecodableTests: XCTestCase {
    struct TestJSON: Decodable, Equatable {
        let names: [String]
    }
    let jsonString = #"{"names":["Bob","Tim","Tina"]}"#
    
    func test_decoding_createsCorrectDecodable() {
        let jsonData = Data(self.jsonString.utf8)
        let actualTestJSON = try? TestJSON(decoding: jsonData)
        let expectedTestJSON = try? JSONDecoder().decode(TestJSON.self, from: jsonData)
        
        XCTAssertNotNil(actualTestJSON)
        XCTAssertEqual(actualTestJSON, expectedTestJSON)
    }
}
