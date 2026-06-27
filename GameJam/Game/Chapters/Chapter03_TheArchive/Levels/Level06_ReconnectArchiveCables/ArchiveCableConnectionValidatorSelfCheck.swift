#if DEBUG
import CoreGraphics

func runArchiveCableConnectionValidatorSelfCheck() {
    let validator = ArchiveCableConnectionValidator()
    validator.startLevel(at: 0)
    assert(validator.beginDrag(target: .yellowManualCablePlug, cableType: .yellowManualCable, startPoint: .zero, time: 0.1) == .cableDragStarted(type: .yellowManualCable))
    assert(validator.updateDrag(cableType: .yellowManualCable, currentPoint: CGPoint(x: 10, y: 20), time: 0.2) == .cableDragging(type: .yellowManualCable, position: CGPoint(x: 10, y: 20)))
    assert(validator.endDrag(cableType: .yellowManualCable, endPoint: .zero, manualBroadcastPortPoint: .zero, aiOutputPortPoint: CGPoint(x: 200, y: 200), time: 0.3) == .manualCableConnected)

    let blueManual = ArchiveCableConnectionValidator()
    blueManual.startLevel(at: 0)
    _ = blueManual.beginDrag(target: .blueAICablePlug, cableType: .blueAICable, startPoint: .zero, time: 0.1)
    assert(blueManual.endDrag(cableType: .blueAICable, endPoint: .zero, manualBroadcastPortPoint: .zero, aiOutputPortPoint: CGPoint(x: 200, y: 200), time: 0.2) == .wrongCableConnected(type: .blueAICable, target: .manualBroadcastPort))

    let yellowAI = ArchiveCableConnectionValidator()
    yellowAI.startLevel(at: 0)
    _ = yellowAI.beginDrag(target: .yellowManualCablePlug, cableType: .yellowManualCable, startPoint: .zero, time: 0.1)
    assert(yellowAI.endDrag(cableType: .yellowManualCable, endPoint: .zero, manualBroadcastPortPoint: CGPoint(x: 200, y: 200), aiOutputPortPoint: .zero, time: 0.2) == .wrongCableConnected(type: .yellowManualCable, target: .aiOutputPort))

    let reset = ArchiveCableConnectionValidator()
    reset.startLevel(at: 0)
    _ = reset.beginDrag(target: .blueAICablePlug, cableType: .blueAICable, startPoint: .zero, time: 0.1)
    assert(reset.endDrag(cableType: .blueAICable, endPoint: .zero, manualBroadcastPortPoint: CGPoint(x: 200, y: 200), aiOutputPortPoint: CGPoint(x: 300, y: 300), time: 0.2) == .cableReset(type: .blueAICable))

    let trap = ArchiveCableConnectionValidator()
    trap.startLevel(at: 0)
    assert(trap.validateTap(target: .autoConnectButton, time: 0.1) == .trapSelected(target: .autoConnectButton))
    assert(trap.validateTap(target: .blueRecommendationPanel, time: 0.2) == .trapSelected(target: .blueRecommendationPanel))
    assert(trap.validateTap(target: .aiOutputPort, time: 0.3) == .trapSelected(target: .aiOutputPort))
    assert(trap.validateTap(target: .aiWallScreen, time: 0.4) == .trapSelected(target: .aiWallScreen))
    assert(trap.validateTap(target: .raka, time: 0.5) == .ignoredTarget(target: .raka))
    assert(trap.validateTap(target: .nova, time: 0.6) == .ignoredTarget(target: .nova))
    assert(trap.validateTap(target: .archiveAntenna, time: 0.7) == .ignoredTarget(target: .archiveAntenna))
    assert(trap.validateTap(target: .empty, time: 0.8) == nil)

    let noInput = ArchiveCableConnectionValidator()
    noInput.startLevel(at: 0)
    assert(noInput.checkTimeouts(currentTime: 4.1) == .noInputTimeout)

    let total = ArchiveCableConnectionValidator()
    total.startLevel(at: 0)
    _ = total.beginDrag(target: .yellowManualCablePlug, cableType: .yellowManualCable, startPoint: .zero, time: 0.1)
    assert(total.checkTimeouts(currentTime: 10.1) == .totalTimeout)

    validator.reset()
    assert(!validator.hasReceivedInput)
    assert(validator.draggingCableType == nil)
}
#endif
