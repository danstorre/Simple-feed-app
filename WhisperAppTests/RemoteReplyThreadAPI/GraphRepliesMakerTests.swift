
import XCTest
import WhisperApp

class GraphRepliesMaker {
    let loader: ReplyThreadLoader
    
    init(loader: ReplyThreadLoader) {
        self.loader = loader
    }
}

protocol ReplyThreadLoader {
    func load(repliesFrom: String, completion: @escaping ([RemoteWhisperReply]) -> Void)
}

class GraphRepliesMakerTests: XCTestCase {

    func test_init_doesntRequestAnyReplyWhispers() {
        let service = ReplyThreadLoaderSpy()
        let _ = GraphRepliesMaker(loader: service)
        
        XCTAssertEqual(service.requestedIds, [])
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
