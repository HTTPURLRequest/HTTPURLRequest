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
    public typealias ImageCompletion = (Result<ImageResponse, Swift.Error>) -> Void
    
    /// A URL load request that is independent of protocol or URL scheme.
    public let request: URLRequest
    /// An object that coordinates a group of related, network data-transfer tasks.
    public let session: URLSession
    
    /// Creates and initializes a URL request with the given URLRequest and URLSession.
    /// - Parameters:
    ///   - request: A URL load request that is independent of protocol or URL scheme.
    ///   - session: An object that coordinates a group of related, network data-transfer tasks (optional). Default value [URLSession.shared](https://developer.apple.com/documentation/foundation/urlsession/1409000-shared).
    ///
    /// Request with `URLRequest`:
    /// ```
    /// let url = URL(string: "http://example.com/")!
    /// let urlRequest = URLRequest(url: url)
    /// let request = HTTPURLRequest(request: urlRequest)
    /// ```
    public init(request: URLRequest, session: URLSession = URLSession.shared) {
        self.request = request
        self.session = session
    }
    
    /// Creates a task that retrieves the contents of a URL based on the specified URL request object,
    /// and calls a handler upon completion.
    ///
    /// Newly-initialized tasks start the task immediately.
    /// - Parameter completion: The completion handler to call when the load request is complete. This handler is executed on the delegate queue.
    ///
    /// - Warning: Don't forget to pass the response to the main thread if necessary, as requests are executed in the background thread.
    /// ```
    /// request.dataTask() { response in
    ///     switch response {
    ///     case let .success(result):
    ///         print(result)
    ///     case let .failure(error):
    ///         print(error)
    ///     }
    /// }
    /// ```
    /// If you are only interested in data, you can use the `success` property from `response`:
    /// ```
    /// request.dataTask() { response in
    ///     print(response.success)
    /// }
    /// ```
    /// # String
    /// To get `String` value from `response`:
    /// ```
    /// let data: Data? = response.success?.data
    /// let string: String? = data?.utf8String
    /// ```
    /// # UIImage
    /// To get `UIImage` value from `response` (pass `response` to the main thread when working with `UI`):
    /// ```
    /// let data: Data? = response.success?.data
    /// DispatchQueue.main.async {
    ///     let image: UIImage? = data?.image
    ///     ...
    /// }
    /// ```
    /// # Decodable
    /// To get `Decodable` value from `response`:
    /// ```swift
    /// struct Product: Decodable {
    ///     let title: String
    /// }
    /// let data: Data? = response.success?.data
    /// let product: Product? = data?.decoding(type: Product.self).success
    /// ```
    /// For more information about `Decodable`, see [Encoding and Decoding Custom Types](https://developer.apple.com/documentation/foundation/archives_and_serialization/encoding_and_decoding_custom_types).
    /// # jsonObject
    /// To get `jsonObject` value from `response`:
    /// ```
    /// let data: Data? = response.success?.data
    /// let jsonObject: Any? = data?.json().success
    /// ```
    /// For more information about `JSON in Swift`, see [Working with JSON in Swift](https://developer.apple.com/swift/blog/?id=37).
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
    
    /// Creates a task that retrieves the contents of a URL based on the specified URL request object, converts JSON to the equivalent Foundation objects and calls a handler upon completion.
    ///
    /// Newly-initialized tasks start the task immediately.
    /// - Parameter completion: The completion handler to call when the load request is complete. This handler is executed on the delegate queue.
    @discardableResult
    public func imageDataTask(completion: @escaping ImageCompletion) -> URLSessionDataTask {
        let task = self.dataTask { response in
            switch response {
            case let .success(result):
                if let image = result.data.image {
                    let imageResponse = ImageResponse(image: image, response: result.response)
                    completion(.success(imageResponse))
                } else {
                    let error = Error.invalidImageData
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
