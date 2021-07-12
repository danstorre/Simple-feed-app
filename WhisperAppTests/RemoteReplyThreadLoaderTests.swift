
import XCTest
import WhisperApp

class RemoteReplyThreadLoaderTests: XCTestCase {
    
    func test_init_doesntRequestData() {
        let (_, client) = makeSUT()
        
        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_serviceLoadsDataUsingAnWhisperID() {
        let url = URL(string: "http://a-url.com")!
        let whisperId = "anUUID"
        let (sut, client) = makeSUT(url: url)
        
        sut.load(from: whisperId)
        
        XCTAssertEqual(client.requestedURL?.absoluteString,
                       "http://a-url.com?wid=\(whisperId)")
    }
    
    // MARK:- Helpers
    
    private func makeSUT(
        url: URL = URL(string: "http://a-url.com")!,
        client: HTTPClientSpy = HTTPClientSpy()
    ) -> (RemoteReplyThreadLoader, HTTPClientSpy) {
        (RemoteReplyThreadLoader(url: url, client: client), client)
    }
    
    private class HTTPClientSpy: HTTPClient {
        var requestedURL: URL?
        
        func getDataFrom(url: URL) {
            requestedURL = url
        }
    }
}
