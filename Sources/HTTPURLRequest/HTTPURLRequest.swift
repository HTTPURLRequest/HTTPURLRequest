import Foundation

public struct HTTPURLRequest {
    public typealias Completion = (Result<HTTPData, Swift.Error>) -> Void
    
    public enum Error: Swift.Error, Equatable {
        case emptyPath
        case invalidPath(_ path: String)
        case emptyData
        case unknownResponse
        case wrongStatusCode(_ httpData: HTTPData)
    }
    
    public let request: URLRequest
    public let session: URLSession
    
    public func dataTask(completion: @escaping Completion) {
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
            
            let httpData = HTTPData(data: data, response: httpResponse)
            if (200...299).contains(httpResponse.statusCode) {
                completion(.success(httpData))
            } else {
                let error = Error.wrongStatusCode(httpData)
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
}

// MARK: Initialization

public extension HTTPURLRequest {
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
