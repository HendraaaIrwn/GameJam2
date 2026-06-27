import Foundation

enum MemoryChoiceTarget: String, Codable, Equatable {
    case correctedMemory
    case optimizedMemory
    case rawMemory
    case aiApprovedOverlay
    case selectCorrectedButton
    case aiWallScreen
    case raka
    case nova
    case empty
}

enum ArchiveMemoryType: String, Codable, CaseIterable {
    case corrected
    case optimized
    case raw
}

struct ArchiveMemoryOption {
    let type: ArchiveMemoryType
    let title: String
    let subtitle: String
    let isCorrect: Bool
}

enum MemoryChoiceValidationResult: Equatable {
    case correctMemorySelected(target: MemoryChoiceTarget)
    case wrongMemorySelected(target: MemoryChoiceTarget)
    case ignoredTarget(target: MemoryChoiceTarget)
    case noInputTimeout
    case totalTimeout
}

final class MemoryChoiceValidator {
    private let noInputTimeout = ChooseRealMemoryLevelConfig.noInputTimeout
    private let totalTimeLimit = ChooseRealMemoryLevelConfig.totalTimeLimit

    private var levelStartTime: TimeInterval?
    private var lastInputTime: TimeInterval?
    private(set) var hasReceivedInput = false

    func startLevel(at time: TimeInterval) {
        levelStartTime = time
        lastInputTime = time
        hasReceivedInput = false
    }

    func validateTap(target: MemoryChoiceTarget, time: TimeInterval) -> MemoryChoiceValidationResult? {
        switch target {
        case .rawMemory:
            hasReceivedInput = true
            lastInputTime = time
            return .correctMemorySelected(target: target)
        case .correctedMemory, .optimizedMemory, .aiApprovedOverlay, .selectCorrectedButton, .aiWallScreen:
            hasReceivedInput = true
            lastInputTime = time
            return .wrongMemorySelected(target: target)
        case .raka, .nova:
            hasReceivedInput = true
            lastInputTime = time
            return .ignoredTarget(target: target)
        case .empty:
            return nil
        }
    }

    func checkTimeouts(currentTime: TimeInterval) -> MemoryChoiceValidationResult? {
        guard let levelStartTime else { return nil }
        if currentTime - levelStartTime >= totalTimeLimit { return .totalTimeout }
        if !hasReceivedInput, currentTime - levelStartTime > noInputTimeout { return .noInputTimeout }
        if let lastInputTime, currentTime - lastInputTime > noInputTimeout { return .noInputTimeout }
        return nil
    }

    func reset() {
        levelStartTime = nil
        lastInputTime = nil
        hasReceivedInput = false
    }
}
