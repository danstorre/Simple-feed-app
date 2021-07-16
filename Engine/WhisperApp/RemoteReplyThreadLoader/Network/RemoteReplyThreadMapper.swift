import Foundation

internal final class RemoteReplyThreadLoaderMapper {
    private struct RemoteWhisperReplyRoot: Decodable {
        let replies: [RemoteWhisperReply]
        
        var items: [Whisper] {
            replies.map { $0.whisper}
        }
        
        enum CodingKeys: String, CodingKey {
            case replies
        }
    }
    
    static func map(response: HTTPURLResponse, data: Data) -> RemoteReplyLoader.Result {
        guard response.statusCode == 200,
              let root = try? JSONDecoder().decode(RemoteWhisperReplyRoot.self, from: data) else {
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
