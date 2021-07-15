
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


enum FactoryPopularReplyThreadLoader {
    static func create() -> PopularReplyThreadLoader {
        let prodUrL = URL(string: "http://prod.whisper.sh/whispers/replies")!
        return ReplyThreadLoaderAdapter(remoteReplyFromWhisperAPI: RemoteReplyLoaderAdapter(remote: RemoteReplyLoader(url: prodUrL, client: URLSession.shared)))
    }
}

enum CreatePopularThreadView {
    static func create() -> PopularThreadFromWhisper {
        let popularRepliesVM: PopularWhisperVM = PopularWhisperVM(loader: FactoryPopularReplyThreadLoader.create())
        
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
