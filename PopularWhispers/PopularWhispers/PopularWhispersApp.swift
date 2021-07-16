
import Foundation
import SwiftUI

@main
struct PopularWhispersApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    @State var nextView: WhisperListView!
    @State var pushed: Bool = false
    
    var body: some View {
        NavigationView {
            VStack {
                FactoryPopularWhisperFeedView.create { whisperListView in
                    nextView = whisperListView
                    pushed = true
                }
                
                NavigationLink(destination: nextView, isActive: $pushed) {}
            }
        }.navigationTitle("Popular")
    }
}
