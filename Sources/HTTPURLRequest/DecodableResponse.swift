import Foundation

public struct DecodableResponse<T: Decodable> {
    public let decoded: T
    public let response: HTTPURLResponse
}
