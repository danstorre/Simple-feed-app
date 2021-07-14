
import Foundation

public struct Whisper: Equatable {
    private let description: String
    private let heartCount: Int
    private let replyCount: Int
    private let image: URL
    private let wildCardID: String
    
    public init(description: String, heartCount: Int, replyCount: Int, image: URL, wildCardID: String) {
        self.description = description
        self.heartCount = heartCount
        self.replyCount = replyCount
        self.image = image
        self.wildCardID = wildCardID
    }
}
