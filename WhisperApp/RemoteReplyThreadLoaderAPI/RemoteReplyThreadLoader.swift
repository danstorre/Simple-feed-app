
import Foundation

public class RemoteReplyThreadLoader {
    private let url: URL
    private let client: HTTPClient
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load(from id: String) {
        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let queryWhisperID = URLQueryItem(name: "wid", value: id)
        
        urlComponents?.queryItems = [queryWhisperID]
        
        if let repliesFromWhisperURL = urlComponents?.url {
            client.getDataFrom(url: repliesFromWhisperURL)
        }
    }
}
