
import SwiftUI
import WhisperApp

struct PopularThreadFromWhisper: View {
    let title: String
    @ObservedObject var viewModel: PopularReplyThreadVM
    
    var body: some View {
        ScrollView {
            VStack {
                PopularThreadHeader(title: title)
                ForEach(viewModel.replies) {
                    WhisperReplyView(whisper: $0)
                }
                Spacer()
            }
        }
        .onAppear {
            viewModel.loadPopularThread()
        }
    }
}

struct PopularThreadFromWhisper_Previews: PreviewProvider {
    
    static var vm: PopularReplyThreadVM = PopularReplyThreadVM(loader: MockReplyThreadLoaderAdapter(),
                                                       whisper: Whisper(description: "a text",
                                                                        heartCount: 1,
                                                                        replyCount: 1,
                                                                        image: URL(string: "http://a-url.com")!,
                                                                        wildCardID: "id"))
    
    static var previews: some View {
        Group {
            PopularThreadFromWhisper(title: "Most Popular Thread", viewModel: vm)
            
            PopularThreadFromWhisper(title: "Most Popular Thread", viewModel: vm)
                .preferredColorScheme(.dark)
        }
    }
}

private class MockReplyThreadLoaderAdapter: PopularReplyThreadLoader {
    
    func loadPopularReplyThread(from whisper: Whisper,
                                completion: @escaping (ResultReplyThread) -> Void) {
        let sameURL = URL(string: "http://a-url.com")!
        let whisper1 = Whisper(description: "a text", heartCount: 1, replyCount: 1, image: sameURL, wildCardID: "1")
        let whisper2 = Whisper(description: "a text", heartCount: 1, replyCount: 1, image: sameURL, wildCardID: "2")
        let whisper3 = Whisper(description: """
a very large a very large a very large a very large a very large a very large a very large a very large a very large a very large a very large a very large a very large a very large a very large a very large text
""", heartCount: 1, replyCount: 1, image: sameURL, wildCardID: "3")
        let whispers = [whisper1, whisper2, whisper3,
                        whisper1, whisper2, whisper3,
                        whisper1, whisper2, whisper3,
                        whisper1, whisper2, whisper3,
                        whisper1, whisper2, whisper3]
    
        completion(.success(whispers))
    }
}
