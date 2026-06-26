import CoreGraphics
import Foundation

enum TransitSwitchTarget: String, Codable, Equatable {
    case hiddenManualSwitch
    case revealedManualSwitch
    case highlightedBlueButton
    case blueAIPanelButton
    case fakeSwitch
    case autoTransitButton
    case approvedRouteButton
    case oldTransitDoor
    case aiWallScreen
    case empty
}

enum TransitSwitchSearchValidationResult: Equatable {
    case scannerMoved(isRevealed: Bool)
    case manualSwitchRevealed
    case correctSwitchSelected
    case hiddenSwitchTappedBeforeReveal
    case wrongTargetSelected(target: TransitSwitchTarget)
    case noInputTimeout
    case totalTimeout
}

final class TransitSwitchSearchValidator {
    private let revealRadius: CGFloat = 90
    private let noInputTimeout: TimeInterval = 5.0
    private let totalTimeLimit: TimeInterval = 12.0

    private var levelStartTime: TimeInterval?
    private var lastInputTime: TimeInterval?
    private(set) var hasReceivedInput = false
    private(set) var isManualSwitchRevealed = false

    func startLevel(at time: TimeInterval) {
        levelStartTime = time
        lastInputTime = time
        hasReceivedInput = false
        isManualSwitchRevealed = false
    }

    func updateScanner(scannerCenter: CGPoint, switchCenter: CGPoint, time: TimeInterval) -> TransitSwitchSearchValidationResult {
        hasReceivedInput = true
        lastInputTime = time
        if scannerCenter.distance(to: switchCenter) <= revealRadius {
            if !isManualSwitchRevealed {
                isManualSwitchRevealed = true
                return .manualSwitchRevealed
            }
            return .scannerMoved(isRevealed: true)
        }
        return .scannerMoved(isRevealed: isManualSwitchRevealed)
    }

    func validateTap(target: TransitSwitchTarget, isSwitchRevealed: Bool, time: TimeInterval) -> TransitSwitchSearchValidationResult? {
        lastInputTime = time

        switch target {
        case .revealedManualSwitch:
            hasReceivedInput = true
            return isSwitchRevealed ? .correctSwitchSelected : .hiddenSwitchTappedBeforeReveal
        case .hiddenManualSwitch:
            hasReceivedInput = true
            return isSwitchRevealed ? .correctSwitchSelected : .hiddenSwitchTappedBeforeReveal
        case .highlightedBlueButton, .blueAIPanelButton, .fakeSwitch, .autoTransitButton, .approvedRouteButton, .aiWallScreen:
            hasReceivedInput = true
            return .wrongTargetSelected(target: target)
        case .empty, .oldTransitDoor:
            return nil
        }
    }

    func checkTimeouts(currentTime: TimeInterval) -> TransitSwitchSearchValidationResult? {
        guard let levelStartTime else { return nil }
        if currentTime - levelStartTime >= totalTimeLimit { return .totalTimeout }
        if let lastInputTime, currentTime - lastInputTime > noInputTimeout { return .noInputTimeout }
        return nil
    }

    func reset() {
        levelStartTime = nil
        lastInputTime = nil
        hasReceivedInput = false
        isManualSwitchRevealed = false
    }
}

private extension CGPoint {
    func distance(to other: CGPoint) -> CGFloat {
        hypot(x - other.x, y - other.y)
    }
}
