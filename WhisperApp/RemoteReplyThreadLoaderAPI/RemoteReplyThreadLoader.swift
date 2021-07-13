
import Foundation

public class RemoteReplyThreadLoader {
    private let url: URL
    private let client: HTTPClient
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public enum Error: Swift.Error, Equatable {
        case connectivityError
    }
    
    public func load(from id: String, completion: @escaping (Error) -> Void) {
        guard let repliesFromWhisperURL = createWhisperURL(from: id) else {
            return
        }
        
        client.getDataFrom(url: repliesFromWhisperURL, completion: { error in
            completion(Error.connectivityError)
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
}
