
import Foundation

public final class RemoteReplyLoader {
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
        case success([Whisper])
    }
    
    public func load(from id: String, completion: @escaping (Result) -> Void) {
        guard let repliesFromWhisperURL = createWhisperURL(from: id) else {
            return
        }
        
        client.getDataFrom(url: repliesFromWhisperURL, completion: { [weak self] result in
            guard self != nil else { return }
            
            switch result {
            case let .success(response, data):
                completion(RemoteReplyThreadLoaderMapper.map(response: response, data: data))
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
}
