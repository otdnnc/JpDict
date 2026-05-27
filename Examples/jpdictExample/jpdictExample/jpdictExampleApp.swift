import SwiftUI

@main
struct jpdictExampleApp: App {
    @State private var store = DictionaryStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(store)
        }
        #if os(macOS)
        .defaultSize(width: 1100, height: 720)
        #endif
    }
}
