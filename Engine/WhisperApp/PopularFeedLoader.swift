
import Foundation

public enum ResultPopularLoader {
    case success([Whisper])
    case failure(Error)
}

public protocol PopularFeedLoader {
    func loadPopularFeedLoader(completion: @escaping (ResultPopularLoader) -> Void)
}
