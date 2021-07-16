
import SwiftUI
import WhisperApp

protocol WhisperPresenter {
    func loadItems(completion: @escaping ([WhisperPresentableData]) -> Void)
}

class AdapterWhisperList: ObservableObject {
    private let loader: WhisperPresenter
    @Published var replies: [WhisperPresentableData] = []
    
    init(loader: WhisperPresenter) {
        self.loader = loader
    }
    
    func loadItems() {
        loader.loadItems { [weak self] whispersViewData in
            guard let self = self else { return }
            
            self.replies = whispersViewData
        }
    }
}

struct WhisperListView: View {
    let title: String
    @ObservedObject var viewModel: AdapterWhisperList
    
    var body: some View {
        ScrollView {
            VStack {
                Header(title: title)
                ForEach(viewModel.replies) {
                    WhisperView(whisper: $0)
                }
                Spacer()
            }
        }
        .onAppear {
            viewModel.loadItems()
        }
    }
}

struct PopularThreadFromWhisper_Previews: PreviewProvider {
    
    static var vm: AdapterWhisperList = create()
    
    static func create() -> AdapterWhisperList {
        let whisper = Whisper(description: "a text",
                              heartCount: 1,
                              replyCount: 1,
                              image: URL(string: "http://a-url.com")!,
                              wildCardID: "id")
        return AdapterWhisperList(loader: PopularReplyThreadVM(loader: MockReplyThreadLoaderAdapter(),
                                                               whisper: whisper))
    }
    
    static var previews: some View {
        Group {
            WhisperListView(title: "Most Popular Thread", viewModel: vm)
            
            WhisperListView(title: "Most Popular Thread", viewModel: vm)
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
