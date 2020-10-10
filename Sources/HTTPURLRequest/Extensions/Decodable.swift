import Foundation

public extension Decodable {
    /// Decodes an instance of the indicated type.
    /// - Parameters:
    ///   - data: Decoding data.
    ///   - decoder: An object that decodes instances of a data type from JSON objects.
    init(decoding data: Data, decoder: JSONDecoder = JSONDecoder()) throws {
        self = try decoder.decode(Self.self, from: data)
    }
}
