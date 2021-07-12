
import XCTest
import WhisperApp

class RemoteReplyThreadLoaderTests: XCTestCase {
    
    func test_init_DoesntRequestData() {
        let url = URL(string: "http://a-url.com")!
        let client = HTTPClientSpy()
        let _ = RemoteReplyThreadLoader(url: url, client: client)
        
        XCTAssertNil(client.requestedURL)
    }
    
    // MARK:- Helpers
    
    private class HTTPClientSpy: HTTPClient {
        var requestedURL: URL?
        
        func getDataFrom(url: URL) {
            requestedURL = url
        }
    }
}
