
import Foundation

public protocol ReplyThreadLoader {
    func load(repliesFrom: String, completion: @escaping ([RemoteWhisperReply]) -> Void)
}
