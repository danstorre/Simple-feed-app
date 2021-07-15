
import Foundation
import WhisperApp

class ReplyThreadLoaderAdapter: PopularReplyThreadLoader {
    private let remoteReplyFromWhisperAPI: RemoteReplyLoaderAdapter
    private let graphMaker: GraphRepliesMaker
    
    init(remoteReplyFromWhisperAPI: RemoteReplyLoaderAdapter) {
        self.remoteReplyFromWhisperAPI = remoteReplyFromWhisperAPI
        self.graphMaker = GraphRepliesMaker(loader: self.remoteReplyFromWhisperAPI)
    }
    
    func loadPopularReplyThread(from whisper: Whisper,
                                completion: @escaping (ResultReplyThread) -> Void) {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            
            self.graphMaker.createGraphFrom(whisper: whisper) { result in
                switch result {
                case let .success(nodeWhisper):
                    let topMostPopularThread = PopularReplyThreadMakerFromGraph()
                        .createTopMostLikedReplyThread(from: nodeWhisper)
                    DispatchQueue.main.async {
                        completion(.success(topMostPopularThread))
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
