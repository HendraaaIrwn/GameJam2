import SwiftUI

struct StorylinePanel: Identifiable {
    let id: Int

    var assetName: String {
        "storyline\(id)"
    }
}

struct StorylineBoardView: View {
    let onCompleted: () -> Void

    @State private var topPanel: StorylinePanel?
    @State private var bottomPanel: StorylinePanel?
    @State private var hasFinishedReveal = false
    @State private var isTopVisible = false
    @State private var isBottomVisible = false
    @State private var revealTask: Task<Void, Never>?
    @State private var audioPlayer = StorylineAudioPlayer()

    private let panels = (1...8).map(StorylinePanel.init)
    private let initialDelay: TimeInterval = 0.4
    private let panelRevealInterval: TimeInterval = 2

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.80, green: 0.93, blue: 0.98),
                    Color(red: 1.00, green: 0.96, blue: 0.90)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 8) {
                header
                    .padding(.bottom, 16)
                
//                Spacer()

                VStack(spacing:32) {
                    panelSlot(topPanel, isVisible: isTopVisible)
            
                    panelSlot(bottomPanel, isVisible: isBottomVisible)
                }
//                .padding(.top, 16)
                
                Spacer()

                if hasFinishedReveal {
                    continueButton
//                        .padding(.bottom, 24)
                        .transition(.opacity.combined(with: .scale(scale: 0.96)))
                }
            }
            .padding(.top, 12)
        }
        .onAppear(perform: startIntro)
        .onDisappear(perform: stopIntro)
    }

    private var header: some View {
        HStack {
            Text("STORYLINE")
                .font(.system(size: 20, weight: .heavy, design: .rounded))
                .foregroundStyle(Color(red: 0.12, green: 0.32, blue: 0.42))

            Spacer()

            Button("SKIP", action: skipToEnd)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(Color(red: 0.12, green: 0.32, blue: 0.42).opacity(0.85), in: Capsule())
        }
        .padding(.horizontal, 20)
    }

    @ViewBuilder
    private func panelSlot(_ panel: StorylinePanel?, isVisible: Bool) -> some View {
        ZStack {
            if let panel {
                StorylinePanelView(panel: panel)
                    .id(panel.id)
                    .opacity(isVisible ? 1 : 0)
                    .offset(y: isVisible ? 0 : 24)
                    .scaleEffect(isVisible ? 1 : 0.96)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 300)
    }

    private var continueButton: some View {
        Button(action: completeIntro) {
            Text("CONTINUE")
                .font(.system(size: 18, weight: .heavy, design: .rounded))
                .foregroundStyle(Color(red: 0.10, green: 0.24, blue: 0.32))
                .padding(.horizontal, 36)
                .padding(.vertical, 16)
                .background(Color(red: 1.0, green: 0.78, blue: 0.22), in: Capsule())
                .shadow(color: .black.opacity(0.16), radius: 8, y: 4)
        }
    }

    private func startIntro() {
        audioPlayer.play()
        revealTask = Task {
            try? await Task.sleep(for: .seconds(initialDelay))

            for panel in panels {
                guard !Task.isCancelled else { return }
                await reveal(panel)
                try? await Task.sleep(for: .seconds(panelRevealInterval))
            }
        }
    }

    @MainActor
    private func reveal(_ panel: StorylinePanel) async {
        let isBottomSlot = panel.id.isMultiple(of: 2)

        withAnimation(.easeIn(duration: 0.28)) {
            if isBottomSlot {
                isBottomVisible = false
            } else {
                isTopVisible = false
            }
        }

        try? await Task.sleep(for: .seconds(0.28))

        if isBottomSlot {
            bottomPanel = panel
        } else {
            topPanel = panel
        }

        withAnimation(.easeOut(duration: 0.55)) {
            if isBottomSlot {
                isBottomVisible = true
            } else {
                isTopVisible = true
            }

            hasFinishedReveal = panel.id == panels.count
        }

        print("Reveal panel:", panel.id)
    }

    private func skipToEnd() {
        print("Storyline skipped to end")
        revealTask?.cancel()
        withAnimation(.easeOut(duration: 0.55)) {
            topPanel = panels[6]
            bottomPanel = panels[7]
            isTopVisible = true
            isBottomVisible = true
            hasFinishedReveal = true
        }
    }

    private func completeIntro() {
        audioPlayer.stop()
        onCompleted()
    }

    private func stopIntro() {
        revealTask?.cancel()
        audioPlayer.stop()
    }
}

struct StorylinePanelView: View {
    let panel: StorylinePanel

    var body: some View {
        Image(panel.assetName)
            .resizable()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(.white.opacity(0.8), lineWidth: 2)
            }
            .shadow(color: .black.opacity(0.15), radius: 8, y: 5)
            .padding(.horizontal, 16)
    }
}

#Preview {
    StorylineBoardView(onCompleted: {})
}
