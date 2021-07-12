
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
        
        sut.load(from: whisperId)
        
        let expectedURLs = [URL(string:  "http://a-url.com?wid=\(whisperId)")!]
        
        XCTAssertEqual(client.requestedURLs,
                       expectedURLs)
    }
    
    func test_load_serviceDoesnLoadDataWhenWhisperIDIsEmpty() {
        let emptyWhisperID = ""
        let (sut, client) = makeSUT()
        
        sut.load(from: emptyWhisperID)
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_twice_loadsFromURLTwice() {
        let url = URL(string: "http://a-url.com")!
        let whisperId = "anUUID"
        let (sut, client) = makeSUT(url: url)
        
        sut.load(from: whisperId)
        sut.load(from: whisperId)
        
        let expectedURLs = Array(
            repeating: URL(string: "http://a-url.com?wid=\(whisperId)")!,
            count: 2
        )
        
        XCTAssertEqual(client.requestedURLs,
                       expectedURLs)
    }
    
    // MARK:- Helpers
    
    private func makeSUT(
        url: URL = URL(string: "http://a-url.com")!,
        client: HTTPClientSpy = HTTPClientSpy()
    ) -> (RemoteReplyThreadLoader, HTTPClientSpy) {
        (RemoteReplyThreadLoader(url: url, client: client), client)
    }
    
    private class HTTPClientSpy: HTTPClient {
        var messages: [URL] = [URL]()
        
        var requestedURLs: [URL] {
            return messages.map { $0 }
        }
        
        func getDataFrom(url: URL) {
            messages.append(url)
        }
    }
}
