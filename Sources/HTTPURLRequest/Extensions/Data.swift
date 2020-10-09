import UIKit

public extension Data {
    var utf8String: String { String(decoding: self, as: UTF8.self) }
    var image: UIImage? { UIImage(data: self) }
    func json(options opt: JSONSerialization.ReadingOptions = []) -> Result<Any, Error> {
        do {
            let json = try JSONSerialization.jsonObject(with: self, options: opt)
            return .success(json)
        } catch {
            return .failure(error)
        }
    }
    func decoding<T: Decodable>(type: T.Type, decoder: JSONDecoder = JSONDecoder()) -> Result<T, Error> {
        do {
            let decoded = try T(decoding: self, decoder: decoder)
            return .success(decoded)
        } catch {
            return .failure(error)
        }
    }
}
