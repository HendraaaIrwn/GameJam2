#if DEBUG
import CoreGraphics

func runManualRouteTraceValidatorSelfCheck() {
    let start = CGPoint(x: 40, y: 40)
    let door = CGPoint(x: 300, y: 400)
    let pod = CGPoint(x: 320, y: 80)
    let checkpoints = [
        CGPoint(x: 90, y: 120),
        CGPoint(x: 145, y: 200),
        CGPoint(x: 210, y: 280),
        CGPoint(x: 270, y: 350)
    ]
    let aiRoute = [CGPoint(x: 140, y: 80), CGPoint(x: 220, y: 80), pod]

    var validator = ManualRouteTraceValidator()
    validator.startLevel(at: 0)
    assert(validator.beginTrace(at: start, startPoint: start, time: 0.2) == .traceStarted)
    assert(validator.updateTrace(at: checkpoints[0], checkpoints: checkpoints, aiRoutePoints: aiRoute, time: 0.4) == .checkpointReached(index: 1, total: 4))
    assert(validator.updateTrace(at: checkpoints[1], checkpoints: checkpoints, aiRoutePoints: aiRoute, time: 0.6) == .checkpointReached(index: 2, total: 4))
    assert(validator.updateTrace(at: checkpoints[2], checkpoints: checkpoints, aiRoutePoints: aiRoute, time: 0.8) == .checkpointReached(index: 3, total: 4))
    assert(validator.updateTrace(at: checkpoints[3], checkpoints: checkpoints, aiRoutePoints: aiRoute, time: 1.0) == .checkpointReached(index: 4, total: 4))
    assert(validator.endTrace(at: door, doorPoint: door, comfortPodPoint: pod, time: 1.2) == .correctRouteCompleted)

    validator = ManualRouteTraceValidator()
    validator.startLevel(at: 10)
    assert(validator.beginTrace(at: CGPoint(x: 160, y: 160), startPoint: start, time: 10.2) == .invalidStart)

    validator = ManualRouteTraceValidator()
    validator.startLevel(at: 20)
    assert(validator.beginTrace(at: start, startPoint: start, time: 20.2) == .traceStarted)
    assert(validator.endTrace(at: checkpoints[0], doorPoint: door, comfortPodPoint: pod, time: 20.6) == .releasedTooEarly)

    validator = ManualRouteTraceValidator()
    validator.startLevel(at: 30)
    assert(validator.beginTrace(at: start, startPoint: start, time: 30.2) == .traceStarted)
    assert(validator.endTrace(at: pod, doorPoint: door, comfortPodPoint: pod, time: 30.6) == .wrongDestination)

    validator = ManualRouteTraceValidator()
    validator.startLevel(at: 40)
    assert(validator.beginTrace(at: start, startPoint: start, time: 40.2) == .traceStarted)
    assert(validator.updateTrace(at: CGPoint(x: 140, y: 80), checkpoints: checkpoints, aiRoutePoints: aiRoute, time: 40.6) == .aiRouteSelected)

    validator = ManualRouteTraceValidator()
    validator.startLevel(at: 50)
    assert(validator.registerTapOnTrap(target: .aiRoute, time: 50.2) == .aiRouteSelected)
    assert(validator.registerTapOnTrap(target: .autoNavigateButton, time: 50.4) == .aiRouteSelected)
    assert(validator.registerTapOnTrap(target: .aiWallScreen, time: 50.6) == .aiRouteSelected)
    assert(validator.registerTapOnTrap(target: .comfortPod, time: 50.8) == .wrongDestination)

    validator = ManualRouteTraceValidator()
    validator.startLevel(at: 60)
    assert(validator.checkTimeouts(currentTime: 65.1) == .noInputTimeout)

    validator = ManualRouteTraceValidator()
    validator.startLevel(at: 70)
    assert(validator.checkTimeouts(currentTime: 82.1) == .totalTimeout)
}
#endif
