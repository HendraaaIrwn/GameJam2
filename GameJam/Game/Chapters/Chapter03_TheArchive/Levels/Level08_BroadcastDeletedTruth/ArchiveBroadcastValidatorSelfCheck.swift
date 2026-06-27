#if DEBUG
import CoreGraphics

func runArchiveBroadcastValidatorSelfCheck() {
    let validator = ArchiveBroadcastValidator()
    validator.startLevel(at: 0)
    assert(validator.beginTouch(target: .broadcastSwitch, startPoint: .zero, time: 0.1) == .switchHoldStarted)
    if case let .switchHolding(progress)? = validator.updateHold(target: .broadcastSwitch, time: 0.5) {
        assert(progress > 0)
    } else {
        assertionFailure("Expected switch hold progress")
    }
    assert(validator.updateHold(target: .broadcastSwitch, time: 1.2) == .switchHoldCompleted)
    assert(validator.beginSliderDrag(target: .signalSlider, startPoint: .zero, time: 1.3) == .sliderDragStarted)
    assert(validator.endSliderDrag(sliderPosition: .zero, yellowZoneCenter: .zero, blueZoneCenter: CGPoint(x: 200, y: 200), time: 1.4) == .sliderPlacedInYellowZone)
    assert(validator.validateTap(target: .sendRawArchiveButton, time: 1.5) == .rawArchiveSent)

    let earlyRelease = ArchiveBroadcastValidator()
    earlyRelease.startLevel(at: 0)
    _ = earlyRelease.beginTouch(target: .broadcastSwitch, startPoint: .zero, time: 0.1)
    assert(earlyRelease.endHold(target: .broadcastSwitch, time: 0.3) == .switchHolding(progress: 0))

    let premature = ArchiveBroadcastValidator()
    premature.startLevel(at: 0)
    assert(premature.validateTap(target: .sendRawArchiveButton, time: 0.1) == .prematureSend)
    assert(premature.beginSliderDrag(target: .signalSlider, startPoint: .zero, time: 0.2) == .ignoredTarget(target: .signalSlider))

    let blue = ArchiveBroadcastValidator()
    blue.startLevel(at: 0)
    _ = blue.beginTouch(target: .broadcastSwitch, startPoint: .zero, time: 0.1)
    _ = blue.updateHold(target: .broadcastSwitch, time: 1.2)
    _ = blue.beginSliderDrag(target: .signalSlider, startPoint: .zero, time: 1.3)
    assert(blue.endSliderDrag(sliderPosition: .zero, yellowZoneCenter: CGPoint(x: 200, y: 200), blueZoneCenter: .zero, time: 1.4) == .sliderPlacedInBlueZone)

    let trap = ArchiveBroadcastValidator()
    trap.startLevel(at: 0)
    assert(trap.validateTap(target: .cleanVersionButton, time: 0.1) == .trapSelected(target: .cleanVersionButton))
    assert(trap.validateTap(target: .cancelBroadcastButton, time: 0.2) == .trapSelected(target: .cancelBroadcastButton))
    assert(trap.validateTap(target: .blueAIZone, time: 0.3) == .trapSelected(target: .blueAIZone))
    assert(trap.validateTap(target: .aiWallScreen, time: 0.4) == .trapSelected(target: .aiWallScreen))
    assert(trap.validateTap(target: .raka, time: 0.5) == .ignoredTarget(target: .raka))
    assert(trap.validateTap(target: .nova, time: 0.6) == .ignoredTarget(target: .nova))
    assert(trap.validateTap(target: .empty, time: 0.7) == nil)

    let noInput = ArchiveBroadcastValidator()
    noInput.startLevel(at: 0)
    assert(noInput.checkTimeouts(currentTime: 5.1) == .noInputTimeout)

    let total = ArchiveBroadcastValidator()
    total.startLevel(at: 0)
    _ = total.beginTouch(target: .broadcastSwitch, startPoint: .zero, time: 0.1)
    assert(total.checkTimeouts(currentTime: 14.1) == .totalTimeout)

    validator.reset()
    assert(!validator.hasReceivedInput)
    assert(validator.currentStep == .holdSwitch)
}
#endif
