import Foundation

public extension Data {
    var utf8String: String { String(decoding: self, as: UTF8.self) }
}
