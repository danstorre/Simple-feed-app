
import Foundation

public enum ReplyThreadLoaderResult {
    case success([RemoteWhisperReply])
    case failure(Error)
}

public protocol ReplyThreadLoader {
    func load(repliesFrom: String, completion: @escaping (ReplyThreadLoaderResult) -> Void)
}
