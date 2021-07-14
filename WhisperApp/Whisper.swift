
import Foundation

public struct Whisper: Equatable {
    private let description: String
    private let heartCount: Int
    private let replyCount: Int
    private let image: URL
    private let wildCardID: String
    
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
