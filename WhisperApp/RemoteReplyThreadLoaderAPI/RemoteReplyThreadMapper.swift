import Foundation

internal final class RemoteReplyThreadLoaderMapper {
    private struct RemoteWhisperReplyRoot: Decodable {
        let replies: [RemoteWhisperReply]
        
        enum CodingKeys: String, CodingKey {
            case replies
        }
    }
    
    static func map(response: HTTPURLResponse, data: Data) -> RemoteReplyThreadLoader.Result {
        guard response.statusCode == 200,
              let root = try? JSONDecoder().decode(RemoteWhisperReplyRoot.self, from: data) else {
            return .failure(.invalidData)
        }
        
        return .success(root.replies)
    }
}
