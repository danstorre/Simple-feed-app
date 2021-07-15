
import SwiftUI

struct PopularThreadFromWhisper: View {
    let title: String
    @State var whispers: [WhisperPresentableData]
    
    var body: some View {
        VStack {
            PopularThreadHeader(title: title)
            ForEach(whispers.indices) { i in
                WhisperReplyView(whisper: whispers[i])
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
            
            PopularThreadFromWhisper(title: "Most Popular Thread", whispers: whispers)
            
            PopularThreadFromWhisper(title: "Most Popular Thread", whispers: whispers)
                .preferredColorScheme(.dark)
        }
    }
}
