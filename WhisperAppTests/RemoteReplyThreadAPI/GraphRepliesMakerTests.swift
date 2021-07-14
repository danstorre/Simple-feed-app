
import XCTest
import WhisperApp

class GraphRepliesMakerTests: XCTestCase {

    func test_init_doesntRequestAnyReplyWhispers() {
        let loader = ReplyThreadLoaderSpy()
        let _ = GraphRepliesMaker(loader: loader)
        
        XCTAssertEqual(loader.requestedIds, [])
    }
    
    func test_createGraph_loadsRepliesFromGivenWhisperId() {
        let (sut, loader) = makeSUT()
        
        let whisper = createWhisper(wildCardID: "ID")
        sut.createGraphFrom(whisper: whisper)
        
        XCTAssertEqual(loader.requestedIds, [whisper.wildCardID])
    }
    
    func test_createGraph_deliversConnectivityErrorWhenLoaderFailsWithConnectivityError() {
        let (sut, loader) = makeSUT()
        
        expect(result: .failure(.connectivityError), from: sut, when: {
            loader.completeWith(error: .connectivityError)
        })
    }
    
    func test_createGraph_deliversInvalidDataWhenLoaderFailsWithInvalidData() {
        let (sut, loader) = makeSUT()
        
        expect(result: .failure(.invalidData), from: sut, when: {
            loader.completeWith(error: .invalidData)
        })
    }
    
    func test_createGraph_deliversCompleteGraphWhenRepliesDontHaveReplies() {
        let (sut, loader) = makeSUT()

        let whisperReply1 = createWhisper(wildCardID: "1")

        let whisperReply2 = createWhisper(wildCardID: "2")

        let whisperRoot = createWhisper(wildCardID: "0")
        
        let whisperResult = Whisper(description: whisperRoot.description,
                                    heartCount: whisperRoot.heartCount,
                                    replyCount: whisperRoot.replyCount,
                                    image: whisperRoot.image,
                                    wildCardID: whisperRoot.wildCardID,
                                    replies: [whisperReply1, whisperReply2])

        expect(result: .success(whisperResult), from: sut, and: whisperRoot, when: {
            loader.completesWith(whispers: [whisperReply1, whisperReply2])
        })
    }
    
    // MARK: - helpers
    private func createWhisper(
        description: String = "a whisper description",
        heartCount: Int = 2,
        replyCount: Int = 4,
        image: URL = URL(string: "http://a-url.com")!,
        wildCardID: String = "1"
    ) -> Whisper {
        Whisper(description: "a whisper description",
                heartCount: 2,
                replyCount: 4,
                image: URL(string: "http://a-url.com")!,
                wildCardID: "1")
    }
    
    private func expect(result: GraphRepliesMaker.Result,
                        from sut: GraphRepliesMaker,
                        and whisper: Whisper = Whisper(description: "a whisper description",
                                                       heartCount: 2,
                                                       replyCount: 4,
                                                       image: URL(string: "http://a-url.com")!,
                                                       wildCardID: "1"),
                        when completionBlock: @escaping () -> Void,
                        file: StaticString = #filePath, line: UInt = #line) {
        var capturedResults = [GraphRepliesMaker.Result]()
        
        sut.createGraphFrom(whisper: whisper) { result in
            capturedResults.append(result)
        }
        
        completionBlock()
        
        XCTAssertEqual(capturedResults, [result], file: file, line: line)
    }
    
    private func makeSUT() -> (sut: GraphRepliesMaker,
                               loader: ReplyThreadLoaderSpy) {
        let loader = ReplyThreadLoaderSpy()
        let sut = GraphRepliesMaker(loader: loader)
        return (sut, loader)
    }
    
    private class ReplyThreadLoaderSpy: ReplyThreadLoader {
        var messages: [(id: String, completion: (ReplyThreadLoaderResult) -> Void)] = []
        
        var requestedIds: [String] {
            messages.map { $0.id }
        }
        
        func load(repliesFrom id: String, completion: @escaping (ReplyThreadLoaderResult) -> Void) {
            messages.append((id, completion))
        }
        
        func completeWith(error: ReplyThreadLoaderError, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        func completesWith(whispers: [Whisper], at index: Int = 0) {
            messages[index].completion(.success(whispers))
        }
    }
}
