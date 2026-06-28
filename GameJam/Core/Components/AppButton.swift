import SwiftUI

struct AppButton: View {
    let title: String
    let systemImage: String?
    let height: CGFloat
    let fontSize: CGFloat
    let action: () -> Void

   init(
       _ title: String,
       systemImage: String? = "play.fill",
       height: CGFloat = 56,
       fontSize: CGFloat = 22,
       action: @escaping () -> Void
   ) {
        self.title = title
        self.systemImage = systemImage
        self.height = height
        self.fontSize = fontSize
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: height * 0.32) {
                if let systemImage {
                    Image(systemName: systemImage)
                        .font(.system(size: height * 0.46, weight: .black))
                        .symbolRenderingMode(.monochrome)
                }

                Text(title)
                    .font(GameFont.swiftUI(fontSize, weight: .black))
                    .tracking(2)
            }
            .foregroundStyle(AppColor.buttonInk)
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .background(AppButtonBackground(cornerRadius: height * 0.5))
            .contentShape(.rect(cornerRadius: height * 0.5))
        }
        .buttonStyle(AppButtonStyle())
        .accessibilityLabel(title)
    }
}

private struct AppButtonBackground: View {
    let cornerRadius: CGFloat

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [
                        AppColor.buttonSurface.opacity(0.94),
                        AppColor.buttonSurface,
                        AppColor.buttonSurface.opacity(0.9)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(.white.opacity(0.75), lineWidth: 1)
            }
            .shadow(color: .white.opacity(0.7), radius: 10, x: 0, y: -3)
            .shadow(color: .black.opacity(0.22), radius: 0, x: 0, y: 12)
//            .shadow(color: .black.opacity(0.16), radius: 11, x: 0, y: 16)
    }
}

private struct AppButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .brightness(configuration.isPressed ? -0.04 : 0)
            .offset(y: configuration.isPressed ? 5 : 0)
            .animation(.spring(response: 0.18, dampingFraction: 0.58), value: configuration.isPressed)
    }
}


#Preview {
    AppButton("Start"){
        
    }
}
