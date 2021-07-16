
import Foundation
import WhisperApp

enum FactoryPopularThreadView {
    private static let aWhisper = Whisper(description: "1",
                                          heartCount: 1,
                                          replyCount: 1,
                                          image: URL(string: "http://a-url.com")!,
                                          wildCardID: "05c6f4b2e1123a3b427cf57c25ce26be41a789")
    
    static func create(from whisper: Whisper = FactoryPopularThreadView.aWhisper) -> WhisperListView {
        let popularRepliesVM: PopularReplyThreadVM = PopularReplyThreadVM(loader: FactoryPopularReplyThreadLoader.create(),
                                                                          whisper: whisper)
        let whisperListAdapter = AdapterWhisperList(loader: popularRepliesVM, handler: { _ in })
        
        return WhisperListView(title: "Popular Reply Thread",
                                        viewModel: whisperListAdapter)
    }
}
