
import Foundation
import WhisperApp

enum FactoryPopularWhisperFeedLoader {
    static func create() -> PopularFeedLoader {
        let prodUrL = URL(string: "http://prod.whisper.sh/whispers/popular?limit=200")!
        return RemotePopularFeedAdapter(remotePopularFeedLoaderAPI: RemotePopularFeedLoader(url: prodUrL, client: URLSession.shared))
    }
}
