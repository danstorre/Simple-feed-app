
import Foundation
import WhisperApp

class RemotePopularFeedAdapter: PopularFeedLoader {
    private let remotePopularFeedLoaderAPI: RemotePopularFeedLoader
    
    init(remotePopularFeedLoaderAPI: RemotePopularFeedLoader) {
        self.remotePopularFeedLoaderAPI = remotePopularFeedLoaderAPI
    }
    
    func loadPopularFeedLoader(completion: @escaping (ResultPopularLoader) -> Void) {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            
            self.remotePopularFeedLoaderAPI.load() { result in
                switch result {
                case let .success(popularWhispers):
                    DispatchQueue.main.async {
                        completion(.success(popularWhispers))
                    }
                case let .failure(error):
                    print(error.localizedDescription)
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                }
            }
        }
    }
}
