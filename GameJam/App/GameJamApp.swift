import SwiftUI

@main
struct GameJamApp: App {
    @State private var gameFlow = GameFlowViewModel()

    init() {
        #if DEBUG
        runWakeUpTapValidatorSelfCheck()
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
        runArchiveLightLeverValidatorSelfCheck()
        runBrokenCityMapValidatorSelfCheck()
        runMemoryChoiceValidatorSelfCheck()
        runManualProtocolSequenceValidatorSelfCheck()
        runNOVAStabilizationValidatorSelfCheck()
        runArchiveCableConnectionValidatorSelfCheck()
        runRewriteScanAvoidanceValidatorSelfCheck()
        runArchiveBroadcastValidatorSelfCheck()
        #endif
    }

    var body: some Scene {
        WindowGroup {
            if CommandLine.arguments.contains("-preview-level3") {
                FindManualKeyPreviewView()
            } else {
                GameContainerView(viewModel: gameFlow)
            }
        }
    }
}
