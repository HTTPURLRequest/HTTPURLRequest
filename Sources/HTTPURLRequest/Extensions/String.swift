import Foundation

public extension String {
    /// Creates a URL instance from the provided string.
    var url: URL? { URL(string: self) }
}
