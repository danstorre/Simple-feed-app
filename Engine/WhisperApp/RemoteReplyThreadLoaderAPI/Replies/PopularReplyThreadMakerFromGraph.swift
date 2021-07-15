
import Foundation

public class PopularReplyThreadMakerFromGraph {
    
    public init() { }
    
    public func createTopMostLikedReplyThread(from node: NodeWhisper) -> [Whisper] {
        return getPathFrom(node: node).whispers.reversed()
    }
    
    private func getPathFrom(node: NodeWhisper) -> (count: Int, whispers: [Whisper]) {
        guard let replies = node.replies else {
            return (node.whisper.heartCount, [node.whisper])
        }
        
        var path = [Whisper]()
        var acc = 0
        
        for node in replies {
            let (accFromNode, indicesFromNode) = getPathFrom(node: node)
            if accFromNode > acc {
                path = indicesFromNode
                acc = accFromNode
            }
        }
        
        path.append(node.whisper)
        return (acc + node.whisper.heartCount, path)
    }
}
