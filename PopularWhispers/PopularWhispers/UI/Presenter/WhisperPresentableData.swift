
import Foundation
import WhisperApp

struct WhisperPresentableData: Identifiable {
    let description: String
    let heartCount: String
    let image: Data?
    let id: String
}

class PopularWhisperVM: ObservableObject {
    private let whisper: Whisper
    private let loader: PopularReplyThreadLoader
    @Published var replies: [WhisperPresentableData] = []
    
    init(loader: PopularReplyThreadLoader, whisper: Whisper) {
        self.loader = loader
        self.whisper = whisper
    }
    
    func loadPopularThread() {
        loader.loadPopularReplyThread(from: whisper) { result in
            switch result {
            case let .success(replies):
                self.replies = replies.map {
                    WhisperPresentableData(description: $0.description,
                                           heartCount: String($0.heartCount),
                                           image: nil,
                                           id: $0.wildCardID)
                }
            case let .failure(error):
                print(error.localizedDescription)
            }
        }
    }
}
