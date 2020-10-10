import UIKit

public extension Data {
    /// Creates a string from the given Unicode code units in the UTF8 encoding.
    var utf8String: String { String(decoding: self, as: UTF8.self) }
    /// Initializes and returns the image object with the specified data.
    ///
    /// The data must be formatted to match the file format of one of the system’s supported image types.
    var image: UIImage? { UIImage(data: self) }
    /// Returns a Foundation object from given JSON data.
    /// - Parameter options: Options for reading the JSON data and creating the Foundation objects (optional).
    func json(options opt: JSONSerialization.ReadingOptions = []) -> Result<Any, Error> {
        do {
            let json = try JSONSerialization.jsonObject(with: self, options: opt)
            return .success(json)
        } catch {
            return .failure(error)
        }
    }
    /// Decodes an instance of the indicated type.
    /// - Parameters:
    ///   - type: Decoding type.
    ///   - decoder: An object that decodes instances of a data type from JSON objects.
    func decoding<T: Decodable>(type: T.Type, decoder: JSONDecoder = JSONDecoder()) -> Result<T, Error> {
        do {
            let decoded = try T(decoding: self, decoder: decoder)
            return .success(decoded)
        } catch {
            return .failure(error)
        }
    }
}
