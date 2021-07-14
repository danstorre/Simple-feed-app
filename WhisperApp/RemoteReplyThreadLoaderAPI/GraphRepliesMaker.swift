
import Foundation

public final class GraphRepliesMaker {
    private let loader: ReplyThreadLoader
    
    public enum Result: Equatable {
        case failure(Error)
    }
    
    public enum Error: Swift.Error, Equatable {
        case connectivityError
        case invalidData
    }
    
    public init(loader: ReplyThreadLoader) {
        self.loader = loader
    }
    
    public func createGraphFrom(whisperID: String,
                                completion: @escaping (Result) -> Void = { _ in }) {
        loader.load(repliesFrom: whisperID) { result in
            switch result {
            case let .failure(error):
                switch error {
                case .connectivityError:
                    completion(.failure(.connectivityError))
                case .invalidData:
                    completion(.failure(.invalidData))
                }
            case .success(_):
                break
            }
        }
    }
}
