
import Foundation
import WhisperApp

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
