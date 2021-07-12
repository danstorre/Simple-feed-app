
import XCTest
import WhisperApp

class RemoteReplyThreadLoaderTests: XCTestCase {
    
    func test_init_DoesntRequestData() {
        let url = URL(string: "http://a-url.com")!
        let client = HTTPClientSpy()
        let _ = RemoteReplyThreadLoader(url: url, client: client)
        
        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_serviceLoadsDataUsingAnWhisperID() {
        let url = URL(string: "http://a-url.com")!
        let whisperId = "anUUID"
        let client = HTTPClientSpy()
        let sut = RemoteReplyThreadLoader(url: url, client: client)
        
        sut.load(from: whisperId)
        
        XCTAssertEqual(client.requestedURL?.absoluteString,
                       "http://a-url.com?wid=\(whisperId)")
    }
    
    // MARK:- Helpers
    
    private class HTTPClientSpy: HTTPClient {
        var requestedURL: URL?
        
        func getDataFrom(url: URL) {
            requestedURL = url
        }
    }
}
