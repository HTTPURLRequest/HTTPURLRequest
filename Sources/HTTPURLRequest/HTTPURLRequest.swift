import Foundation

/// **HTTPURLRequest** is an easy way of an HTTP networking in Swift.
///
/// `HTTPURLRequest` keeps the information about the request using
/// [URLRequest](https://developer.apple.com/documentation/foundation/urlrequest) and uses
/// [URLSession](https://developer.apple.com/documentation/foundation/urlsession)
///  to send the request to a server.
public struct HTTPURLRequest {
    public typealias Completion = (Result<DataResponse, Swift.Error>) -> Void
    public typealias DecodableCompletion<T: Decodable> = (Result<DecodableResponse<T>, Swift.Error>) -> Void
    public typealias JSONCompletion = (Result<JSONResponse, Swift.Error>) -> Void
    
    public enum Error: Swift.Error, Equatable {
        case emptyPath
        case invalidPath(_ path: String)
        case emptyData
        case unknownResponse
        case wrongStatusCode(_ dataResponse: DataResponse)
    }
    
    /// A URL load request that is independent of protocol or URL scheme.
    public let request: URLRequest
    /// An object that coordinates a group of related, network data-transfer tasks.
    public let session: URLSession
    
    /// Creates and initializes a URL request with the given URLRequest and URLSession.
    /// - Parameters:
    ///   - request: A URL load request that is independent of protocol or URL scheme.
    ///   - session: An object that coordinates a group of related, network data-transfer tasks (optional). Default value [URLSession.shared](https://developer.apple.com/documentation/foundation/urlsession/1409000-shared).
    public init(request: URLRequest, session: URLSession = URLSession.shared) {
        self.request = request
        self.session = session
    }
    
    /// Creates a task that retrieves the contents of a URL based on the specified URL request object,
    /// and calls a handler upon completion.
    ///
    /// Newly-initialized tasks start the task immediately.
    /// - Parameter completion: The completion handler to call when the load request is complete. This handler is executed on the delegate queue.
    @discardableResult
    public func dataTask(completion: @escaping Completion) -> URLSessionDataTask {
        let task = self.session.dataTask(with: self.request) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                let error = Error.emptyData
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                let error = Error.unknownResponse
                completion(.failure(error))
                return
            }
            
            let dataResponse = DataResponse(data: data, response: httpResponse)
            if (200...299).contains(httpResponse.statusCode) {
                completion(.success(dataResponse))
            } else {
                let error = Error.wrongStatusCode(dataResponse)
                completion(.failure(error))
            }
        }
        
        task.resume()
        
        return task
    }
    
    /// Creates a task that retrieves the contents of a URL based on the specified URL request object, decodes an instance of the indicated type and calls a handler upon completion.
    ///
    /// Newly-initialized tasks start the task immediately.
    /// - Parameters:
    ///   - decoding: Decoded type.
    ///   - decoder: An object that decodes instances of a data type from JSON objects (optional).
    ///   - completion: The completion handler to call when the load request is complete. This handler is executed on the delegate queue.
    @discardableResult
    public func dataTask<T: Decodable>(decoding: T.Type, decoder: JSONDecoder = JSONDecoder(), completion: @escaping DecodableCompletion<T>) -> URLSessionDataTask {
        let task = self.dataTask { response in
            switch response {
            case let .success(result):
                switch result.data.decoding(type: T.self, decoder: decoder) {
                case let .success(decoded):
                    let decodableResponse = DecodableResponse(decoded: decoded, response: result.response)
                    completion(.success(decodableResponse))
                case let .failure(error):
                    completion(.failure(error))
                }
            case let .failure(error):
                completion(.failure(error))
            }
        }
        
        return task
    }
    
    /// Creates a task that retrieves the contents of a URL based on the specified URL request object, converts JSON to the equivalent Foundation objects and calls a handler upon completion.
    ///
    /// Newly-initialized tasks start the task immediately.
    /// - Parameters:
    ///   - options: Options used when creating Foundation objects from JSON data (optional).
    ///   - completion: The completion handler to call when the load request is complete. This handler is executed on the delegate queue.
    @discardableResult
    public func jsonDataTask(options opt: JSONSerialization.ReadingOptions = [], completion: @escaping JSONCompletion) -> URLSessionDataTask {
        let task = self.dataTask { response in
            switch response {
            case let .success(result):
                switch result.data.json(options: opt) {
                case let .success(json):
                    let jsonResponse = JSONResponse(json: json, response: result.response)
                    completion(.success(jsonResponse))
                case let .failure(error):
                    completion(.failure(error))
                }
            case let .failure(error):
                completion(.failure(error))
            }
        }
        
        return task
    }
}

// MARK: Initialization

public extension HTTPURLRequest {
    /// Creates and initializes a URL request with the given URLRequest and URLSession.
    /// - Parameters:
    ///   - path: path string value
    ///   - session: An object that coordinates a group of related, network data-transfer tasks (optional). Default value [URLSession.shared](https://developer.apple.com/documentation/foundation/urlsession/1409000-shared).
    /// - Throws: If the path is empty string or has an invalid value an error is thrown: HTTPURLRequest.Error.emptyPath or HTTPURLRequest.Error.invalidPath(path) accordingly.
    init(path: String, session: URLSession = URLSession.shared) throws {
        let path = path.trimmingCharacters(in: .whitespacesAndNewlines)
        if path.isEmpty {
            throw Error.emptyPath
        }
        guard let url = path.url else {
            throw Error.invalidPath(path)
        }
        self.init(url: url, session: session)
    }
    
    /// Creates and initializes a URL request with the given URLRequest and URLSession.
    /// - Parameters:
    ///   - path: path string value
    ///   - session: An object that coordinates a group of related, network data-transfer tasks (optional). Default value [URLSession.shared](https://developer.apple.com/documentation/foundation/urlsession/1409000-shared).
    static func create(path: String, session: URLSession = URLSession.shared) -> Result<HTTPURLRequest, Swift.Error> {
        do {
            let request = try HTTPURLRequest(path: path, session: session)
            return .success(request)
        } catch {
            return .failure(error)
        }
    }
    
    /// Creates and initializes a URL request with the given URLRequest and URLSession.
    /// - Parameters:
    ///   - url: A value that identifies the location of a resource, such as an item on a remote server or the path to a local file.
    ///   - session: An object that coordinates a group of related, network data-transfer tasks (optional). Default value [URLSession.shared](https://developer.apple.com/documentation/foundation/urlsession/1409000-shared).
    init(url: URL, session: URLSession = URLSession.shared) {
        let request = url.urlRequest
        self.init(request: request, session: session)
    }
}

extension HTTPURLRequest.Error: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .emptyPath:
            let key = "String path is empty"
            return NSLocalizedString(key, comment: "Path is empty")
        case let .invalidPath(path):
            let key = "Invalid path for URL: \(path)"
            return NSLocalizedString(key, comment: "Invalid path for URL")
        case .emptyData:
            let key = "There is no data in the server response"
            return NSLocalizedString(key, comment: "Data is not available")
        case .unknownResponse:
            let key = "Server response was not recognized"
            return NSLocalizedString(key, comment: "Unable to recognize the response")
        case let .wrongStatusCode(httpData):
            let statusCode = httpData.response.localizedStatusCode
            let error = httpData.data.utf8String
            let key = "Unsuccessful HTTP status code: \(statusCode). Error: \(error)"
            return NSLocalizedString(key, comment: statusCode)
        }
    }
}
