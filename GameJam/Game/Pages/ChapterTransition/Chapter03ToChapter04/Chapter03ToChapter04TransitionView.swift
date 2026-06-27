import SpriteKit
import SwiftUI

struct Chapter03ToChapter04TransitionView: View {
    private let scene: Chapter03ToChapter04TransitionScene
    let onCompleted: () -> Void

    init(onCompleted: @escaping () -> Void) {
        let scene = Chapter03ToChapter04TransitionScene(size: CGSize(width: 390, height: 844))
        scene.scaleMode = .resizeFill
        self.scene = scene
        self.onCompleted = onCompleted
    }

    var body: some View {
        SpriteView(scene: scene)
            .ignoresSafeArea()
            .onAppear {
                scene.onTransitionCompleted = {
                    DispatchQueue.main.async {
                        onCompleted()
                    }
                }
            }
    }
}
