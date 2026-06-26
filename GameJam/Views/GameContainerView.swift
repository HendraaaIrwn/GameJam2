import SpriteKit
import SwiftUI

struct GameContainerView: View {
    @Bindable var viewModel: GameFlowViewModel

    var body: some View {
        switch viewModel.screen {
        case .gameplay:
            ZStack(alignment: .top) {
                SpriteView(scene: viewModel.scene)
                    .id(viewModel.sceneID)
                    .ignoresSafeArea()

                GameHUDView(
                    levelTitle: viewModel.levelTitle,
                    score: viewModel.score,
                    statusText: viewModel.statusText,
                    canRetry: viewModel.canRetry,
                    retry: viewModel.retry
                )
            }
        case .chapterTransition:
            ChapterTransitionView(onCompleted: viewModel.completeChapterTransition)
        }
    }
}
