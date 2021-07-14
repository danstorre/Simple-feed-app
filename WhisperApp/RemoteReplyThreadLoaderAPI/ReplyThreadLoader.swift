
import Foundation

public enum ReplyThreadLoaderError {
    case connectivityError
    case invalidData
}

public enum ReplyThreadLoaderResult {
    case success([RemoteWhisperReply])
    case failure(ReplyThreadLoaderError)
}

public protocol ReplyThreadLoader {
    func load(repliesFrom: String, completion: @escaping (ReplyThreadLoaderResult) -> Void)
}
