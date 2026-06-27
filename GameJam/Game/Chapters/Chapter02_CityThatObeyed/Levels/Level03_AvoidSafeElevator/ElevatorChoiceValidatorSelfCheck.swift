#if DEBUG
import CoreGraphics

func runElevatorChoiceValidatorSelfCheck() {
    var validator = ElevatorChoiceValidator()
    validator.startLevel(at: 0)
    assert(validator.validateSwipe(startPoint: CGPoint(x: 200, y: 100), endPoint: CGPoint(x: 90, y: 115), time: 1) == .correctManualStairs)
    assert(validator.validateSwipe(startPoint: CGPoint(x: 200, y: 100), endPoint: CGPoint(x: 310, y: 105), time: 1) == .wrongSafeElevator)
    assert(validator.validateSwipe(startPoint: CGPoint(x: 200, y: 100), endPoint: CGPoint(x: 195, y: 190), time: 1) == .wrongDirection)
    assert(validator.validateSwipe(startPoint: CGPoint(x: 200, y: 100), endPoint: CGPoint(x: 178, y: 120), time: 1) == .weakSwipe)

    validator = ElevatorChoiceValidator()
    validator.startLevel(at: 10)
    assert(validator.validateTap(target: .manualStairs, time: 11) == .correctManualStairs)
    assert(validator.validateTap(target: .safeElevator, time: 11) == .trapSelected(target: .safeElevator))
    assert(validator.validateTap(target: .safeElevatorButton, time: 11) == .trapSelected(target: .safeElevatorButton))
    assert(validator.validateTap(target: .blueAIRoute, time: 11) == .trapSelected(target: .blueAIRoute))
    assert(validator.validateTap(target: .aiWallScreen, time: 11) == .trapSelected(target: .aiWallScreen))
    assert(validator.validateTap(target: .empty, time: 11) == nil)
    assert(validator.validateTap(target: .raka, time: 11) == nil)

    validator = ElevatorChoiceValidator()
    validator.startLevel(at: 20)
    assert(validator.checkTimeouts(currentTime: 24.1) == .noInputTimeout)

    validator = ElevatorChoiceValidator()
    validator.startLevel(at: 30)
    assert(validator.checkTimeouts(currentTime: 38.1) == .totalTimeout)
}
#endif
