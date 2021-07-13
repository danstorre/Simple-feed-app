
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
        var capturedError = [RemoteReplyThreadLoader.Result]()
        loadWith(sut: sut) { result in
            capturedError.append(result)
        }
        
        let clientError = NSError(domain: "client error", code: 1, userInfo: nil)
        client.completeWith(error: clientError)
        
        XCTAssertEqual(capturedError, [.failure(.connectivityError)])
    }
    
    func test_load_deliversInvalidDataOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        
        let samples = [199,201,300,400,500]
        
        samples.enumerated().forEach { [weak self] index, code in
            var capturedResult = [RemoteReplyThreadLoader.Result]()
            
            self?.loadWith(sut: sut) { result in
                capturedResult.append(result)
            }
            
            client.completeWith(code: code, at: index)
            
            XCTAssertEqual(capturedResult, [.failure(.invalidData)])
        }
    }
    
    // MARK:- Helpers
    private func makeSUT(
        url: URL = URL(string: "http://a-url.com")!,
        client: HTTPClientSpy = HTTPClientSpy()
    ) -> (RemoteReplyThreadLoader, HTTPClientSpy) {
        (RemoteReplyThreadLoader(url: url, client: client), client)
    }
    
    private func loadWith(id whisperId: String = "whisperID",
                          sut: RemoteReplyThreadLoader,
                          completion: @escaping (RemoteReplyThreadLoader.Result) -> Void) {
        sut.load(from: whisperId, completion: completion)
    }
    
    private class HTTPClientSpy: HTTPClient {
        var messages: [(url: URL, completion: (HTTPClientResult) -> Void)] = []
        
        var requestedURLs: [URL] {
            return messages.map { $0.url }
        }
        
        func getDataFrom(url: URL, completion: @escaping (HTTPClientResult) -> Void) {
            messages.append((url, completion))
        }
        
        func completeWith(error: NSError, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        func completeWith(code: Int, at index: Int = 0) {
            let httpResponse = HTTPURLResponse(url: messages[index].url,
                                               statusCode: code,
                                               httpVersion: nil,
                                               headerFields: nil)!
            messages[index].completion(.success(httpResponse))
        }
    }
}
