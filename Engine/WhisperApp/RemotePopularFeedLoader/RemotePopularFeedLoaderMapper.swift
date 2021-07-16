
import Foundation

internal final class RemotePopularFeedLoaderMapper {
    private struct RemoteWhisperPopularRoot: Decodable {
        let popular: [RemoteWhisperReply]
        
        var items: [Whisper] {
            popular.map { $0.whisper}
        }
        
        enum CodingKeys: String, CodingKey {
            case popular
        }
    }
    
    static func map(response: HTTPURLResponse, data: Data) -> RemotePopularFeedLoader.Result {
        guard response.statusCode == 200,
              let root = try? JSONDecoder().decode(RemoteWhisperPopularRoot.self, from: data) else {
            return .failure(.invalidData)
        }
        
        return .success(root.items)
    }
    
    private struct RemoteWhisperReply: Equatable, Decodable {
        public let id: String
        public let heartCount: Int
        public let replies: Int
        public let text: String
        public let imageURL: URL
        
        public var whisper: Whisper {
            Whisper(description: text,
                    heartCount: heartCount,
                    replyCount: replies,
                    image: imageURL,
                    wildCardID: id)
        }
        
        enum CodingKeys: String, CodingKey {
            case id = "wid"
            case heartCount = "me2"
            case replies
            case text
            case imageURL = "url"
        }
        
        public init(id: String, heartCount: Int, replies: Int, text: String, imageURL: URL) {
            self.id = id
            self.heartCount = heartCount
            self.replies = replies
            self.text = text
            self.imageURL = imageURL
        }
    }
}
