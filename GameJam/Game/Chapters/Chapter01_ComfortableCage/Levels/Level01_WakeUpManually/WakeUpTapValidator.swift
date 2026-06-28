import Foundation

enum WakeUpFaceTapValidationResult: Equatable {
    case faceTapped(currentCount: Int, requiredCount: Int)
    case sequenceReset(currentCount: Int, requiredCount: Int)
    case rakaAwakened(currentCount: Int, requiredCount: Int)
    case ignoredTap
    case totalTimeout
}

final class WakeUpTapValidator {
    private var startTime: TimeInterval?
    private var lastInputTime: TimeInterval?
    private(set) var faceTapCount = 0

    func start(at time: TimeInterval) {
        startTime = time
        lastInputTime = nil
        faceTapCount = 0
    }

    func registerTap(isFaceTap: Bool, time: TimeInterval) -> WakeUpFaceTapValidationResult {
        guard startTime != nil else {
            start(at: time)
            return registerTap(isFaceTap: isFaceTap, time: time)
        }

        guard isFaceTap else { return .ignoredTap }
        let didReset: Bool
        if let lastInputTime, time - lastInputTime > WakeUpManuallyLevelConfig.maxTapGap {
            faceTapCount = 0
            didReset = true
        } else {
            didReset = false
        }

        lastInputTime = time
        faceTapCount += 1
        if faceTapCount >= WakeUpManuallyLevelConfig.requiredWakeTaps {
            return .rakaAwakened(currentCount: faceTapCount, requiredCount: WakeUpManuallyLevelConfig.requiredWakeTaps)
        }
        if didReset {
            return .sequenceReset(currentCount: faceTapCount, requiredCount: WakeUpManuallyLevelConfig.requiredWakeTaps)
        }
        return .faceTapped(currentCount: faceTapCount, requiredCount: WakeUpManuallyLevelConfig.requiredWakeTaps)
    }

    func checkTimeouts(currentTime: TimeInterval) -> WakeUpFaceTapValidationResult? {
        guard let startTime else { return nil }
        if currentTime - startTime >= WakeUpManuallyLevelConfig.totalTimeLimit { return .totalTimeout }
        return nil
    }

    func reset() {
        startTime = nil
        lastInputTime = nil
        faceTapCount = 0
    }
}
