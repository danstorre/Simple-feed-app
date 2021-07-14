
import Foundation

public final class GraphRepliesMaker {
    private let loader: ReplyThreadLoader
    
    public enum Result: Equatable {
        case failure(Error)
    }
    
    public enum Error: Swift.Error, Equatable {
        case connectivityError
    }
    
    public init(loader: ReplyThreadLoader) {
        self.loader = loader
    }
    
    public func createGraphFrom(whisperID: String,
                                completion: @escaping (Result) -> Void = { _ in }) {
        loader.load(repliesFrom: whisperID) { result in
            completion(.failure(.connectivityError))
        }
    }
}
