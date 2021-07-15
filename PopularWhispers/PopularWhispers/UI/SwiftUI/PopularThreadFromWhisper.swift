
import SwiftUI

struct WhisperPresentableData: Hashable {
    let description: String
    let heartCount: String
    let image: UIImage?
}

struct PopularThreadFromWhisper: View {
    let title: String
    let whispersPresentable: [WhisperPresentableData]
    
    var body: some View {
        VStack {
            PopularThreadHeader(title: title)
            ForEach(whispersPresentable, id:\.self) { whisper in
                WhisperReplyView(whisper: whisper)
            }
            Spacer()
        }
    }
}

struct PopularThreadFromWhisper_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            let whisper1 = WhisperPresentableData(description: "a text 1", heartCount: "2", image: nil)
            let whisper2 = WhisperPresentableData(description: "a text 2", heartCount: "4", image: nil)
            let whisper3 = WhisperPresentableData(description:
"""
a very large a very large a very large a very large a very large a very large a very large a very large a very large a very large a very large a very large a very large a very large a very large a very large text
""", heartCount: "4", image: nil)
            let whispers = [whisper1, whisper2, whisper3]
            
            PopularThreadFromWhisper(title: "Most Popular Thread", whispersPresentable: whispers)
            
            PopularThreadFromWhisper(title: "Most Popular Thread", whispersPresentable: whispers)
                .preferredColorScheme(.dark)
        }
    }
}
