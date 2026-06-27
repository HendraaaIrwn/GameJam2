#if DEBUG
import CoreGraphics

func runNOVAStabilizationValidatorSelfCheck() {
    let validator = NOVAStabilizationValidator()
    validator.startLevel(at: 0)
    assert(validator.beginDrag(target: .nova, startPoint: .zero, time: 0.1) == .novaDragStarted)

    if case let .stabilizing(progress, stableTime) = validator.updateDrag(novaPosition: .zero, signalCenter: .zero, resetZoneCenter: CGPoint(x: 300, y: 300), time: 1.1) {
        assert(progress > 0)
        assert(stableTime > 0)
    } else {
        assertionFailure("Expected stabilizing")
    }

    assert(validator.updateDrag(novaPosition: .zero, signalCenter: .zero, resetZoneCenter: CGPoint(x: 300, y: 300), time: 3.2) == .novaStabilized)

    let reset = NOVAStabilizationValidator()
    reset.startLevel(at: 0)
    _ = reset.beginDrag(target: .novaHitbox, startPoint: .zero, time: 0.1)
    assert(reset.updateDrag(novaPosition: .zero, signalCenter: CGPoint(x: 300, y: 300), resetZoneCenter: .zero, time: 0.2) == .enteredResetZone)

    let released = NOVAStabilizationValidator()
    released.startLevel(at: 0)
    _ = released.beginDrag(target: .nova, startPoint: .zero, time: 0.1)
    assert(released.endDrag(novaPosition: CGPoint(x: 200, y: 200), signalCenter: .zero, resetZoneCenter: CGPoint(x: 300, y: 300), time: 0.2) == .releasedTooEarly)

    let grace = NOVAStabilizationValidator()
    grace.startLevel(at: 0)
    _ = grace.beginDrag(target: .nova, startPoint: .zero, time: 0.1)
    _ = grace.endDrag(novaPosition: .zero, signalCenter: .zero, resetZoneCenter: CGPoint(x: 300, y: 300), time: 0.2)
    assert(grace.checkTimeouts(currentTime: 1.1) == .releasedTooEarly)

    let trap = NOVAStabilizationValidator()
    trap.startLevel(at: 0)
    assert(trap.validateTap(target: .resetNOVAButton, time: 0.1) == .trapSelected(target: .resetNOVAButton))
    assert(trap.validateTap(target: .blueResetZone, time: 0.2) == .trapSelected(target: .blueResetZone))
    assert(trap.validateTap(target: .aiWallScreen, time: 0.3) == .trapSelected(target: .aiWallScreen))
    assert(trap.validateTap(target: .raka, time: 0.4) == .ignoredTarget(target: .raka))
    assert(trap.validateTap(target: .manualProtocolTerminal, time: 0.5) == .ignoredTarget(target: .manualProtocolTerminal))
    assert(trap.validateTap(target: .empty, time: 0.6) == nil)

    let noInput = NOVAStabilizationValidator()
    noInput.startLevel(at: 0)
    assert(noInput.checkTimeouts(currentTime: 4.1) == .noInputTimeout)

    let total = NOVAStabilizationValidator()
    total.startLevel(at: 0)
    _ = total.beginDrag(target: .nova, startPoint: .zero, time: 0.1)
    assert(total.checkTimeouts(currentTime: 10.1) == .totalTimeout)

    validator.reset()
    assert(!validator.hasReceivedInput)
    assert(!validator.isDraggingNOVA)
}
#endif
