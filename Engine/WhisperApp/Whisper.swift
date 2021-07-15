
import Foundation

public struct Whisper: Equatable {
    public let description: String
    public let heartCount: Int
    public let replyCount: Int
    public let image: URL
    public let wildCardID: String
    
    public var replies: [Whisper]?
    
    public init(description: String, heartCount: Int, replyCount: Int, image: URL, wildCardID: String, replies: [Whisper]? = nil) {
        self.description = description
        self.heartCount = heartCount
        self.replyCount = replyCount
        self.image = image
        self.wildCardID = wildCardID
        self.replies = replies
    }
}
