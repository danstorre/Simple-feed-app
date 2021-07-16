
import Foundation
import WhisperApp

class LocalPopularFeedDecorator: PopularFeedLoader {
    private let loader: PopularFeedLoader
    private var whispers: [Whisper] = []
    
    init(loader: PopularFeedLoader) {
        self.loader = loader
    }
    
    func loadPopularFeedLoader(completion: @escaping (ResultPopularLoader) -> Void) {
        guard whispers.isEmpty else {
            completion(.success(whispers))
            return
        }
        
        loader.loadPopularFeedLoader { [weak self] result in
            guard let sSelf = self else { return }
            switch result {
            case let .success(whispers):
                sSelf.whispers = whispers
                completion(.success(whispers))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
}
