#if DEBUG
import CoreGraphics
import Foundation

func runCrowdResistanceValidatorSelfCheck() {
    let validator = CrowdResistanceValidator()
    validator.startLevel(at: 0)
    assert(validator.validateSwipe(startPoint: CGPoint(x: 120, y: 0), endPoint: CGPoint(x: 20, y: 5), time: 0.1) == .resistanceProgress(current: 1, required: 3))
    assert(validator.validateSwipe(startPoint: CGPoint(x: 120, y: 0), endPoint: CGPoint(x: 30, y: -5), time: 0.2) == .resistanceProgress(current: 2, required: 3))
    assert(validator.validateSwipe(startPoint: CGPoint(x: 140, y: 0), endPoint: CGPoint(x: 20, y: 8), time: 0.3) == .resisted)

    let wrong = CrowdResistanceValidator()
    wrong.startLevel(at: 0)
    assert(wrong.validateSwipe(startPoint: .zero, endPoint: CGPoint(x: 90, y: 5), time: 0.1) == .followedCrowd)
    assert(wrong.validateSwipe(startPoint: .zero, endPoint: CGPoint(x: 20, y: 5), time: 0.2) == .weakSwipe)
    assert(wrong.validateSwipe(startPoint: .zero, endPoint: CGPoint(x: 10, y: 90), time: 0.3) == .wrongDirection)

    assert(wrong.validateTap(target: .flowWithCrowdButton, time: 0.4) == .trapSelected(target: .flowWithCrowdButton))
    assert(wrong.validateTap(target: .blueFlowRoute, time: 0.5) == .trapSelected(target: .blueFlowRoute))
    assert(wrong.validateTap(target: .aiWallScreen, time: 0.6) == .trapSelected(target: .aiWallScreen))
    assert(wrong.validateTap(target: .empty, time: 0.7) == nil)
    assert(wrong.validateTap(target: .raka, time: 0.8) == nil)
    assert(wrong.validateTap(target: .crowdCitizen, time: 0.9) == nil)
    assert(wrong.validateTap(target: .yellowManualLane, time: 1.0) == nil)

    let noInput = CrowdResistanceValidator()
    noInput.startLevel(at: 0)
    assert(noInput.checkTimeouts(currentTime: 4.1) == .noInputTimeout)

    let total = CrowdResistanceValidator()
    total.startLevel(at: 0)
    assert(total.checkTimeouts(currentTime: 9.1) == .totalTimeout)

    validator.reset()
    assert(validator.resistanceCount == 0)
    assert(!validator.hasReceivedInput)
}
#endif
