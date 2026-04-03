import AppKit
import SwiftUI
import SwiftData
import Combine

class AppDelegate: NSObject, NSApplicationDelegate, NSPopoverDelegate {
    var statusItem: NSStatusItem?
    var popover = NSPopover()
    let timerViewModel = TimerViewModel()
    private var cancellable: AnyCancellable?

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupStatusItem()
        setupPopover()
        observeTimer()
        setupTimerFinishedCallback()
    }

    func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: 42)
        if let button = statusItem?.button {
            button.font = NSFont.monospacedDigitSystemFont(ofSize: 12, weight: .medium)
            button.title = "25:00"
            button.alignment = .center
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
            button.action = #selector(handleClick)
            button.target = self
        }
    }

    func setupPopover() {
        popover.contentSize = NSSize(width: 260, height: 320)
        popover.behavior = .transient
        popover.delegate = self
        let container = try! ModelContainer(for: Task.self)
        popover.contentViewController = NSHostingController(
            rootView: ContentView(timerViewModel: timerViewModel)
                .modelContainer(container)
        )
        popover.contentViewController?.view.setFrameSize(
            NSSize(width: 260, height: 320)
        )
    }

    func observeTimer() {
        cancellable = timerViewModel.$secondsRemaining
            .sink { [weak self] _ in
                DispatchQueue.main.async {
                    guard let self else { return }
                    let time = self.timerViewModel.displayTime
                    self.statusItem?.button?.title = time
                    let isHourMode = self.timerViewModel.secondsRemaining >= 3600
                    self.statusItem?.length = isHourMode ? 54 : 42
                }
            }
    }

    func setupTimerFinishedCallback() {
        timerViewModel.onTimerFinished = { [weak self] in
            guard let self else { return }
            DispatchQueue.main.async {
                if !self.popover.isShown {
                    self.togglePopover()
                }
            }
        }
    }

    @objc func handleClick(sender: NSStatusBarButton) {
        let event = NSApp.currentEvent!
        if event.type == .rightMouseUp {
            if timerViewModel.isRunning {
                timerViewModel.pause()
            } else {
                timerViewModel.start()
            }
        } else {
            togglePopover()
        }
    }


    @objc func toggleTimer() {
        if timerViewModel.isRunning {
            timerViewModel.pause()
        } else {
            timerViewModel.start()
        }
    }

    @objc func resetTimer() {
        timerViewModel.stop()
    }

    @objc func togglePopover() {
        guard let button = statusItem?.button else { return }
        if popover.isShown {
            popover.performClose(nil)
            button.isHighlighted = false
        } else {
            popover.show(
                relativeTo: button.bounds,
                of: button,
                preferredEdge: .minY
            )
            button.isHighlighted = true
        }
    }

    func popoverDidClose(_ notification: Notification) {
        statusItem?.button?.isHighlighted = false
    }
}
