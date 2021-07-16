
import Foundation

enum FactoryPopularWhisperFeedView {
    static func create() -> WhisperListView {
        let popularRepliesVM: PopularWhisperFeedVM = PopularWhisperFeedVM(loader: FactoryPopularWhisperFeedLoader.create())
        let whisperListAdapter = AdapterWhisperList(loader: popularRepliesVM, handler: { _ in })
        
        return WhisperListView(title: "Popular Whispers",
                               viewModel: whisperListAdapter)
    }
}
