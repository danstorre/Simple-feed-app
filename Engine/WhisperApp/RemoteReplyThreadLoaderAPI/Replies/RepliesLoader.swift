
import Foundation

public enum RepliesLoaderLoaderError {
    case connectivityError
    case invalidData
}

public enum RepliesLoaderResult {
    case success([Whisper])
    case failure(RepliesLoaderLoaderError)
}

public protocol RepliesLoader {
    func load(repliesFrom: String, completion: @escaping (RepliesLoaderResult) -> Void)
}
