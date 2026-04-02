import SwiftUI
import Combine

class TimerViewModel: ObservableObject {
    @Published var secondsRemaining: Int = 25 * 60
    @Published var isRunning: Bool = false
    @Published var isEditing: Bool = false
    @Published var editText: String = ""

    var totalSeconds: Int = 25 * 60
    private var timer: AnyCancellable?

    var displayTime: String {
        let hours = secondsRemaining / 3600
        let minutes = (secondsRemaining % 3600) / 60
        let seconds = secondsRemaining % 60
        if hours > 0 {
            return String(format: "%02dh:%02dm", hours, minutes) // edit this for space fix
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }

    var displayLabel: String {
        let hours = secondsRemaining / 3600
        return hours > 0 ? "hh mm" : "mm:ss"
    }

    var progress: Double {
        guard totalSeconds > 0 else { return 0 }
        return 1.0 - (Double(secondsRemaining) / Double(totalSeconds))
    }

    func setPreset(minutes: Int) {
        isEditing = false
        stop()
        totalSeconds = minutes * 60
        secondsRemaining = totalSeconds
    }

    func start() {
        isRunning = true
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self else { return }
                if self.secondsRemaining > 0 {
                    self.secondsRemaining -= 1
                } else {
                    self.stop()
                }
            }
    }

    func pause() {
        isRunning = false
        timer?.cancel()
    }

    func stop() {
        isRunning = false
        secondsRemaining = totalSeconds
        timer?.cancel()
    }

    func beginEditing() {
        pause()
        editText = ""
        isEditing = true
    }

    func commitEdit() {
        let digits = editText.filter { $0.isNumber }
        if digits.count <= 4 {
            let padded = String(repeating: "0", count: max(0, 4 - digits.count)) + digits
            let minutes = Int(padded.prefix(2)) ?? 0
            let seconds = Int(padded.suffix(2)) ?? 0
            if seconds < 60 {
                totalSeconds = (minutes * 60) + seconds
                secondsRemaining = totalSeconds
            }
        } else {
            let capped = String(digits.prefix(6))
            let padded = String(repeating: "0", count: max(0, 6 - capped.count)) + capped
            let hours = Int(padded.prefix(2)) ?? 0
            let minutes = Int(padded.dropFirst(2).prefix(2)) ?? 0
            if minutes < 60 {
                totalSeconds = (hours * 3600) + (minutes * 60)
                secondsRemaining = totalSeconds
            }
        }
        isEditing = false
    }
}
