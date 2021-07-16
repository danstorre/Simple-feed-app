
import Foundation
import WhisperApp

enum FactoryPopularWhisperFeedLoader {
    static func create() -> PopularFeedLoader {
        let prodUrL = URL(string: "http://prod.whisper.sh/whispers/popular?limit=200")!
        
        let remote = RemotePopularFeedLoader(url: prodUrL, client: URLSession.shared)
        let remoteAdapter = RemotePopularFeedAdapter(remotePopularFeedLoaderAPI: remote)
        let localDecorator = LocalPopularFeedDecorator(loader: remoteAdapter)
        return localDecorator
    }
}
