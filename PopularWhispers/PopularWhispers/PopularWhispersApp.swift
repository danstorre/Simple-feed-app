
import SwiftUI
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


enum FactoryPopularReplyThreadLoader {
    static func create() -> PopularReplyThreadLoader {
        let prodUrL = URL(string: "http://prod.whisper.sh/whispers/replies")!
        return ReplyThreadLoaderAdapter(remoteReplyFromWhisperAPI: RemoteReplyLoaderAdapter(remote: RemoteReplyLoader(url: prodUrL, client: URLSession.shared)))
    }
}

enum CreatePopularThreadView {
    private static let aWhisper = Whisper(description: "1",
                                          heartCount: 1,
                                          replyCount: 1,
                                          image: URL(string: "http://a-url.com")!,
                                          wildCardID: "05c6f4b2e1123a3b427cf57c25ce26be41a789")
    
    static func create(from whisper: Whisper = CreatePopularThreadView.aWhisper) -> PopularThreadFromWhisper {
        let popularRepliesVM: PopularWhisperVM = PopularWhisperVM(loader: FactoryPopularReplyThreadLoader.create(),
                                                                  whisper: CreatePopularThreadView.aWhisper)
        
        return PopularThreadFromWhisper(title: "Popular Reply Thread",
                                        viewModel: popularRepliesVM)
    }
}

@main
struct PopularWhispersApp: App {
    var body: some Scene {
        WindowGroup {
            CreatePopularThreadView.create()
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
