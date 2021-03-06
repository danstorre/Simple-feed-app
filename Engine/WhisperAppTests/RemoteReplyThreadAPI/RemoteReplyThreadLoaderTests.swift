
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
        
        expect(result: .failure(.connectivityError), from: sut, when: {
            let clientError = NSError(domain: "client error", code: 1, userInfo: nil)
            client.completeWith(error: clientError)
        })
    }
    
    func test_load_deliversInvalidDataOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        
        let samples = [199,201,300,400,500]
        
        samples.enumerated().forEach { index, code in
            expect(result: .failure(.invalidData), from: sut, when: {
                client.completeWith(code: code, data: Data(), at: index)
            })
        }
    }
    
    func test_load_deliversInvalidDataOn200HttpResponseWithInvalidJson() {
        let (sut, client) = makeSUT()
        
        let invalidJSON = String("invalid json").data(using: .utf8)!
        expect(result: .failure(.invalidData), from: sut, when: {
            client.completeWith(code: 200, data: invalidJSON)
        })
    }
    
    func test_load_deliversEmptyItemsOn200HTTPResponseWithEmptyList() throws {
        let (sut, client) = makeSUT()
        
        let emptyListJSON = try createJSON(from: [])
        
        expect(result: .success([]), from: sut) {
            client.completeWith(code: 200, data: emptyListJSON)
        }
    }
    
    func test_load_deliversRepliesOn200HTTPResponseWithValidJSON() throws {
        let (sut, client) = makeSUT()
        
        let whisperReply1 = createWhisper(id: "id",
                                         heartCount: 2,
                                         replies: 2,
                                         text: "a text",
                                         imageURL: URL(string: "http://a-URL-1.com")!)
        
        let whisperReply2 = createWhisper(id: "id2",
                                          heartCount: 4,
                                          replies: 4,
                                          text: "a second text",
                                          imageURL: URL(string: "http://a-URL-2.com")!)
        
        let whisperReplies = [whisperReply1, whisperReply2]
        let jsonReplies = whisperReplies.map(createJSONObjectFrom)
        
        let json = try createJSON(from: jsonReplies)
    
        expect(result: .success(whisperReplies), from: sut) {
            client.completeWith(code: 200, data: json)
        }
    }
    
    func test_load_doesntDeliverRepliesWhenDeallocated() throws {
        let url = URL(string: "http://a-url.com")!
        let client = HTTPClientSpy()
        var sut: RemoteReplyLoader? = RemoteReplyLoader(url: url,
                                                                    client: client)
        
        var capturedResults = [RemoteReplyLoader.Result]()
        
        sut?.load(from: "anWhisperID",
                  completion: { result in
            capturedResults.append(result)
        })
        
        sut = nil
        
        let json = try createJSON(from: [])
        client.completeWith(code: 200, data: json)
        
        XCTAssertTrue(capturedResults.isEmpty)
    }
    
    // MARK:- Helpers
    private func createWhisper(
        id: String,
        heartCount: Int,
        replies: Int,
        text: String,
        imageURL: URL
    ) -> Whisper {
        Whisper(description: text,
                heartCount: heartCount,
                replyCount: replies,
                image: imageURL,
                wildCardID: id)
    }

    private func createJSONObjectFrom(whisper: Whisper) -> [String: Any] {
        [
            "wid": whisper.wildCardID,
            "me2": whisper.heartCount,
            "replies": whisper.replyCount,
            "text": whisper.description,
            "url": whisper.image.absoluteString
        ].compactMapValues { $0 }
    }
    
    private func createJSON(from replies: [[String: Any]]) throws -> Data {
        let dict = ["replies": replies]
        
        return try JSONSerialization.data(withJSONObject: dict)
    }
    
    private func expect(
        result: RemoteReplyLoader.Result,
        from sut: RemoteReplyLoader,
        when completion: () -> Void,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        var capturedResults = [RemoteReplyLoader.Result]()
        
        loadWith(sut: sut) { result in
            capturedResults.append(result)
        }
        
        completion()
        
        XCTAssertEqual(capturedResults, [result], file: file,
                       line: line)
    }
    
    private func makeSUT(
        url: URL = URL(string: "http://a-url.com")!,
        client: HTTPClientSpy = HTTPClientSpy()
    ) -> (RemoteReplyLoader, HTTPClientSpy) {
        let sut = RemoteReplyLoader(url: url, client: client)
        
        checkForMemoryLeak(instance: sut)
        checkForMemoryLeak(instance: client)
        
        return (sut, client)
    }
    
    private func checkForMemoryLeak(instance: AnyObject) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "instance should be deallocated potential memory leak")
        }
    }
    
    private func loadWith(id whisperId: String = "whisperID",
                          sut: RemoteReplyLoader,
                          completion: @escaping (RemoteReplyLoader.Result) -> Void) {
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
        
        func completeWith(code: Int, data: Data, at index: Int = 0) {
            let httpResponse = HTTPURLResponse(url: messages[index].url,
                                               statusCode: code,
                                               httpVersion: nil,
                                               headerFields: nil)!
            messages[index].completion(.success(httpResponse, data))
        }
    }
}
