
import Foundation

public final class GraphRepliesMaker {
    private let loader: RepliesLoader
    
    public enum Result: Equatable {
        case success(NodeWhisper)
        case failure(Error)
    }
    
    public enum Error: Swift.Error, Equatable {
        case connectivityError
        case invalidData
    }
    
    public init(loader: RepliesLoader) {
        self.loader = loader
    }
    
    public func createGraphFrom(whisper: Whisper,
                                completion: @escaping (Result) -> Void = { _ in }) {
        let whisperNodeRoot = NodeWhisper(whisper: whisper)
        let queueOperations = Queue<NodeWhisper>(items: [whisperNodeRoot])
        createGraphFrom(queue: queueOperations,
                        root: whisperNodeRoot,
                        completion: completion)
    }
    
    private func createGraphFrom(queue: Queue<NodeWhisper>,
                                 root: NodeWhisper,
                                 completion: @escaping (Result) -> Void) {
        var auxQueue = queue
        
        guard let current = auxQueue.dequeue() else {
            completion(.success(root))
            return
        }
        
        loader.load(repliesFrom: current.whisper.wildCardID) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(replyWhispers):
                guard !replyWhispers.isEmpty else {
                    _ = auxQueue.dequeue()
                    self.createGraphFrom(queue: auxQueue,
                                         root: root,
                                         completion: completion)
                    return
                }
                
                let replyNodes = replyWhispers.map { NodeWhisper(whisper: $0) }
                
                current.replies = replyNodes
                
                _ = auxQueue.dequeue()
                for whisperNode in replyNodes {
                    auxQueue.enqueue(element: whisperNode)
                }
                
                self.createGraphFrom(queue: auxQueue,
                                     root: root,
                                     completion: completion)
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

public class NodeWhisper: Equatable {
    public let whisper: Whisper
    public var replies: [NodeWhisper]?
    
    public init(whisper: Whisper, replies: [Whisper]? = nil) {
        self.whisper = whisper
        self.replies = replies?.map { NodeWhisper(whisper: $0) }
    }
    
    public static func == (lhs: NodeWhisper, rhs: NodeWhisper) -> Bool {
        return lhs.whisper.wildCardID == rhs.whisper.wildCardID
    }
}

private struct Queue<T>{
    
    var items:[T] = []
    
    mutating func enqueue(element: T)
    {
        items.append(element)
    }
    
    mutating func dequeue() -> T?
    {
        
        if items.isEmpty {
            return nil
        }
        else{
            let tempElement = items.first
            items.remove(at: 0)
            return tempElement
        }
    }
}
