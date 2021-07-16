
import Foundation

public final class RemotePopularFeedLoader {
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
    
    public func load(completion: @escaping (Result) -> Void) {
        client.getDataFrom(url: url, completion: { [weak self] result in
            guard self != nil else { return }
            
            switch result {
            case let .success(response, data):
                completion(RemotePopularFeedLoaderMapper.map(response: response, data: data))
            case .failure:
                completion(.failure(.connectivityError))
            }
        })
    }
}
