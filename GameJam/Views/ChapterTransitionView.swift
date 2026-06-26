import SpriteKit
import SwiftUI

struct ChapterTransitionView: View {
    private let scene: ChapterTransitionScene
    let onCompleted: () -> Void

    init(onCompleted: @escaping () -> Void) {
        let scene = ChapterTransitionScene(size: CGSize(width: 390, height: 844))
        scene.scaleMode = .resizeFill
        self.scene = scene
        self.onCompleted = onCompleted
    }

    var body: some View {
        SpriteView(scene: scene)
            .ignoresSafeArea()
            .onAppear {
                scene.onTransitionCompleted = {
                    onCompleted()
                }
            }
    }
}
