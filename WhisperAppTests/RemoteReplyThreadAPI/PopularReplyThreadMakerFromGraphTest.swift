
import XCTest
import WhisperApp

class PopularReplyThreadMakerFromGraphTest: XCTestCase {
    
    func test_createTopMostLikedReplyThread_deliversTopMostLikedReplies() {
        let whisperReply1a = createWhisper(heartCount: 1,
                                           wildCardID: "1-a")
        let whisperReply1b = createWhisper(heartCount: 2,
                                           wildCardID: "1-b")

        let whisperReply1 = createWhisper(heartCount: 1,
                                          wildCardID: "1")
        
        let whisperNode1 = NodeWhisper(whisper: whisperReply1,
                                       replies: [whisperReply1a, whisperReply1b])

        let whisperReply2a = createWhisper(heartCount: 2,
                                           wildCardID: "2-a")
        let whisperReply2b = createWhisper(heartCount: 3,
                                           wildCardID: "2-b")

        let whisperReply2 = createWhisper(heartCount: 2,
                                          wildCardID: "2")
        let whisperNode2 = NodeWhisper(whisper: whisperReply2,
                                       replies: [whisperReply2a, whisperReply2b])
        
        let whisperRoot = createWhisper(heartCount: 0,
                                        wildCardID: "0")
        let whisperRootResult = NodeWhisper(whisper: whisperRoot)
        whisperRootResult.replies = [whisperNode1, whisperNode2]
        
        let sut = PopularReplyThreadMakerFromGraph()
        
        let result = sut.createTopMostLikedReplyThread(from: whisperRootResult)
        
        XCTAssertEqual(result, [whisperRoot, whisperReply2, whisperReply2b])
    }
    
    func test_createTopMostLikedReplyThread_deliversTopMostLikedRepliesWhenThereIsNoReplies() {
        let whisperRoot = createWhisper(heartCount: 0,
                                        wildCardID: "0")
        let whisperRootResult = NodeWhisper(whisper: whisperRoot)
        
        let sut = PopularReplyThreadMakerFromGraph()
        
        let result = sut.createTopMostLikedReplyThread(from: whisperRootResult)
        
        XCTAssertEqual(result, [whisperRoot])
    }

    private func createWhisper(
        description: String = "a whisper description",
        heartCount: Int = 2,
        replyCount: Int = 4,
        image: URL = URL(string: "http://a-url.com")!,
        wildCardID: String = "1",
        replies: [Whisper]? = nil
    ) -> Whisper {
        Whisper(description: description,
                heartCount: heartCount,
                replyCount: replyCount,
                image: image,
                wildCardID: wildCardID,
                replies: replies)
    }
}
