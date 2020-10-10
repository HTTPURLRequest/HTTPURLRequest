import XCTest
@testable import HTTPURLRequest

final class HTTPURLRequestTests: XCTestCase {
    var sut: HTTPURLRequest!
    var session: MockURLSession!
    let path = "http://example.com/"
    let url = URL(string: "http://example.com/")!
    var request: URLRequest!
}

// MARK: - Initialization

extension HTTPURLRequestTests {
    func test_defaultInit_setsRequestAndSession() {
        let urlRequest = self.url.urlRequest
        let session = URLSession()
        self.sut = HTTPURLRequest(request: urlRequest, session: session)
        
        XCTAssertNotNil(self.sut.request)
        XCTAssertEqual(self.sut.request, urlRequest)
        XCTAssertNotNil(self.sut.session)
        XCTAssertEqual(self.sut.session, session)
    }
    
    func test_defaultInitWithoutSession_setsRequestAndSession() {
        let urlRequest = self.url.urlRequest
        self.sut = HTTPURLRequest(request: urlRequest)
        
        XCTAssertNotNil(self.sut.request)
        XCTAssertEqual(self.sut.request, urlRequest)
        XCTAssertNotNil(self.sut.session)
        XCTAssertEqual(self.sut.session, URLSession.shared)
    }
    
    func test_initWithEmptyPath_throws() {
        let request = { try HTTPURLRequest(path: "") }
        let expectedError = HTTPURLRequest.Error.emptyPath
        var actualError: Error? = nil
        
        XCTAssertThrowsError(try request())
        
        do {
            _ = try request()
        } catch {
            actualError = error
        }
        
        XCTAssertNotNil(actualError)
        XCTAssertEqual(actualError as? HTTPURLRequest.Error, expectedError)
    }
    
    func test_initWithInvalidPath_throws() {
        let path = "INVALID PATH"
        let request = { try HTTPURLRequest(path: path) }
        let expectedError = HTTPURLRequest.Error.invalidPath(path)
        var actualError: Error? = nil
        
        XCTAssertThrowsError(try request())
        
        do {
            _ = try request()
        } catch {
            actualError = error
        }
        
        XCTAssertNotNil(actualError)
        XCTAssertEqual(actualError as? HTTPURLRequest.Error, expectedError)
    }
    
    func test_pathInit_setsRequestAndSession() {
        let session = URLSession()
        self.sut = try! HTTPURLRequest(path: self.path, session: session)
        
        XCTAssertNotNil(self.sut.request)
        XCTAssertEqual(self.sut.request, self.path.url!.urlRequest)
        XCTAssertNotNil(self.sut.session)
        XCTAssertEqual(self.sut.session, session)
    }
    
    func test_pathInitWithoutSession_setsRequestAndSession() {
        self.sut = try! HTTPURLRequest(path: self.path)
        
        XCTAssertNotNil(self.sut.request)
        XCTAssertEqual(self.sut.request, self.path.url!.urlRequest)
        XCTAssertNotNil(self.sut.session)
        XCTAssertEqual(self.sut.session, URLSession.shared)
    }
    
    func test_createWithInvalidPath_createsFailureResult() {
        let path = "INVALID PATH"
        let result = HTTPURLRequest.create(path: path)
        
        XCTAssertNil(result.success)
        XCTAssertNotNil(result.failure)
    }
    
    func test_createWithValidPath_createsSuccessResult() {
        let result = HTTPURLRequest.create(path: self.path)
        
        XCTAssertNotNil(result.success)
        XCTAssertNil(result.failure)
    }

    static var allTests = [
        ("test_defaultInit_setsRequestAndSession", test_defaultInit_setsRequestAndSession),
    ]
}

// MARK: - DataTask

extension HTTPURLRequestTests {
    override func setUp() {
        super.setUp()
        self.session = MockURLSession()
        self.request = URLRequest(url: self.url)
        self.sut = HTTPURLRequest(request: self.request, session: self.session)
    }
    
    override func tearDown() {
        self.request = nil
        self.session = nil
        self.sut = nil
        super.tearDown()
    }
    
    func test_dataTask_callsExpectedRequest() {
        self.sut.dataTask() { _ in }
        
        XCTAssertNotNil(self.request)
        XCTAssertEqual(self.session.lastRequest, self.request)
    }
    
    func test_dataTask_callsResumeOnTask() throws {
        self.sut.dataTask() { _ in }

        XCTAssertNotNil(self.session.lastTask)
        let lastTask = try XCTUnwrap(self.session.lastTask)
        XCTAssertTrue(lastTask.calledResume)
    }

    func test_dataTask_givenError_callsCompletionWithFailure() {
        let expectedError = NSError(domain: NSURLErrorDomain, code: NSURLErrorTimedOut)

        let result = self.runDataTask(data: Data(), self.response(200), expectedError)

        XCTAssertTrue(result.calledCompletion)
        XCTAssertNil(result.data)

        let actualError = result.error as NSError?
        XCTAssertEqual(actualError, expectedError)
    }

    typealias APIDataResult = (calledCompletion: Bool, data: DataResponse?, error: Error?)

    func runDataTask(data: Data?, _ response: HTTPURLResponse? = nil, _ error: Error? = nil) -> APIDataResult {
        var calledCompletion = false
        var receivedData: DataResponse?
        var receivedError: Error?

        self.sut.dataTask() { result in
            calledCompletion = true

            receivedData = result.success
            receivedError = result.failure
        }

        self.session.lastTask?.completionHandler(data, response, error)

        return (calledCompletion, receivedData, receivedError)
    }

    func response(_ statusCode: Int) -> HTTPURLResponse? {
        HTTPURLResponse(url: self.url, statusCode: statusCode)
    }

    func test_dataTask_emptyData_callsCompletionWithFailure() {
        let result = self.runDataTask(data: nil, self.response(200))
        let expectedError = HTTPURLRequest.Error.emptyData

        XCTAssertTrue(result.calledCompletion)
        XCTAssertNil(result.data)
        let actualError = result.error as? HTTPURLRequest.Error
        XCTAssertEqual(actualError, expectedError)
    }

    func test_dataTask_unknownResponse_callsCompletionWithFailure() {
        let result = self.runDataTask(data: Data())
        let expectedError = HTTPURLRequest.Error.unknownResponse

        XCTAssertTrue(result.calledCompletion)
        XCTAssertNil(result.data)
        let actualError = result.error as? HTTPURLRequest.Error
        XCTAssertEqual(actualError, expectedError)
    }

    func test_dataTask_givenResponseStatusCode500_callsCompletionWithFailure() throws {
        let response = self.response(500)
        let unwrappedResponse = try XCTUnwrap(response)
        let httpData = DataResponse(data: Data(), response: unwrappedResponse)
        let expectedError = HTTPURLRequest.Error.wrongStatusCode(httpData)

        let result = self.runDataTask(data: Data(), response)

        XCTAssertTrue(result.calledCompletion)
        XCTAssertNil(result.data)
        let actualError = result.error as? HTTPURLRequest.Error
        XCTAssertEqual(actualError, expectedError)
    }

    func test_dataTask_givenDataAndSuccessResponseStatusCode_callsCompletionWithSuccess() throws {
        let result = self.runDataTask(data: Data(), self.response(200))

        XCTAssertTrue(result.calledCompletion)
        XCTAssertNotNil(result.data)
        XCTAssertNil(result.error)
    }
}

// MARK: - Decodable DataTask

extension HTTPURLRequestTests {
    typealias APIDecodableResult<T: Decodable> = (calledCompletion: Bool, decoded: DecodableResponse<T>?, error: Error?)

    func runDecodableDataTask<T: Decodable>(type: T.Type, data: Data?, _ response: HTTPURLResponse? = nil, _ error: Error? = nil) -> APIDecodableResult<T> {
        var calledCompletion = false
        var receivedDecoded: DecodableResponse<T>?
        var receivedError: Error?

        self.sut.dataTask(decoding: T.self) { result in
            calledCompletion = true

            receivedDecoded = result.success
            receivedError = result.failure
        }

        self.session.lastTask?.completionHandler(data, response, error)

        return (calledCompletion, receivedDecoded, receivedError)
    }
    
    func test_decodingDataTask_givenInvalidData_callsCompletionWithFailure() {
        let result = self.runDecodableDataTask(type: TestJSON.self, data: Data(), self.response(200))

        XCTAssertTrue(result.calledCompletion)
        XCTAssertNil(result.decoded)
        XCTAssertNotNil(result.error)
    }
    
    func test_decodingDataTask_validData_callsCompletionWithSuccess() throws {
        let jsonData = Data(jsonString.utf8)
        let result = self.runDecodableDataTask(type: TestJSON.self, data: jsonData, self.response(200))

        XCTAssertTrue(result.calledCompletion)
        XCTAssertNotNil(result.decoded)
        XCTAssertNil(result.error)
    }
}


// MARK: - JSON DataTask

extension HTTPURLRequestTests {
    typealias APIJSONResult = (calledCompletion: Bool, json: Any?, error: Error?)

    func runJSONDataTask(data: Data?, _ response: HTTPURLResponse? = nil, _ error: Error? = nil) -> APIJSONResult {
        var calledCompletion = false
        var receivedJSON: Any?
        var receivedError: Error?

        self.sut.jsonDataTask() { result in
            calledCompletion = true

            receivedJSON = result.success
            receivedError = result.failure
        }

        self.session.lastTask?.completionHandler(data, response, error)

        return (calledCompletion, receivedJSON, receivedError)
    }
    
    func test_jsonDataTask_givenInvalidData_callsCompletionWithFailure() {
        let result = self.runJSONDataTask(data: Data(), self.response(200))

        XCTAssertTrue(result.calledCompletion)
        XCTAssertNil(result.json)
        XCTAssertNotNil(result.error)
    }
    
    func test_jsonDataTask_validData_callsCompletionWithSuccess() throws {
        let jsonData = Data(jsonString.utf8)
        let result = self.runJSONDataTask(data: jsonData, self.response(200))

        XCTAssertTrue(result.calledCompletion)
        XCTAssertNotNil(result.json)
        XCTAssertNil(result.error)
    }
}


// MARK: - Mock Classes

typealias MockCompletion = (Data?, URLResponse?, Error?) -> Void

class MockURLSession: URLSession {
    private (set) var lastRequest: URLRequest?
    private (set) var lastTask: MockURLSessionDataTask?
    
    override init() { }
    
    override func dataTask(with request: URLRequest, completionHandler: @escaping MockCompletion) -> URLSessionDataTask {
        self.lastRequest = request
        let lastTask = MockURLSessionDataTask(completionHandler: completionHandler, request: request)
        self.lastTask = lastTask
        
        return lastTask
    }
}

class MockURLSessionDataTask: URLSessionDataTask {
    var completionHandler: MockCompletion
    var request: URLRequest
    var calledResume = false
    
    init(completionHandler: @escaping MockCompletion, request: URLRequest) {
        self.completionHandler = completionHandler
        self.request = request
    }

    override func resume() {
        self.calledResume = true
    }
}
