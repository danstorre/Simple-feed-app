
import XCTest
import WhisperApp

class RemoteReplyThreadLoaderTests: XCTestCase {
    
    func test_init_doesntRequestData() {
        let (_, client) = makeSUT()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_serviceLoadsDataUsingAnWhisperID() {
        let url = URL(string: "http://a-url.com")!
        let whisperId = "anUUID"
        let (sut, client) = makeSUT(url: url)
        
        sut.load(from: whisperId) { _ in}
        
        let expectedURLs = [URL(string:  "http://a-url.com?wid=\(whisperId)")!]
        
        XCTAssertEqual(client.requestedURLs,
                       expectedURLs)
    }
    
    func test_load_serviceDoesnLoadDataWhenWhisperIDIsEmpty() {
        let emptyWhisperID = ""
        let (sut, client) = makeSUT()
        
        sut.load(from: emptyWhisperID) { _ in}
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_twice_requestsDataFromURLTwice() {
        let url = URL(string: "http://a-url.com")!
        let whisperId = "anUUID"
        let (sut, client) = makeSUT(url: url)
        
        sut.load(from: whisperId) { _ in}
        sut.load(from: whisperId) { _ in}
        
        let expectedURLs = Array(
            repeating: URL(string: "http://a-url.com?wid=\(whisperId)")!,
            count: 2
        )
        
        XCTAssertEqual(client.requestedURLs,
                       expectedURLs)
    }
    
    func test_load_deliversConnectivityErrorOnClientError() {
        let (sut, client) = makeSUT()
        let whisperId = "anUUID"
        
        var capturedError = [RemoteReplyThreadLoader.Error]()
        sut.load(from: whisperId, completion: { error in
            capturedError.append(error)
        })
        
        let clientError = NSError(domain: "client error", code: 1, userInfo: nil)
        client.completeWith(error: clientError)
        
        XCTAssertEqual(capturedError, [.connectivityError])
    }
    
    // MARK:- Helpers
    
    private func makeSUT(
        url: URL = URL(string: "http://a-url.com")!,
        client: HTTPClientSpy = HTTPClientSpy()
    ) -> (RemoteReplyThreadLoader, HTTPClientSpy) {
        (RemoteReplyThreadLoader(url: url, client: client), client)
    }
    
    private class HTTPClientSpy: HTTPClient {
        var messages: [(url: URL, completion: (Error) -> Void)] = []
        
        var requestedURLs: [URL] {
            return messages.map { $0.url }
        }
        
        func getDataFrom(url: URL, completion: @escaping (Error) -> Void) {
            messages.append((url, completion))
        }
        
        func completeWith(error: NSError, at index: Int = 0) {
            messages[index].completion(error)
        }
    }
}
