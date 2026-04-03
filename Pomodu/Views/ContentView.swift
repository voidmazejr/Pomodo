import SwiftUI
import AppKit

enum Tab {
    case timer
    case todo
}

struct ContentView: View {
    @State private var currentTab: Tab = .timer
    var timerViewModel: TimerViewModel
    var appDelegate: AppDelegate

    var body: some View {
        VStack(spacing: 0) {
            HeaderView(
                currentTab: $currentTab,
                onSettingsTapped: {
                    appDelegate.toggleSettings()
                }
            )

            Divider()
                .background(Color.gray.opacity(0.3))

            switch currentTab {
            case .timer:
                TimerView(vm: timerViewModel)
            case .todo:
                TodoView()
            }
        }
        .frame(width: 260, height: 320)
        .background(Color(hex: "323235"))
        .focusable(false)
    }
}
