import XCTest
@testable import HTTPURLRequest

class HTTPURLRequestErrorTests: XCTestCase {
    var sut: HTTPURLRequest.Error!

    func test_errorDescription_createsCorrectString() throws {
        self.sut = .emptyPath
        var localizedDescription = "String path is empty."
        XCTAssertEqual(self.sut.localizedDescription, localizedDescription)
        
        var path = "INVALID PATH"
        self.sut = .invalidPath(path)
        localizedDescription = "Invalid path for URL: \(path)."
        XCTAssertEqual(self.sut.localizedDescription, localizedDescription)
        
        self.sut = .emptyData
        localizedDescription = "There is no data in the server response."
        XCTAssertEqual(self.sut.localizedDescription, localizedDescription)
        
        self.sut = .unknownResponse
        localizedDescription = "Server response was not recognized."
        XCTAssertEqual(self.sut.localizedDescription, localizedDescription)
        
        path = "http://example.com/"
        let response = HTTPURLResponse(url: path.url!, statusCode: 500)
        let unwrappedResponse = try XCTUnwrap(response)
        let httpData = DataResponse(data: Data(), response: unwrappedResponse)
        self.sut = HTTPURLRequest.Error.unsuccessfulHTTPStatusCode(httpData)
        let statusCode = httpData.response.localizedStatusCode
        localizedDescription = "Unsuccessful HTTP status code: \(statusCode)."
        XCTAssertEqual(self.sut.localizedDescription, localizedDescription)
    }
    
    func test_wrongStatusCodeHTTPData_returnsCorrectValue() throws {
        let path = "http://example.com/"
        let response = HTTPURLResponse(url: path.url!, statusCode: 500)
        let unwrappedResponse = try XCTUnwrap(response)
        let data = Data()
        let httpData = DataResponse(data: data, response: unwrappedResponse)
        self.sut = HTTPURLRequest.Error.unsuccessfulHTTPStatusCode(httpData)
        
        let errorHTTPData = self.sut.unsuccessfulHTTPStatusCodeData
        XCTAssertNotNil(errorHTTPData)
        XCTAssertEqual(errorHTTPData?.response, response)
        XCTAssertEqual(errorHTTPData?.data, data)
    }
    
    
}
