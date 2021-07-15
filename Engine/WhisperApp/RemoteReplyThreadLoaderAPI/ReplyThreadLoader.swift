
import Foundation

public enum ReplyThreadLoaderError {
    case connectivityError
    case invalidData
}

public enum ReplyThreadLoaderResult {
    case success([Whisper])
    case failure(ReplyThreadLoaderError)
}

public protocol ReplyThreadLoader {
    func load(repliesFrom: String, completion: @escaping (ReplyThreadLoaderResult) -> Void)
}
