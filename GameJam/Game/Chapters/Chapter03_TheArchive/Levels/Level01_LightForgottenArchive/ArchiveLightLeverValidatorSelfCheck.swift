#if DEBUG
import CoreGraphics

func runArchiveLightLeverValidatorSelfCheck() {
    let validator = ArchiveLightLeverValidator()
    validator.startLevel(at: 0)
    assert(validator.beginDrag(target: .manualLeverHandle, startPoint: .zero, time: 0.1) == .leverDragStarted)

    if case let .leverDragging(progress) = validator.updateDrag(currentPoint: CGPoint(x: 0, y: -45), time: 0.2) {
        assert(progress == 0.5)
    } else {
        assertionFailure("Expected lever progress")
    }

    assert(validator.updateDrag(currentPoint: CGPoint(x: 0, y: -90), time: 0.3) == .archiveLightRestored)

    let weak = ArchiveLightLeverValidator()
    weak.startLevel(at: 0)
    _ = weak.beginDrag(target: .manualLever, startPoint: .zero, time: 0.1)
    assert(weak.endDrag(endPoint: CGPoint(x: 0, y: -30), time: 0.2) == .weakLeverPull)

    let traps = ArchiveLightLeverValidator()
    traps.startLevel(at: 0)
    assert(traps.validateTap(target: .blueEmergencyLight, time: 0.1) == .trapSelected(target: .blueEmergencyLight))
    assert(traps.validateTap(target: .aiSafetyRoute, time: 0.2) == .trapSelected(target: .aiSafetyRoute))
    assert(traps.validateTap(target: .returnToSafetyButton, time: 0.3) == .trapSelected(target: .returnToSafetyButton))
    assert(traps.validateTap(target: .aiWallScreen, time: 0.4) == .trapSelected(target: .aiWallScreen))
    assert(traps.validateTap(target: .empty, time: 0.5) == nil)

    let noInput = ArchiveLightLeverValidator()
    noInput.startLevel(at: 0)
    assert(noInput.checkTimeouts(currentTime: 4.1) == .noInputTimeout)

    let total = ArchiveLightLeverValidator()
    total.startLevel(at: 0)
    _ = total.beginDrag(target: .manualLeverHandle, startPoint: .zero, time: 0.1)
    assert(total.checkTimeouts(currentTime: 8.1) == .totalTimeout)

    validator.reset()
    assert(!validator.hasReceivedInput)
    assert(!validator.isDraggingLever)
}
#endif
