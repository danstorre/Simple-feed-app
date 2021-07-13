
import Foundation

public protocol HTTPClient {
    func getDataFrom(url: URL, completion: @escaping (Error) -> Void)
}
