
import Foundation
import WhisperApp

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
