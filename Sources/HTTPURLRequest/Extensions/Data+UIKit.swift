#if(!macOS)
import UIKit

public extension Data {
    /// Initializes and returns the image object with the specified data.
    ///
    /// The data must be formatted to match the file format of one of the system’s supported image types.
    var image: UIImage? { UIImage(data: self) }
    
    
}
#endif
