import Foundation

public extension URL {
    /// Creates and initializes a URL request with the given URL.
    var urlRequest: URLRequest { URLRequest(url: self) }
}
