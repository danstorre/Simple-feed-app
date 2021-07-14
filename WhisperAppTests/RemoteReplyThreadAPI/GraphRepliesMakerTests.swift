
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
        
        let whisperID = "anID"
        sut.createGraphFrom(whisperID: whisperID)
        
        XCTAssertEqual(loader.requestedIds, [whisperID])
    }
    
    func test_createGraph_deliversConnectivityErrorWhenLoaderFailsWithConnectivityError() {
        let (sut, loader) = makeSUT()
        
        let whisperID = "anID"
        var capturedResults = [GraphRepliesMaker.Result]()
        
        sut.createGraphFrom(whisperID: whisperID) { result in
            capturedResults.append(result)
        }
        
        loader.completeWith(error: .connectivityError)
        
        XCTAssertEqual(capturedResults, [.failure(.connectivityError)])
    }
    
    func test_createGraph_deliversInvalidDataWhenLoaderFailsWithInvalidData() {
        let (sut, loader) = makeSUT()
        
        let whisperID = "anID"
        var capturedResults = [GraphRepliesMaker.Result]()
        
        sut.createGraphFrom(whisperID: whisperID) { result in
            capturedResults.append(result)
        }
        
        loader.completeWith(error: .invalidData)
        
        XCTAssertEqual(capturedResults, [.failure(.invalidData)])
    }
    
    // MARK: - helpers
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
