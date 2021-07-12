
import Foundation

enum ResultReplyThread {
    case success([Whisper])
    case failure(Error)
}

protocol PopularReplyThreadLoader {
    func loadPopularReplyThread(from: Whisper,
                                completion: @escaping (ResultReplyThread) -> Void)
}
