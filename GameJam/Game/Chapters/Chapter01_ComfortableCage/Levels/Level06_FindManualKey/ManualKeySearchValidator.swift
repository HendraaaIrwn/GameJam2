import Foundation

enum KeyChoice: String, Codable, Equatable {
    case manualKey
    case aiKey
    case fakeKey
    case aiWallScreen
    case aiSuggestionButton
    case empty
}

enum ManualKeySearchValidationResult: Equatable {
    case searching
    case manualKeyRevealed
    case correctKeySelected
    case wrongKeySelected(choice: KeyChoice)
    case manualKeyTappedBeforeReveal
    case noInputTimeout
    case totalTimeout
}

final class ManualKeySearchValidator {
    private let noInputTimeout: TimeInterval = 5.0
    private let totalTimeLimit: TimeInterval = 12.0

    private var levelStartTime: TimeInterval?
    private var lastInputTime: TimeInterval?
    private(set) var hasRevealedManualKey = false
    private(set) var hasReceivedInput = false

    func startLevel(at time: TimeInterval) {
        levelStartTime = time
        lastInputTime = time
        hasRevealedManualKey = false
        hasReceivedInput = false
    }

    func recordDrag(at time: TimeInterval, didRevealManualKey: Bool) -> ManualKeySearchValidationResult {
        hasReceivedInput = true
        lastInputTime = time

        if didRevealManualKey && !hasRevealedManualKey {
            hasRevealedManualKey = true
            return .manualKeyRevealed
        }

        return .searching
    }

    func select(choice: KeyChoice, at time: TimeInterval) -> ManualKeySearchValidationResult {
        hasReceivedInput = true
        lastInputTime = time

        switch choice {
        case .manualKey where hasRevealedManualKey:
            return .correctKeySelected
        case .manualKey:
            return .manualKeyTappedBeforeReveal
        case .empty:
            return .searching
        default:
            return .wrongKeySelected(choice: choice)
        }
    }

    func checkTimeouts(currentTime: TimeInterval) -> ManualKeySearchValidationResult? {
        guard let levelStartTime else { return nil }
        if currentTime - levelStartTime >= totalTimeLimit { return .totalTimeout }
        if let lastInputTime, currentTime - lastInputTime > noInputTimeout { return .noInputTimeout }
        return nil
    }

    func reset() {
        levelStartTime = nil
        lastInputTime = nil
        hasRevealedManualKey = false
        hasReceivedInput = false
    }
}
