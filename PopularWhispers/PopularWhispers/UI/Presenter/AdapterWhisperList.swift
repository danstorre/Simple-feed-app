
import Foundation

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
