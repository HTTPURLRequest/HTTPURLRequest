import Foundation

public extension Result {
    var output: (success: Success?, failure: Failure?) {
        switch self {
        case let .success(result):
            return (result, nil)
        case let .failure(error):
            return (nil, error)
        }
    }
}
