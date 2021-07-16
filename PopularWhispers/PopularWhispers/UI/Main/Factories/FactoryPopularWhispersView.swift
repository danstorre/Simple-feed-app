
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
        let loader = FactoryPopularWhisperFeedLoader.create()
        let popularRepliesVM: PopularWhisperFeedVM = PopularWhisperFeedVM(loader: loader)
        let coordinator = WhisperCoordinator(loader: loader)
        
        let whisperListAdapter = AdapterWhisperList(loader: popularRepliesVM, handler: { selectedId in
            coordinator.navigateToDetailsFrom(id: selectedId,
                                              completion: selection)
        })
        
        return WhisperListView(title: "Popular Whispers",
                               viewModel: whisperListAdapter)
    }
}
