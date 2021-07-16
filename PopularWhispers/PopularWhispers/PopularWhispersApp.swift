
import Foundation
import SwiftUI

@main
struct PopularWhispersApp: App {
    var body: some Scene {
        WindowGroup {
            FactoryPopularWhisperFeedView.create()
        }
    }
}
