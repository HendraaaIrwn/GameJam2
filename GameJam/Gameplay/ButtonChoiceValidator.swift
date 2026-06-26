import Foundation

enum FinalChoiceButton: String, Codable, Equatable {
    case redManualOverride
    case greenSafe
    case blueAuto
    case cyanOptimize
    case door
    case aiWallScreen
    case empty
}

enum ButtonChoiceValidationResult: Equatable {
    case correctChoice(button: FinalChoiceButton)
    case wrongChoice(button: FinalChoiceButton)
    case noInputTimeout
    case totalTimeout
}

final class ButtonChoiceValidator {
    private let noInputTimeout: TimeInterval = 4.0
    private let totalTimeLimit: TimeInterval = 8.0

    private var levelStartTime: TimeInterval?
    private var lastInputTime: TimeInterval?
    private var hasReceivedInput = false

    func startLevel(at time: TimeInterval) {
        levelStartTime = time
        lastInputTime = time
        hasReceivedInput = false
    }

    func validateTap(button: FinalChoiceButton, time: TimeInterval) -> ButtonChoiceValidationResult? {
        guard button != .empty else { return nil }
        hasReceivedInput = true
        lastInputTime = time

        if button == .redManualOverride {
            return .correctChoice(button: button)
        }

        return .wrongChoice(button: button)
    }

    func checkTimeouts(currentTime: TimeInterval) -> ButtonChoiceValidationResult? {
        guard let levelStartTime else { return nil }
        if currentTime - levelStartTime >= totalTimeLimit { return .totalTimeout }
        if let lastInputTime, currentTime - lastInputTime > noInputTimeout { return .noInputTimeout }
        return nil
    }

    func reset() {
        levelStartTime = nil
        lastInputTime = nil
        hasReceivedInput = false
    }
}
