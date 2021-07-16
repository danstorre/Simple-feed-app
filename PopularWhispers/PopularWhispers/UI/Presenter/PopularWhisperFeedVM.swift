
import Foundation
import WhisperApp

class PopularWhisperFeedVM: WhisperPresenter {
    private let loader: PopularFeedLoader
    
    init(loader: PopularFeedLoader) {
        self.loader = loader
    }
    
    func loadItems(completion: @escaping ([WhisperPresentableData]) -> Void) {
        loader.loadPopularFeedLoader() { result in 
            switch result {
            case let .success(replies):
                let replies = replies.map {
                    WhisperPresentableData(description: $0.description,
                                           heartCount: String($0.heartCount),
                                           image: nil,
                                           id: $0.wildCardID)
                }
                
                completion(replies)
            case let .failure(error):
                print(error.localizedDescription)
                completion([])
            }
        }
    }
}
