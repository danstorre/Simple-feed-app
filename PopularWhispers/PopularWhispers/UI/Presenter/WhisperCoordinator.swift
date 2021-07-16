
import Foundation
import WhisperApp

class WhisperCoordinator {
    private let loader: PopularFeedLoader
    
    init(loader: PopularFeedLoader) {
        self.loader = loader
    }
    
    func navigateToDetailsFrom(id: String, completion: @escaping (WhisperListView) -> Void ) {
        loader.loadPopularFeedLoader { [weak self] result in
            guard self != nil else { return }
            
            switch result {
            case let .success(whispers):
                guard let selectedWhisper = whispers.first(where: { $0.wildCardID == id }) else { return }
                completion(FactoryPopularThreadView.create(from: selectedWhisper))
                
            case .failure(_): break
            }
        }
    }
}
