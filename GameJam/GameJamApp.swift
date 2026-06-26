import SwiftUI

@main
struct GameJamApp: App {
    @State private var gameFlow = GameFlowViewModel()

    init() {
        #if DEBUG
        runTapSequenceValidatorSelfCheck()
        runSwipeDismissValidatorSelfCheck()
        runCurtainDragValidatorSelfCheck()
        runFoodChoiceValidatorSelfCheck()
        runHoldGestureValidatorSelfCheck()
        runManualKeySearchValidatorSelfCheck()
        runManualRouteTraceValidatorSelfCheck()
        runButtonChoiceValidatorSelfCheck()
        #endif
    }

    var body: some Scene {
        WindowGroup {
            GameContainerView(viewModel: gameFlow)
        }
    }
}
