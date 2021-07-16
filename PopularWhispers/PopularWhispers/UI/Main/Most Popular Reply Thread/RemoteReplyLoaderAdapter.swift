
import Foundation
import WhisperApp

class RemoteReplyLoaderAdapter: RepliesLoader {
    let remote: RemoteReplyLoader
    
    init(remote: RemoteReplyLoader) {
        self.remote = remote
    }
    
    func load(repliesFrom id: String, completion: @escaping (RepliesLoaderResult) -> Void) {
        remote.load(from: id) { [weak self] result in
            guard self != nil else { return }
            
            switch result {
            case let .success(whispers):
                completion(.success(whispers))
            case let .failure(error):
                switch error {
                case .connectivityError:
                    completion(.failure(.connectivityError))
                case .invalidData:
                    completion(.failure(.invalidData))
                }
            }
        }
    }
}
