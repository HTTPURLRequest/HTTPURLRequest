import XCTest
@testable import HTTPURLRequest

class ResultTests: XCTestCase {
    var sut: Result<String, Error>!

    func test_output_successfulOutpoutCreatesCorrectValues() {
        let result = "TEST"
        self.sut = .success(result)
        
        XCTAssertEqual(self.sut.output.success, result)
        XCTAssertNil(self.sut.output.failure)
    }
    
    func test_output_failureOutpoutCreatesCorrectValues() {
        let error = HTTPURLRequest.Error.emptyPath
        self.sut = .failure(error)
        
        XCTAssertEqual(self.sut.output.failure as? HTTPURLRequest.Error, error)
        XCTAssertNil(self.sut.output.success)
    }
}
