import SwiftUI

struct SettingsView: View {
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Settings")
                    .font(.system(size: 20, weight: .light))
                    .foregroundColor(.white)
                Spacer()
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)

            Divider()
                .background(Color.gray.opacity(0.3))

            Spacer()
        }
        .frame(width: 300, height: 400)
        .background(Color(hex: "323235"))
        .cornerRadius(16)
    }
}
