#if DEBUG
import CoreGraphics
import Foundation

func runBridgeBalanceValidatorSelfCheck() {
    let centered = BridgeBalanceValidator()
    centered.startLevel(at: 0)
    var result = BridgeBalanceValidationResult.balancing(balanceValue: 0, safeProgress: 0, dangerProgress: 0)
    for step in 1...41 {
        result = centered.update(tiltInput: 0.09, aiPush: 0.162, currentTime: TimeInterval(step) * 0.1)
    }
    assert(result == .success)

    let left = BridgeBalanceValidator()
    left.startLevel(at: 0)
    assert(left.update(tiltInput: 0, aiPush: -12, currentTime: 0.1) == .fellLeft)

    let right = BridgeBalanceValidator()
    right.startLevel(at: 0)
    assert(right.update(tiltInput: 0, aiPush: 12, currentTime: 0.1) == .fellRight)

    let trap = BridgeBalanceValidator()
    trap.startLevel(at: 0)
    assert(trap.validateTrap(target: .autoPathButton, time: 0.2) == .trapSelected(target: .autoPathButton))
    assert(trap.validateTrap(target: .blueAIRoute, time: 0.3) == .trapSelected(target: .blueAIRoute))
    assert(trap.validateTrap(target: .aiWallScreen, time: 0.4) == .trapSelected(target: .aiWallScreen))
    assert(trap.validateTrap(target: .manualBridge, time: 0.5) == nil)

    let noInput = BridgeBalanceValidator()
    noInput.startLevel(at: 0)
    assert(noInput.update(tiltInput: 0, aiPush: 0, currentTime: 4.1) == .noInputTimeout)

    let total = BridgeBalanceValidator()
    total.startLevel(at: 0)
    assert(total.update(tiltInput: 0.1, aiPush: 0, currentTime: 10.1) == .totalTimeout)

    centered.reset()
    assert(centered.balanceValue == 0)
    assert(centered.safeTime == 0)
}
#endif
