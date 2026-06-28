#if DEBUG
import SpriteKit
import SwiftUI

private struct RejectAutoRoutineScenePreviewView: View {
    private let scene: RejectAutoRoutineScene = {
        let scene = RejectAutoRoutineScene(size: CGSize(width: 390, height: 844))
        scene.scaleMode = .resizeFill
        return scene
    }()

    var body: some View {
        SpriteView(scene: scene)
            .ignoresSafeArea()
    }
}

private struct RejectAutoRoutineSceneWithHUDPreviewView: View {
    var body: some View {
        ZStack(alignment: .top) {
            RejectAutoRoutineScenePreviewView()

            GameHUDView(
                chapterNumber: 1,
                levelNumber: 2,
                score: .initial,
                novaInstruction: "Accept today’s perfect routine.",
                canRetry: false,
                retry: {}
            )
        }
    }
}

#Preview("Chapter 1 Level 2 — Scene") {
    RejectAutoRoutineScenePreviewView()
}

#Preview("Chapter 1 Level 2 — Scene + HUD") {
    RejectAutoRoutineSceneWithHUDPreviewView()
}
#endif
