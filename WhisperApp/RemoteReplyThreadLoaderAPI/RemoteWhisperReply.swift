
import Foundation

public struct RemoteWhisperReply: Equatable, Decodable {
    public let id: String
    public let heartCount: Int
    public let replies: Int
    public let text: String
    public let imageURL: URL
    
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
