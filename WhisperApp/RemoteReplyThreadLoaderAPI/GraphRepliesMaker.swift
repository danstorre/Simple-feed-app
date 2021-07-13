
import Foundation

public final class GraphRepliesMaker {
    private let loader: ReplyThreadLoader
    
    public init(loader: ReplyThreadLoader) {
        self.loader = loader
    }
    
    public func createGraphFrom(whisperID: String) {
        loader.load(repliesFrom: whisperID) { _ in }
    }
}
