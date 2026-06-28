import SwiftUI

struct NovaButton: View {
    let title: String
    let systemImage: String?
    let height: CGFloat
    let fontSize: CGFloat
    let action: () -> Void

    @State private var pulse = false
    @State private var tapFlash = false

    init(
        _ title: String,
        systemImage: String? = nil,
        height: CGFloat = 64,
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
        Button {
            tapFlash = true
            action()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
                tapFlash = false
            }
        } label: {
            ZStack {
                NovaButtonBackground(height: height, isActive: pulse || tapFlash)

                HStack(spacing: height * 0.18) {
                    if let systemImage {
                        Image(systemName: systemImage)
                            .font(.system(size: height * 0.34, weight: .black))
                            .symbolRenderingMode(.monochrome)
                    }

                    Text(title)
                        .font(GameFont.swiftUI(fontSize, weight: .black))
                        .tracking(1.8)
                }
                .foregroundStyle(Color(hex: "#EFFFFF"))
                .shadow(color: Color(hex: "#4EDFF1").opacity(0.9), radius: 10)
            }
            .frame(height: height)
            .contentShape(.rect(cornerRadius: height * 0.5))
        }
        .buttonStyle(NovaButtonStyle())
        .accessibilityLabel(title)
        .onAppear { pulse = true }
    }
}

private struct NovaButtonBackground: View {
    let height: CGFloat
    let isActive: Bool

    private var cornerRadius: CGFloat { height * 0.5 }

    var body: some View {
        ZStack {
            capsule
                .fill(Color(hex: "#7DE8F3"))
                .blur(radius: isActive ? 18 : 12)
                .scaleEffect(x: 1.04, y: 1.26)

            capsule
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hex: "#C8FFFF").opacity(0.94),
                            Color(hex: "#70DDED"),
                            Color(hex: "#9AF2F8")
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(alignment: .top) { topGlass }
                .overlay(alignment: .bottom) { bottomGlass }
                .overlay { innerStroke }
                .overlay { outerStroke }
                .overlay(alignment: .top) { novaDots.offset(y: height * 0.10) }
        }
        .shadow(color: Color(hex: "#8DF5FF").opacity(isActive ? 0.95 : 0.66), radius: isActive ? 22 : 15)
        .shadow(color: .white.opacity(0.85), radius: 6, y: -2)
        .animation(.easeInOut(duration: 1.35).repeatForever(autoreverses: true), value: isActive)
    }

    private var capsule: RoundedRectangle {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
    }

    private var outerStroke: some View {
        capsule
            .stroke(.white.opacity(0.96), lineWidth: height * 0.12)
    }

    private var innerStroke: some View {
        capsule
            .inset(by: height * 0.11)
            .stroke(Color(hex: "#9DF7FF").opacity(0.9), lineWidth: 2)
            .padding(height * 0.02)
    }

    private var topGlass: some View {
        HStack(spacing: 6) {
            Capsule().fill(.white.opacity(0.45)).frame(width: 46, height: 4)
            Capsule().fill(.white.opacity(0.9)).frame(width: 52, height: 5)
            Circle().fill(.white.opacity(0.70)).frame(width: 7, height: 7)
            Circle().fill(.white.opacity(0.82)).frame(width: 7, height: 7)
            Circle().fill(.white.opacity(0.70)).frame(width: 7, height: 7)
        }
    }

    private var bottomGlass: some View {
        Capsule()
            .fill(.white.opacity(0.56))
            .frame(width: 102, height: 5)
            .padding(.bottom, height * 0.10)
    }

    private var novaDots: some View {
        HStack(spacing: 8) {
            Circle().fill(.white.opacity(0.72)).frame(width: 5, height: 5)
            Circle().fill(.white.opacity(0.9)).frame(width: 5, height: 5)
            Circle().fill(.white.opacity(0.72)).frame(width: 5, height: 5)
        }
    }
}

private struct NovaButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.965 : 1)
            .brightness(configuration.isPressed ? 0.10 : 0)
            .saturation(configuration.isPressed ? 1.25 : 1)
            .offset(y: configuration.isPressed ? 4 : 0)
            .shadow(color: Color(hex: "#8DF5FF").opacity(configuration.isPressed ? 1 : 0), radius: configuration.isPressed ? 26 : 0)
            .animation(.spring(response: 0.18, dampingFraction: 0.56), value: configuration.isPressed)
    }
}

#Preview("Nova Button") {
    ZStack {
        Color(hex: "#F8FBFF").ignoresSafeArea()
        NovaButton("NOVA", systemImage: "sparkles", action: {})
            .padding(.horizontal, 28)
    }
}

#Preview("Nova Button Wide") {
    ZStack {
        Color(hex: "#FFF7E8").ignoresSafeArea()
        NovaButton("ACCEPT ROUTINE", height: 72, fontSize: 24, action: {})
            .padding(.horizontal, 20)
    }
}
