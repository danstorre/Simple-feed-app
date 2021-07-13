
import XCTest
import WhisperApp

class GraphRepliesMakerTests: XCTestCase {

    func test_init_doesntRequestAnyReplyWhispers() {
        let loader = ReplyThreadLoaderSpy()
        let _ = GraphRepliesMaker(loader: loader)
        
        XCTAssertEqual(loader.requestedIds, [])
    }
    
    func test_createGraph_requestsRepliesFromGivenWhisperId() {
        let (sut, loader) = makeSUT()
        
        let whisperID = "anID"
        sut.createGraphFrom(whisperID: whisperID)
        
        XCTAssertEqual(loader.requestedIds, [whisperID])
    }
    
    // MARK: - helpers
    private func makeSUT() -> (sut: GraphRepliesMaker,
                               loader: ReplyThreadLoaderSpy) {
        let loader = ReplyThreadLoaderSpy()
        let sut = GraphRepliesMaker(loader: loader)
        return (sut, loader)
    }
    
    private class ReplyThreadLoaderSpy: ReplyThreadLoader {
        var messages: [(id: String, completion: ([RemoteWhisperReply]) -> Void)] = []
        
        var requestedIds: [String] {
            messages.map { $0.id }
        }
        
        func load(repliesFrom id: String, completion: @escaping ([RemoteWhisperReply]) -> Void) {
            messages.append((id, completion))
        }
    }
}
