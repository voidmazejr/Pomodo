import SwiftUI

struct HeaderView: View {
    @Binding var currentTab: Tab
    var onSettingsTapped: () -> Void

    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 3) {
                Text("Pomodo")
                    .font(.system(size: 20, weight: .light))
                    .foregroundColor(.white)
                Text("Pomodoro · To Do")
                    .font(.system(size: 10))
                    .foregroundColor(.gray)
            }

            Spacer()

            HStack(spacing: 5) {
                Button(action: {
                    currentTab = currentTab == .timer ? .todo : .timer
                }) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.gray)
                }
                .buttonStyle(HeaderButtonStyle())

                Divider()
                    .frame(height: 14)
                    .background(Color.gray.opacity(0.4))

                Button(action: { onSettingsTapped() }) {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.gray)
                }
                .buttonStyle(HeaderButtonStyle())
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color(hex: "323235"))
    }
}

struct HeaderButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(width: 26, height: 26)
            .background(configuration.isPressed
                ? Color.white.opacity(0.15)
                : Color.white.opacity(0.08))
            .cornerRadius(7)
    }
}
