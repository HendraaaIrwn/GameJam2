import SpriteKit
import SwiftUI

struct GameContainerView: View {
    @Bindable var viewModel: GameFlowViewModel

    var body: some View {
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
    }
}
