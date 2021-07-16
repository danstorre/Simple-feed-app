
import SwiftUI

struct WhisperView: View {
    let whisper: WhisperPresentableData
    let selection: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Heart count: \(whisper.heartCount)")
                Text(whisper.description)
                Rectangle()
                    .frame(height: 1.0)
            }
            Spacer()
        }
        .padding([.leading, .leading], 16.0)
        .padding([.top, .bottom], 8)
        .onTapGesture {
            selection()
        }
    }
}


struct WhisperReplyView_Previews: PreviewProvider {
    static var previews: some View {
        let whisper1 = WhisperPresentableData(description: "a text 1", heartCount: "2", image: nil, id: "1")
        WhisperView(whisper: whisper1, selection: {})
            .previewLayout(.sizeThatFits)
    }
}
