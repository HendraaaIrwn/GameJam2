import Foundation

enum ManualKeyTableTarget: String, Codable, Equatable {
    case manualKey
    case smartKey
    case brokenCable
    case oldPhoto
    case redChip
    case toyDoll
    case table
    case aiWallScreen
    case blueKeyHintButton
    case empty
}

enum ManualKeySearchValidationResult: Equatable {
    case manualKeySelected
    case smartKeySelected
    case distractionSelected(target: ManualKeyTableTarget)
    case trapSelected(target: ManualKeyTableTarget)
    case noInputTimeout
    case totalTimeout
}

final class ManualKeySearchValidator {
    private let noInputTimeout: TimeInterval
    private let totalTimeLimit: TimeInterval

    private var levelStartTime: TimeInterval?
    private var lastInputTime: TimeInterval?

    init(
        noInputTimeout: TimeInterval = FindManualKeyLevelConfig.noInputTimeout,
        totalTimeLimit: TimeInterval = FindManualKeyLevelConfig.totalTimeLimit
    ) {
        self.noInputTimeout = noInputTimeout
        self.totalTimeLimit = totalTimeLimit
    }

    func startLevel(at time: TimeInterval) {
        levelStartTime = time
        lastInputTime = time
    }

    func validateTap(target: ManualKeyTableTarget, time: TimeInterval) -> ManualKeySearchValidationResult? {
        lastInputTime = time

        switch target {
        case .manualKey:
            return .manualKeySelected
        case .smartKey:
            return .smartKeySelected
        case .blueKeyHintButton, .aiWallScreen:
            return .trapSelected(target: target)
        case .brokenCable, .oldPhoto, .redChip, .toyDoll, .table:
            return .distractionSelected(target: target)
        case .empty:
            return nil
        }
    }

    func checkTimeouts(currentTime: TimeInterval) -> ManualKeySearchValidationResult? {
        guard let levelStartTime else { return nil }
        if currentTime - levelStartTime >= totalTimeLimit {
            return .totalTimeout
        }
        if let lastInputTime, currentTime - lastInputTime >= noInputTimeout {
            return .noInputTimeout
        }
        return nil
    }

    func reset() {
        levelStartTime = nil
        lastInputTime = nil
    }
}
