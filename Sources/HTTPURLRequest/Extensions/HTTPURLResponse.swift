import Foundation

extension HTTPURLResponse {
    var localizedStatusCode: String {
        let statusCode = self.statusCode
        let localizedString = HTTPURLResponse.localizedString(forStatusCode: statusCode)
        return "\(statusCode) - \(localizedString)"
    }
}
