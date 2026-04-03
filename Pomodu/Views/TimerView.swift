import SwiftUI
import SwiftData

struct TimerView: View {
    @ObservedObject var vm: TimerViewModel
    @Query(sort: \Task.order, order: .forward) private var tasks: [Task]

    private var topTask: Task? {
        tasks.first(where: { !$0.isDone })
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            if vm.isEditing {
                TimeEntryField(vm: vm)
            } else {
                Text(vm.displayTime)
                    .font(.system(size: 50, weight: .thin, design: .monospaced))
                    .foregroundColor(.white)
                    .onTapGesture { vm.beginEditing() }
            }

            HStack(spacing: 8) {
                ForEach([15, 30, 45], id: \.self) { minutes in
                    Button("\(minutes)m") {
                        vm.setPreset(minutes: minutes)
                    }
                    .buttonStyle(PresetButtonStyle())
                }
            }
            .padding(.top, 10)

            if let task = topTask {
                Text(task.title)
                    .font(.system(size: 11))
                    .foregroundColor(Color(hex: "bbbbbb"))
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .padding(.top, 6)
            } else {
                Text("no tasks yet")
                    .font(.system(size: 11))
                    .foregroundColor(.gray)
                    .padding(.top, 6)
            }

            HStack(spacing: 8) {
                Button("skip") { vm.stop() }
                    .buttonStyle(TimerButtonStyle(isPrimary: false))
                Button(vm.isRunning ? "pause" : "start") {
                    vm.isRunning ? vm.pause() : vm.start()
                }
                .buttonStyle(TimerButtonStyle(isPrimary: true))
            }
            .padding(.top, 14)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.white.opacity(0.1))
                    Rectangle()
                        .fill(Color.white.opacity(0.85))
                        .frame(width: geo.size.width * vm.progress)
                        .animation(.linear(duration: 1), value: vm.progress)
                }
            }
            .frame(height: 2)
            .cornerRadius(1)
            .padding(.top, 16)

            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.bottom, 12)
    }
}

struct TimeEntryField: View {
    @ObservedObject var vm: TimerViewModel
    @FocusState private var isFocused: Bool
    @State private var isBlinking: Bool = true

    var displayText: String {
        let digits = vm.editText.filter { $0.isNumber }
        if digits.count <= 4 {
            let padded = String(repeating: "0", count: max(0, 4 - digits.count)) + digits
            let mm = padded.prefix(2)
            let ss = padded.suffix(2)
            return "\(mm):\(ss)"
        } else {
            let capped = String(digits.prefix(6))
            let padded = String(repeating: "0", count: max(0, 6 - capped.count)) + capped
            let hh = padded.prefix(2)
            let mm = padded.dropFirst(2).prefix(2)
            return "\(hh)h:\(mm)m" // Edit this for space fix 
        }
    }

//    var modeLabel: String {
//        let digits = vm.editText.filter { $0.isNumber }
//        return digits.count <= 4 ? "mm:ss" : "hh  mm"
//    }

    var body: some View {
        ZStack {
            VStack(spacing: 4) {
                Text(displayText)
                    .font(.system(size: 50, weight: .thin, design: .monospaced))
                    .foregroundColor(.white)
                    .opacity(isBlinking ? 1.0 : 0.2)
                    .animation(
                        .easeInOut(duration: 0.6).repeatForever(autoreverses: true),
                        value: isBlinking
                    )

//                Text(modeLabel)
//                    .font(.system(size: 10))
//                    .foregroundColor(.gray)
//                    .opacity(isBlinking ? 1.0 : 0.2)
//                    .animation(
//                        .easeInOut(duration: 0.6).repeatForever(autoreverses: true),
//                        value: isBlinking
//                    )
            }

            TextField("", text: $vm.editText)
                .foregroundColor(.clear)
                .background(.clear)
                .textFieldStyle(.plain)
                .tint(.clear)
                .frame(width: 180)
                .focused($isFocused)
                .onSubmit { vm.commitEdit() }
                .onExitCommand { vm.isEditing = false }
                .onChange(of: vm.editText) { _, newValue in
                    let digits = newValue.filter { $0.isNumber }
                    let filtered = String(digits.prefix(6))
                    
                    // Only update if it's actually different to prevent unnecessary refreshes
                    if newValue != filtered {
                        DispatchQueue.main.async {
                            vm.editText = filtered
                        }
                    }
                }
        }
        .onAppear {
            DispatchQueue.main.async {
                isFocused = true
                isBlinking = false
            }
        }
    }
}

struct PresetButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 10))
            .foregroundColor(.gray)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(configuration.isPressed
                ? Color.white.opacity(0.15)
                : Color.white.opacity(0.07))
            .cornerRadius(6)
    }
}

struct TimerButtonStyle: ButtonStyle {
    var isPrimary: Bool
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 11))
            .foregroundColor(isPrimary ? .black : .gray)
            .padding(.horizontal, 18)
            .padding(.vertical, 6)
            .background(isPrimary
                ? Color.white.opacity(0.9)
                : Color.white.opacity(0.08))
            .cornerRadius(8)
            .opacity(configuration.isPressed ? 0.7 : 1)
    }
}
