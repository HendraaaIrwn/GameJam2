#if DEBUG
import CoreGraphics

func runHoldGestureValidatorSelfCheck() {
    let validator = HoldGestureValidator()
    validator.startLevel(at: 10)
    assert(validator.beginHold(at: .zero, time: 10, didStartOnCorrectTarget: true) == .holding(progress: 0))
    assert(validator.updateHold(at: .zero, time: 11.6) == .completed)

    validator.startLevel(at: 20)
    assert(validator.beginHold(at: .zero, time: 20, didStartOnCorrectTarget: false) == .wrongStart)

    validator.startLevel(at: 30)
    _ = validator.beginHold(at: .zero, time: 30, didStartOnCorrectTarget: true)
    assert(validator.endHold(at: 30.4) == .releasedTooEarly)

    validator.startLevel(at: 40)
    _ = validator.beginHold(at: .zero, time: 40, didStartOnCorrectTarget: true)
    assert(validator.updateHold(at: CGPoint(x: 42, y: 0), time: 40.2) == .movedTooFar)

    validator.startLevel(at: 50)
    assert(validator.checkTimeouts(currentTime: 54.1) == .noInputTimeout)
}
#endif
