import SwiftUI
import HabitCore

@main
struct HabitHarborApp: App {
    @State private var store = HabitStore()

    var body: some Scene {
        WindowGroup {
            HabitListView()
                .environment(store)
                .preferredColorScheme(.dark)
        }
    }
}
