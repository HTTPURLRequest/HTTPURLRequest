import Foundation

public extension HTTPURLRequest {
    enum Error: Swift.Error, Equatable {
        case emptyPath
        case invalidPath(_ path: String)
        case emptyData
        case unknownResponse
        case unsuccessfulHTTPStatusCode(_ dataResponse: DataResponse)
        case invalidImageData
        
        public var unsuccessfulHTTPStatusCodeData: DataResponse? {
            if case let Error.unsuccessfulHTTPStatusCode(httpData) = self {
                return httpData
            }
            
            return nil
        }
    }
    
    
}

extension HTTPURLRequest.Error: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .emptyPath:
            let key = "String path is empty."
            return NSLocalizedString(key, comment: "Path is empty.")
        case let .invalidPath(path):
            let key = "Invalid path for URL: \(path)."
            return NSLocalizedString(key, comment: "Invalid path for URL.")
        case .emptyData:
            let key = "There is no data in the server response."
            return NSLocalizedString(key, comment: "Data is not available.")
        case .unknownResponse:
            let key = "Server response was not recognized."
            return NSLocalizedString(key, comment: "Unable to recognize the response.")
        case let .unsuccessfulHTTPStatusCode(httpData):
            let statusCode = httpData.response.localizedStatusCode
            let key = "Unsuccessful HTTP status code: \(statusCode)."
            return NSLocalizedString(key, comment: statusCode)
        case .invalidImageData:
            let key = "Unsupported data for image to initialize."
            return NSLocalizedString(key, comment: "Invalid image data.")
        }
    }
    
    
}
