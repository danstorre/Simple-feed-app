
import Foundation

protocol WhisperPresenter {
    func loadItems(completion: @escaping ([WhisperPresentableData]) -> Void)
}

class AdapterWhisperList: ObservableObject {
    private let loader: WhisperPresenter
    @Published var replies: [WhisperPresentableData] = []
    
    let selection: (String) -> Void
    
    init(loader: WhisperPresenter, handler: @escaping (String) -> Void) {
        self.loader = loader
        self.selection = handler
    }
    
    func loadItems() {
        loader.loadItems { [weak self] whispersViewData in
            guard let self = self else { return }
            
            self.replies = whispersViewData
        }
    }
}
