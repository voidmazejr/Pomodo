import SwiftUI
import AppKit

enum Tab {
    case timer
    case todo
}

struct ContentView: View {
    @State private var currentTab: Tab = .timer
    @FocusState private var isFocused: Bool
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
        .focusable(true)
        .focusEffectDisabled()
        .focused($isFocused)
        .onAppear {
            DispatchQueue.main.async { isFocused = true }
        }
        // Re-grab focus when the text field disappears
        .onChange(of: timerViewModel.isEditing) { _, isEditing in
            if !isEditing {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    isFocused = true
                }
            }
        }
        .onKeyPress(.leftArrow) {
            currentTab = .timer
            return .handled
        }
        .onKeyPress(.rightArrow) {
            currentTab = .todo
            return .handled
        }
        .onKeyPress(.space) {
            guard currentTab == .timer else { return .ignored }
            if timerViewModel.isRunning {
                timerViewModel.pause()
            } else {
                timerViewModel.start()
            }
            return .handled
        }
        .onKeyPress(.return) {
            guard currentTab == .timer else { return .ignored }
            
            // FIX: Only handle Enter if we are NOT currently editing.
            // If we ARE editing, let the TextField in TimeEntryField handle it via .onSubmit
            if !timerViewModel.isEditing {
                timerViewModel.beginEditing()
                return .handled
            }
            
            return .ignored
        }
        .onKeyPress(.delete) {
            guard currentTab == .timer else { return .ignored }
            timerViewModel.stop()
            return .handled
        }
    }
}

