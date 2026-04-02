import SwiftUI
import SwiftData

@main
struct PomodoApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
        .modelContainer(for: Task.self)
    }
}
