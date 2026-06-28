import SwiftUI

struct GameHUDView: View {
    let levelTitle: String
    let score: GameScore
    let statusText: String
    let canRetry: Bool
    let retry: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            VStack(spacing: 4) {
                Text("Don’t Trust The App")
                    .font(GameFont.swiftUI(18, weight: .bold))
                Text(levelTitle)
                    .font(GameFont.swiftUI(15))
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 12) {
                Label("Obedience \(score.obedience)", systemImage: "brain")
                Label("Humanity \(score.humanity)", systemImage: "heart")
            }
            .font(GameFont.swiftUI(12))

            Text(statusText)
                .font(GameFont.swiftUI(16, weight: .semibold))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(.thinMaterial, in: Capsule())

            if canRetry {
                Button("Retry Level", action: retry)
                    .buttonStyle(.borderedProminent)
                    .accessibilityHint("Starts the current level again")
            }
        }
        .padding(.top, 12)
        .padding(.horizontal)
        .frame(maxWidth: .infinity)
        .foregroundStyle(.primary)
        .accessibilityElement(children: .contain)
    }
}
