import Combine
import SwiftUI

struct GameHUDView: View {
    let chapterNumber: Int
    let levelNumber: Int
    let score: GameScore
    let novaInstruction: String
    let canRetry: Bool
    let retry: () -> Void

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                HStack(alignment: .top) {
                    chapterLevelView
                    Spacer()
                    scoreView
                }
                .padding(.horizontal, 20)
                .padding(.top, 6)
                
                novaInstructionPanel
                    .padding(.horizontal, 12)
                    .offset(y: -24)

                Spacer()
            }
            .foregroundStyle(AppColor.textOnDark)
            .accessibilityElement(children: .contain)

            if canRetry {
                Color.black.opacity(0.65)
                    .ignoresSafeArea()

                AppButton("RETRY", systemImage: "arrow.clockwise", height: 56, fontSize: 22, action: retry)
                    .frame(maxWidth: 240)
                    .accessibilityHint("Starts the current level again")
            }
        }
    }

    private var chapterLevelView: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("CHAPTER \(chapterNumber)")
            Text("LEVEL \(levelNumber)")
        }
        .font(.custom(GameFont.heavy, size: 18))
        .foregroundStyle(AppColor.obedience)
//        .shadow(radius: 2)
    }

    private var scoreView: some View {
        VStack(alignment: .trailing, spacing: 4) {
            Text("OBEDIENCE \(score.obedience)")
            Text("HUMANITY \(score.humanity)")
        }
        .font(.custom(GameFont.heavy, size: 18))
        .foregroundStyle(AppColor.obedience)
//        .shadow(radius: 2)
    }

    private var novaInstructionPanel: some View {
        ZStack {
            Image("nova_alert")
                .resizable()
                .scaledToFit()

            NovaTerminalInstructionText(text: novaInstruction)
                .padding(.top, 46)
//                .shadow(color: .black.opacity(0.8), radius: 2, y: 1)
        }
        .frame(maxWidth: 360)
        .accessibilityLabel("NOVA instruction: \(novaInstruction)")
    }
}

private struct NovaTerminalInstructionText: View {
    let text: String

    @State private var visibleCharacters = 0

    private let tick = Timer.publish(every: 0.035, on: .main, in: .common).autoconnect()

    var body: some View {
        Text(visibleText)
            .font(.custom(GameFont.pixelifySans, size: 20))
            .foregroundStyle(.red)
            .multilineTextAlignment(.center)
            .lineLimit(4)
            .minimumScaleFactor(0.65)
            .frame(maxWidth: 300)
            .onReceive(tick) { _ in
                guard visibleCharacters < text.count else { return }
                visibleCharacters += 1
            }
            .onChange(of: text) { _, _ in
                visibleCharacters = 0
            }
            .onAppear {
                visibleCharacters = min(visibleCharacters, text.count)
            }
    }

    private var visibleText: String {
        String(text.prefix(visibleCharacters))
    }
}


#Preview {
    GameHUDView(
        chapterNumber: 1,
        levelNumber: 1,
        score: .initial,
        novaInstruction: "",
        canRetry: false,
        retry: {}
    )
}
