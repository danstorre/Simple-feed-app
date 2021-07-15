
import SwiftUI

struct PopularThreadFromWhisper: View {
    let title: String
    @ObservedObject var viewModel: PopularWhisperVM
    
    var body: some View {
        VStack {
            PopularThreadHeader(title: title)
            ForEach(viewModel.replies) {
                WhisperReplyView(whisper: $0)
            }
            Spacer()
        }
    }
}

struct PopularThreadFromWhisper_Previews: PreviewProvider {
    
    static var vm: PopularWhisperVM = PopularWhisperVM(loader: FactoryPopularReplyThreadLoader.create())
    
    init() {
        let whisper1 = WhisperPresentableData(description: "a text 1", heartCount: "2", image: nil, id: "1")
        let whisper2 = WhisperPresentableData(description: "a text 2", heartCount: "4", image: nil, id: "2")
        let whisper3 = WhisperPresentableData(description:
                                                """
a very large a very large a very large a very large a very large a very large a very large a very large a very large a very large a very large a very large a very large a very large a very large a very large text
""", heartCount: "4", image: nil, id: "3")
        let whispers = [whisper1, whisper2, whisper3]
        
        PopularThreadFromWhisper_Previews.vm.replies = whispers
    }
    
    static var previews: some View {
        Group {
            PopularThreadFromWhisper(title: "Most Popular Thread", viewModel: vm)
            
            PopularThreadFromWhisper(title: "Most Popular Thread", viewModel: vm)
                .preferredColorScheme(.dark)
        }
    }
}
