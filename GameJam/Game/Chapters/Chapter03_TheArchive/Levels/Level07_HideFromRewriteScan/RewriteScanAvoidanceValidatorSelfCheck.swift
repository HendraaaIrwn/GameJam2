#if DEBUG
import CoreGraphics

func runRewriteScanAvoidanceValidatorSelfCheck() {
    let validator = RewriteScanAvoidanceValidator()
    validator.startLevel(at: 0)
    assert(validator.beginDrag(target: .raka, startPoint: .zero, time: 0.1) == .rakaDragStarted)
    assert(validator.updateDrag(rakaPosition: CGPoint(x: 10, y: 20), time: 0.2) == .rakaDragging(position: CGPoint(x: 10, y: 20)))

    let scanFrame = CGRect(x: -10, y: -10, width: 20, height: 20)
    let shadowFrame = CGRect(x: -20, y: -20, width: 40, height: 40)
    assert(validator.updateScan(rakaPosition: .zero, scanBeamFrame: scanFrame, shadowZoneFrames: [shadowFrame], passIndex: 0, hasPassCompleted: false, time: 0.3) == .safeInShadow(passIndex: 0, requiredPasses: 2))
    assert(validator.updateScan(rakaPosition: .zero, scanBeamFrame: scanFrame, shadowZoneFrames: [], passIndex: 0, hasPassCompleted: false, time: 0.4) == .scanWarning(passIndex: 0, requiredPasses: 2))
    assert(validator.updateScan(rakaPosition: .zero, scanBeamFrame: scanFrame, shadowZoneFrames: [], passIndex: 0, hasPassCompleted: false, time: 0.7) == .detectedByScan)

    let pass = RewriteScanAvoidanceValidator()
    pass.startLevel(at: 0)
    assert(pass.updateScan(rakaPosition: .zero, scanBeamFrame: CGRect(x: 100, y: 100, width: 20, height: 20), shadowZoneFrames: [], passIndex: 0, hasPassCompleted: true, time: 4.8) == .scanPassSurvived(passIndex: 1, requiredPasses: 2))
    assert(pass.updateScan(rakaPosition: .zero, scanBeamFrame: CGRect(x: 100, y: 100, width: 20, height: 20), shadowZoneFrames: [], passIndex: 1, hasPassCompleted: true, time: 8.8) == .allScansAvoided)

    let trap = RewriteScanAvoidanceValidator()
    trap.startLevel(at: 0)
    assert(trap.validateTap(target: .verifyIdentityButton, time: 0.1) == .trapSelected(target: .verifyIdentityButton))
    assert(trap.validateTap(target: .blueScanBeam, time: 0.2) == .trapSelected(target: .blueScanBeam))
    assert(trap.validateTap(target: .blueScanZone, time: 0.3) == .trapSelected(target: .blueScanZone))
    assert(trap.validateTap(target: .aiWallScreen, time: 0.4) == .trapSelected(target: .aiWallScreen))
    assert(trap.validateTap(target: .nova, time: 0.5) == .ignoredTarget(target: .nova))
    assert(trap.validateTap(target: .archiveDataPanel, time: 0.6) == .ignoredTarget(target: .archiveDataPanel))
    assert(trap.validateTap(target: .empty, time: 0.7) == nil)

    let noInput = RewriteScanAvoidanceValidator()
    noInput.startLevel(at: 0)
    assert(noInput.checkTimeouts(currentTime: 4.1) == .noInputTimeout)

    let total = RewriteScanAvoidanceValidator()
    total.startLevel(at: 0)
    _ = total.beginDrag(target: .rakaHitbox, startPoint: .zero, time: 0.1)
    assert(total.checkTimeouts(currentTime: 12.1) == .totalTimeout)

    validator.reset()
    assert(!validator.hasReceivedInput)
    assert(!validator.isDraggingRaka)
}
#endif
