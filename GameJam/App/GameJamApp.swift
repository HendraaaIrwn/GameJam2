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
        runPathSwipeValidatorSelfCheck()
        runRobotTargetValidatorSelfCheck()
        runElevatorChoiceValidatorSelfCheck()
        runBridgeBalanceValidatorSelfCheck()
        runCitizenRescueValidatorSelfCheck()
        runCrowdResistanceValidatorSelfCheck()
        runTransitSwitchSearchValidatorSelfCheck()
        runManualTunnelEntryValidatorSelfCheck()
        #endif
    }

    var body: some Scene {
        WindowGroup {
            GameContainerView(viewModel: gameFlow)
        }
    }
}
