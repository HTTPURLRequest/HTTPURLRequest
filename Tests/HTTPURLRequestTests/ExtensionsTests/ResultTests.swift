import XCTest
@testable import HTTPURLRequest

class ResultTests: XCTestCase {
    var sut: Result<String, Error>!

    func test_output_successfulOutpoutCreatesCorrectValues() {
        let result = "TEST"
        self.sut = .success(result)
        
        XCTAssertEqual(self.sut.success, result)
        XCTAssertNil(self.sut.failure)
    }
    
    func test_output_failureOutpoutCreatesCorrectValues() {
        let error = HTTPURLRequest.Error.emptyPath
        self.sut = .failure(error)
        
        XCTAssertEqual(self.sut.failure as? HTTPURLRequest.Error, error)
        XCTAssertNil(self.sut.success)
    }
}
