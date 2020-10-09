import Foundation

public extension Decodable {
    init(decoding data: Data, decoder: JSONDecoder = JSONDecoder()) throws {
        self = try decoder.decode(Self.self, from: data)
    }
}
