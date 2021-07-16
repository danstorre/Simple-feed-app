
import Foundation
import WhisperApp

class PopularReplyThreadVM {
    private let whisper: Whisper
    private let loader: PopularReplyThreadLoader
    
    init(loader: PopularReplyThreadLoader, whisper: Whisper) {
        self.loader = loader
        self.whisper = whisper
    }
}

extension PopularReplyThreadVM : WhisperPresenter {
    func loadItems(completion: @escaping ([WhisperPresentableData]) -> Void) {
        loader.loadPopularReplyThread(from: whisper) { result in
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
