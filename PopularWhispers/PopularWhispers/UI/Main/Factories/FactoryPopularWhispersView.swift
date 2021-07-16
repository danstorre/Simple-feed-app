
import Foundation
import WhisperApp
import SwiftUI

enum FactoryPopularWhisperFeedView {
    static func create() -> WhisperListView {
        let popularRepliesVM: PopularWhisperFeedVM = PopularWhisperFeedVM(loader: FactoryPopularWhisperFeedLoader.create())
        let whisperListAdapter = AdapterWhisperList(loader: popularRepliesVM, handler: { _ in })
        
        return WhisperListView(title: "Popular Whispers",
                               viewModel: whisperListAdapter)
    }
    
    static func create(selection: @escaping (WhisperListView) -> Void ) -> WhisperListView {
        let popularRepliesVM: PopularWhisperFeedVM = PopularWhisperFeedVM(loader: FactoryPopularWhisperFeedLoader.create())
        let coordinator = WhisperCoordinator(loader: FactoryPopularWhisperFeedLoader.create())
        
        let whisperListAdapter = AdapterWhisperList(loader: popularRepliesVM, handler: { selectedId in
            coordinator.navigateToDetailsFrom(id: selectedId,
                                              completion: selection)
        })
        
        return WhisperListView(title: "Popular Whispers",
                               viewModel: whisperListAdapter)
    }
}

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
