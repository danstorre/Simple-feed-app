
import XCTest

class RemoteReplyThreadLoader {
    let url: URL
    let client: HTTPClient
    
    init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
}

protocol HTTPClient {
    func getDataFrom(url: URL)
}

class RemoteReplyThreadLoaderTests: XCTestCase {
    
    func test_init_DoesntRequestData() {
        let url = URL(string: "http://a-url.com")!
        let client = HTTPClientSpy()
        let _ = RemoteReplyThreadLoader(url: url, client: client)
        
        XCTAssertNil(client.requestedURL)
    }
    
    private class HTTPClientSpy: HTTPClient {
        var requestedURL: URL?
        
        func getDataFrom(url: URL) {
            requestedURL = url
        }
    }
}
