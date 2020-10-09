import Foundation

public extension Result {
    var success: Success? { self.output.success }
    var failure: Failure? { self.output.failure }
    private var output: (success: Success?, failure: Failure?) {
        switch self {
        case let .success(result):
            return (result, nil)
        case let .failure(error):
            return (nil, error)
        }
    }
}
