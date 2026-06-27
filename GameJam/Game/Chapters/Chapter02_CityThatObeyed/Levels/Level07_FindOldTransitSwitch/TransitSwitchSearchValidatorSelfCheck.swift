#if DEBUG
import CoreGraphics
import Foundation

func runTransitSwitchSearchValidatorSelfCheck() {
    let validator = TransitSwitchSearchValidator()
    validator.startLevel(at: 0)
    assert(validator.updateScanner(scannerCenter: .zero, switchCenter: CGPoint(x: 120, y: 0), time: 0.1) == .scannerMoved(isRevealed: false))
    assert(validator.updateScanner(scannerCenter: CGPoint(x: 40, y: 0), switchCenter: CGPoint(x: 120, y: 0), time: 0.2) == .manualSwitchRevealed)
    assert(validator.isManualSwitchRevealed)
    assert(validator.validateTap(target: .revealedManualSwitch, isSwitchRevealed: true, time: 0.3) == .correctSwitchSelected)

    let hidden = TransitSwitchSearchValidator()
    hidden.startLevel(at: 0)
    assert(hidden.validateTap(target: .hiddenManualSwitch, isSwitchRevealed: false, time: 0.1) == .hiddenSwitchTappedBeforeReveal)

    assert(hidden.validateTap(target: .highlightedBlueButton, isSwitchRevealed: false, time: 0.2) == .wrongTargetSelected(target: .highlightedBlueButton))
    assert(hidden.validateTap(target: .blueAIPanelButton, isSwitchRevealed: false, time: 0.3) == .wrongTargetSelected(target: .blueAIPanelButton))
    assert(hidden.validateTap(target: .fakeSwitch, isSwitchRevealed: false, time: 0.4) == .wrongTargetSelected(target: .fakeSwitch))
    assert(hidden.validateTap(target: .autoTransitButton, isSwitchRevealed: false, time: 0.5) == .wrongTargetSelected(target: .autoTransitButton))
    assert(hidden.validateTap(target: .approvedRouteButton, isSwitchRevealed: false, time: 0.6) == .wrongTargetSelected(target: .approvedRouteButton))
    assert(hidden.validateTap(target: .aiWallScreen, isSwitchRevealed: false, time: 0.7) == .wrongTargetSelected(target: .aiWallScreen))
    assert(hidden.validateTap(target: .empty, isSwitchRevealed: false, time: 0.8) == nil)
    assert(hidden.validateTap(target: .oldTransitDoor, isSwitchRevealed: false, time: 0.9) == nil)

    let noInput = TransitSwitchSearchValidator()
    noInput.startLevel(at: 0)
    assert(noInput.checkTimeouts(currentTime: 5.1) == .noInputTimeout)

    let total = TransitSwitchSearchValidator()
    total.startLevel(at: 0)
    assert(total.checkTimeouts(currentTime: 12.1) == .totalTimeout)

    validator.reset()
    assert(!validator.hasReceivedInput)
    assert(!validator.isManualSwitchRevealed)
}
#endif
