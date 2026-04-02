import SwiftUI

enum Tab {
    case timer
    case todo
}

struct ContentView: View {
    @State private var currentTab: Tab = .timer
    var timerViewModel: TimerViewModel

    var body: some View {
        VStack(spacing: 0) {
            HeaderView(currentTab: $currentTab)

            Divider()
                .background(Color.gray.opacity(0.3))

            switch currentTab {
            case .timer:
                TimerView(vm: timerViewModel)
            case .todo:
                TodoView()
            }
        }
        .frame(width: 260, height: 320) // Change this aswell for size (rest in AppDelegate -> setupPopover)
        .background(Color(hex: "323235"))
        .focusable(false)
    }
}
