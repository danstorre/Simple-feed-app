
import Foundation

public enum HTTPClientResult {
    case success(HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient {
    func getDataFrom(url: URL, completion: @escaping (HTTPClientResult) -> Void)
}
