
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
        
        let whisperResultRoot = NodeWhisper(whisper: whisperRoot)
        whisperResultRoot.replies = [NodeWhisper(whisper: whisperReply1), NodeWhisper(whisper: whisperReply2)]
        

        expect(result: .success(whisperResultRoot), from: sut, and: whisperRoot, when: {
            loader.completesWith(whispers: [whisperReply1, whisperReply2])
            loader.completesWith(whispers: [])
            loader.completesWith(whispers: [])
        })
    }
    
    func test_createGraph_deliversCompleteGraphWhenRepliesHaveReplies() {
        let (sut, loader) = makeSUT()

        let whisperReply1a = createWhisper(wildCardID: "1-a")
        let whisperReply1b = createWhisper(wildCardID: "1-b")

        let whisperReply1 = createWhisper(wildCardID: "1")
        
        let whisperNode1 = NodeWhisper(whisper: whisperReply1,
                                       replies: [whisperReply1a, whisperReply1b])

        let whisperReply2a = createWhisper(wildCardID: "2-a")
        let whisperReply2b = createWhisper(wildCardID: "2-b")

        let whisperReply2 = createWhisper(wildCardID: "2")
        let whisperNode2 = NodeWhisper(whisper: whisperReply2,
                                       replies: [whisperReply2a, whisperReply2b])
        
        let whisperRoot = createWhisper(wildCardID: "0")
        let whisperRootResult = NodeWhisper(whisper: whisperRoot)
        whisperRootResult.replies = [whisperNode1, whisperNode2]

        expect(result: .success(whisperRootResult), from: sut, and: whisperRoot, when: {
            loader.completesWith(whispers: [whisperReply1, whisperReply2])
            loader.completesWith(whispers: [whisperReply1a, whisperReply1b])
            loader.completesWith(whispers: [whisperReply2a, whisperReply2b])
            loader.completesWith(whispers: [])
            loader.completesWith(whispers: [])
            loader.completesWith(whispers: [])
            loader.completesWith(whispers: [])
        })
    }
    
    func test_createGraph_doesntDeliverResultWhenDeallocated() {
        let loader = ReplyThreadLoaderSpy()
        var sut: GraphRepliesMaker? = GraphRepliesMaker(loader: loader)
        
        var capturedResults = [GraphRepliesMaker.Result]()
        sut?.createGraphFrom(
            whisper: createWhisper(),
            completion: { result in
                capturedResults.append(result)
            })
        
        sut = nil
        
        loader.completeWith(error: .connectivityError)
        
        XCTAssertTrue(capturedResults.isEmpty)
    }
    
    // MARK: - helpers
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
    
    private func makeSUT(file: StaticString = #filePath,
                         line: UInt = #line) -> (sut: GraphRepliesMaker,
                               loader: ReplyThreadLoaderSpy) {
        let loader = ReplyThreadLoaderSpy()
        let sut = GraphRepliesMaker(loader: loader)
        
        checkMemoryLeak(on: loader, file: file, line: line)
        checkMemoryLeak(on: sut, file: file, line: line)
        
        return (sut, loader)
    }
    
    private func checkMemoryLeak(on instance: AnyObject,
                                 file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "instance should be nil - potential memory leak.",
                         file: file, line: line)
        }
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
