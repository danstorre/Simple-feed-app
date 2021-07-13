
import Foundation

public struct RemoteWhisperReply: Equatable, Decodable {
    public let id: String
    public let heartCount: Int
    public let replies: Int
    public let text: String
    public let imageURL: URL
    
    enum CodingKeys: String, CodingKey {
        case id = "wid"
        case heartCount = "me2"
        case replies
        case text
        case imageURL = "url"
    }
    
    public init(id: String, heartCount: Int, replies: Int, text: String, imageURL: URL) {
        self.id = id
        self.heartCount = heartCount
        self.replies = replies
        self.text = text
        self.imageURL = imageURL
    }
}

public class RemoteReplyThreadLoader {
    private let url: URL
    private let client: HTTPClient
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public enum Error: Swift.Error, Equatable {
        case connectivityError
        case invalidData
    }
    
    public enum Result: Equatable {
        case failure(Error)
        case success([RemoteWhisperReply])
    }
    
    public func load(from id: String, completion: @escaping (Result) -> Void) {
        guard let repliesFromWhisperURL = createWhisperURL(from: id) else {
            return
        }
        
        client.getDataFrom(url: repliesFromWhisperURL, completion: { result in
            switch result {
            case let .success(response, data):
                guard response.statusCode == 200,
                      let root = try? JSONDecoder().decode(RemoteWhisperReplyRoot.self, from: data) else {
                    completion(.failure(.invalidData))
                    return
                }
                
                completion(.success(root.replies))
            case .failure:
                completion(.failure(.connectivityError))
            }
        })
    }
    
    private func createWhisperURL(from id: String) -> URL? {
        guard isValid(id: id) else {
            return nil
        }
        
        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let queryWhisperID = URLQueryItem(name: "wid", value: id)
        
        urlComponents?.queryItems = [queryWhisperID]
        
        return urlComponents?.url
    }
    
    private func isValid(id: String) -> Bool {
        !id.isEmpty
    }
    
    private struct RemoteWhisperReplyRoot: Decodable {
        let replies: [RemoteWhisperReply]
        
        enum CodingKeys: String, CodingKey {
            case replies
        }
    }
}
