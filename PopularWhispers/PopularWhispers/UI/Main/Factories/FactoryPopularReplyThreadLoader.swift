
import Foundation
import WhisperApp

enum FactoryPopularReplyThreadLoader {
    static func create() -> PopularReplyThreadLoader {
        let prodUrL = URL(string: "http://prod.whisper.sh/whispers/replies")!
        return ReplyThreadLoaderAdapter(remoteReplyFromWhisperAPI: RemoteReplyLoaderAdapter(remote: RemoteReplyLoader(url: prodUrL, client: URLSession.shared)))
    }
}
