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
            switch viewModel.activeTransition {
            case .chapter1ToChapter2:
                ChapterTransitionView(onCompleted: viewModel.completeChapterTransition)
            case .chapter2ToChapter3:
                Chapter02ToChapter03TransitionView(onCompleted: viewModel.completeChapterTransition)
            case .chapter3ToChapter4:
                Chapter03ToChapter04TransitionView(onCompleted: viewModel.completeChapterTransition)
            }
        }
    }
}
