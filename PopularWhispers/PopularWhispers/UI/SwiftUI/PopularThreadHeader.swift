
import SwiftUI

struct PopularThreadHeader: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.title)
            .fontWeight(.bold)
            .multilineTextAlignment(.leading)
    }
}

struct PopularThreadHeader_Previews: PreviewProvider {
    static var previews: some View {
        PopularThreadHeader(title: "A title")
            .previewLayout(.sizeThatFits)
    }
}
