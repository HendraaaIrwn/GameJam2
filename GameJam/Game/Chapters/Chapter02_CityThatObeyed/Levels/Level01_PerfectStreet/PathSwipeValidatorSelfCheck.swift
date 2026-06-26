#if DEBUG
import CoreGraphics

func runPathSwipeValidatorSelfCheck() {
    var validator = PathSwipeValidator()
    validator.startLevel(at: 0)
    assert(validator.validateSwipe(startPoint: CGPoint(x: 100, y: 100), endPoint: CGPoint(x: 20, y: 190), time: 1) == .correctManualPath)
    assert(validator.validateSwipe(startPoint: CGPoint(x: 100, y: 100), endPoint: CGPoint(x: 118, y: 180), time: 1) == .wrongAIRoute)
    assert(validator.validateSwipe(startPoint: CGPoint(x: 100, y: 100), endPoint: CGPoint(x: 180, y: 120), time: 1) == .wrongDirection)
    assert(validator.validateSwipe(startPoint: CGPoint(x: 100, y: 100), endPoint: CGPoint(x: 92, y: 70), time: 1) == .weakSwipe)

    validator = PathSwipeValidator()
    validator.startLevel(at: 10)
    assert(validator.validateTap(target: .blueAIRoute, time: 11) == .trapSelected(target: .blueAIRoute))
    assert(validator.validateTap(target: .autonomousChair, time: 11) == .trapSelected(target: .autonomousChair))
    assert(validator.validateTap(target: .aiWallScreen, time: 11) == .trapSelected(target: .aiWallScreen))
    assert(validator.validateTap(target: .followRouteButton, time: 11) == .trapSelected(target: .followRouteButton))
    assert(validator.validateTap(target: .empty, time: 11) == nil)

    validator = PathSwipeValidator()
    validator.startLevel(at: 20)
    assert(validator.checkTimeouts(currentTime: 24.1) == .noInputTimeout)

    validator = PathSwipeValidator()
    validator.startLevel(at: 30)
    assert(validator.checkTimeouts(currentTime: 38.1) == .totalTimeout)
}
#endif
