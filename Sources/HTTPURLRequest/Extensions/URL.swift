import Foundation

public extension URL {
    var urlRequest: URLRequest { URLRequest(url: self) }
}
