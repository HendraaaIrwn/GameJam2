import SpriteKit
import SwiftUI

struct Chapter02ToChapter03TransitionView: View {
    private let scene: Chapter02ToChapter03TransitionScene
    let onCompleted: () -> Void

    init(onCompleted: @escaping () -> Void) {
        let scene = Chapter02ToChapter03TransitionScene(size: CGSize(width: 390, height: 844))
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
