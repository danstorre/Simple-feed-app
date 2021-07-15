
import Foundation

public enum ResultReplyThread {
    case success([Whisper])
    case failure(Error)
}

public protocol PopularReplyThreadLoader {
    func loadPopularReplyThread(from: Whisper,
                                completion: @escaping (ResultReplyThread) -> Void)
}
