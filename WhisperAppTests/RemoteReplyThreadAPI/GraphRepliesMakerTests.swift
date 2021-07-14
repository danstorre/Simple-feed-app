
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
                        when completionBlock: @escaping () -> Void) {
        let whisper = createWhisper()
        var capturedResults = [GraphRepliesMaker.Result]()
        
        sut.createGraphFrom(whisper: whisper) { result in
            capturedResults.append(result)
        }
        
        completionBlock()
        
        XCTAssertEqual(capturedResults, [result])
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
    }
}
