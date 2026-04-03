import AppKit
import SwiftUI
import SwiftData
import Combine

class AppDelegate: NSObject, NSApplicationDelegate, NSPopoverDelegate {
    var statusItem: NSStatusItem?
    var popover = NSPopover()
    var settingsWindow: NSWindow?
    let timerViewModel = TimerViewModel()
    private var cancellable: AnyCancellable?
    private var localKeyMonitor: Any?

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupStatusItem()
        setupPopover()
        observeTimer()
        setupTimerFinishedCallback()
        setupKeyShortcut()
    }

    func applicationWillTerminate(_ notification: Notification) {
        if let monitor = localKeyMonitor {
            NSEvent.removeMonitor(monitor)
        }
    }

    func setupKeyShortcut() {
        localKeyMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            if event.modifierFlags.contains(.command) && event.charactersIgnoringModifiers == "," {
                self.toggleSettings()
                return nil
            }
            return event
        }
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
            rootView: ContentView(
                timerViewModel: timerViewModel,
                appDelegate: self
            )
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

    @objc func toggleSettings() {
        if let window = settingsWindow, window.isVisible {
            window.orderOut(nil)
            settingsWindow = nil
            popover.behavior = .transient
            return
        }

        popover.behavior = .applicationDefined

        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 300, height: 400),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )

        panel.isFloatingPanel = true
        panel.becomesKeyOnlyIfNeeded = true
        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.hasShadow = true
        panel.isMovableByWindowBackground = true
        panel.contentViewController = NSHostingController(
            rootView: SettingsView()
        )
        panel.setContentSize(NSSize(width: 300, height: 400))
        // panel.center() // works but its not true center
        // Actual true center
        if let screen = NSScreen.main {
            let x = (screen.frame.width - 300) / 2
            let y = (screen.frame.height - 400) / 2
            panel.setFrameOrigin(NSPoint(x: x, y: y))
        }
        panel.orderFront(nil)
        settingsWindow = panel
    }

    @objc func togglePopover() {
        guard let button = statusItem?.button else { return }
        if popover.isShown {
            if let window = settingsWindow, window.isVisible {
                window.orderOut(nil)
                settingsWindow = nil
                popover.behavior = .transient
            }
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
