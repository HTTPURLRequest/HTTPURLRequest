import Foundation

public extension Result {
    /// A Success value.
    var success: Success? { self.output.success }
    /// A Failure value.
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
