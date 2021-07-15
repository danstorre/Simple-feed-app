
import SwiftUI
import WhisperApp

class RemoteReplyLoaderAdapter: RepliesLoader {
    let remote: RemoteReplyLoader
    
    init(remote: RemoteReplyLoader) {
        self.remote = remote
    }
    
    func load(repliesFrom id: String, completion: @escaping (RepliesLoaderResult) -> Void) {
        remote.load(from: id) { result in
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

class ReplyThreadLoaderAdapter: PopularReplyThreadLoader {
    let remoteReplyFromWhisperAPI: RemoteReplyLoaderAdapter
    
    init(remoteReplyFromWhisperAPI: RemoteReplyLoaderAdapter) {
        self.remoteReplyFromWhisperAPI = remoteReplyFromWhisperAPI
    }
    
    func loadPopularReplyThread(from whisper: Whisper,
                                completion: @escaping (ResultReplyThread) -> Void) {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            
            let graphMaker = GraphRepliesMaker(loader: self.remoteReplyFromWhisperAPI)
            
            graphMaker.createGraphFrom(whisper: whisper) { result in
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

class PopularWhisperVM {
    let loader: PopularReplyThreadLoader
    var replies: [Whisper] = []
    
    init(loader: PopularReplyThreadLoader) {
        self.loader = loader
    }
    
    func loadPopularReply(from whisper: Whisper) {
        loader.loadPopularReplyThread(from: whisper) { result in
            switch result {
            case let .success(replies):
                self.replies = replies
            case let .failure(error):
                print(error.localizedDescription)
            }
        }
    }
}

@main
struct PopularWhispersApp: App {
    @State var popularRepliesVM: PopularWhisperVM!
    
    static let popularThreadURL = URL(string: "http://prod.whisper.sh/whispers/replies")!

    var body: some Scene {
        let popularWhispersAPI = RemoteReplyLoader(url: Self.popularThreadURL, client: URLSession.shared)
        let remoteAdapter = RemoteReplyLoaderAdapter(remote: popularWhispersAPI)
        let replyThreadLoader = ReplyThreadLoaderAdapter(remoteReplyFromWhisperAPI: remoteAdapter)
        

        WindowGroup {
            PopularThreadFromWhisper(title: "Popular Reply Thread",
                                     whispers: [WhisperPresentableData(description: "a text", heartCount: "1", image: nil)])
        }
    }
}


extension URLSession: HTTPClient {
    public func getDataFrom(url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        let dataTask = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                completion(.failure(NSError(domain: "URLSession - Network problem",
                                            code: 1)))
                return
            }
            
            let httpResponse = HTTPURLResponse(url: url,
                                               statusCode: 200,
                                               httpVersion: nil,
                                               headerFields: nil)!
            
            completion(.success(httpResponse, data))
        }
        
        dataTask.resume()
    }
}
