import CoreGraphics
import Foundation

enum NOVAStabilizationTarget: String, Codable, Equatable {
    case nova
    case novaHitbox
    case yellowSignalCircle
    case blueResetZone
    case resetNOVAButton
    case aiWallScreen
    case raka
    case manualProtocolTerminal
    case empty
}

enum NOVAStabilizationValidationResult: Equatable {
    case novaDragStarted
    case stabilizing(progress: CGFloat, stableTime: TimeInterval)
    case unstable(progress: CGFloat)
    case novaStabilized
    case enteredResetZone
    case releasedTooEarly
    case trapSelected(target: NOVAStabilizationTarget)
    case ignoredTarget(target: NOVAStabilizationTarget)
    case noInputTimeout
    case totalTimeout
}

final class NOVAStabilizationValidator {
    private let noInputTimeout = StabilizeNOVALevelConfig.noInputTimeout
    private let totalTimeLimit = StabilizeNOVALevelConfig.totalTimeLimit
    private let requiredStableDuration = StabilizeNOVALevelConfig.requiredStableDuration
    private let releaseGraceDuration = StabilizeNOVALevelConfig.releaseGraceDuration
    private let signalRadius = StabilizeNOVALevelConfig.signalRadius
    private let resetZoneRadius = StabilizeNOVALevelConfig.resetZoneRadius

    private var levelStartTime: TimeInterval?
    private var lastInputTime: TimeInterval?
    private var lastReleaseTime: TimeInterval?
    private(set) var hasReceivedInput = false
    private(set) var isDraggingNOVA = false
    private(set) var stableAccumulatedTime: TimeInterval = 0
    private var lastUpdateTime: TimeInterval?

    func startLevel(at time: TimeInterval) {
        levelStartTime = time
        lastInputTime = time
        lastReleaseTime = nil
        hasReceivedInput = false
        isDraggingNOVA = false
        stableAccumulatedTime = 0
        lastUpdateTime = time
    }

    func beginDrag(target: NOVAStabilizationTarget, startPoint: CGPoint, time: TimeInterval) -> NOVAStabilizationValidationResult? {
        guard target == .nova || target == .novaHitbox else { return nil }
        hasReceivedInput = true
        isDraggingNOVA = true
        lastInputTime = time
        lastReleaseTime = nil
        lastUpdateTime = time
        return .novaDragStarted
    }

    func updateDrag(novaPosition: CGPoint, signalCenter: CGPoint, resetZoneCenter: CGPoint, time: TimeInterval) -> NOVAStabilizationValidationResult {
        hasReceivedInput = true
        lastInputTime = time
        let deltaTime = max(0, time - (lastUpdateTime ?? time))
        lastUpdateTime = time

        if distance(novaPosition, resetZoneCenter) <= resetZoneRadius { return .enteredResetZone }

        if distance(novaPosition, signalCenter) <= signalRadius {
            stableAccumulatedTime += deltaTime
            let progress = CGFloat(stableAccumulatedTime / requiredStableDuration).clamped(to: 0...1)
            if stableAccumulatedTime >= requiredStableDuration { return .novaStabilized }
            return .stabilizing(progress: progress, stableTime: stableAccumulatedTime)
        }

        stableAccumulatedTime = max(0, stableAccumulatedTime - deltaTime * 0.35)
        return .unstable(progress: CGFloat(stableAccumulatedTime / requiredStableDuration).clamped(to: 0...1))
    }

    func endDrag(novaPosition: CGPoint, signalCenter: CGPoint, resetZoneCenter: CGPoint, time: TimeInterval) -> NOVAStabilizationValidationResult? {
        guard isDraggingNOVA else { return nil }
        isDraggingNOVA = false
        lastInputTime = time
        lastReleaseTime = time
        if distance(novaPosition, resetZoneCenter) <= resetZoneRadius { return .enteredResetZone }
        if stableAccumulatedTime >= requiredStableDuration { return .novaStabilized }
        if distance(novaPosition, signalCenter) <= signalRadius { return .unstable(progress: CGFloat(stableAccumulatedTime / requiredStableDuration).clamped(to: 0...1)) }
        return .releasedTooEarly
    }

    func validateTap(target: NOVAStabilizationTarget, time: TimeInterval) -> NOVAStabilizationValidationResult? {
        switch target {
        case .resetNOVAButton, .blueResetZone, .aiWallScreen:
            hasReceivedInput = true
            lastInputTime = time
            return .trapSelected(target: target)
        case .raka, .manualProtocolTerminal, .yellowSignalCircle:
            hasReceivedInput = true
            lastInputTime = time
            return .ignoredTarget(target: target)
        case .nova, .novaHitbox, .empty:
            return nil
        }
    }

    func checkTimeouts(currentTime: TimeInterval) -> NOVAStabilizationValidationResult? {
        guard let levelStartTime else { return nil }
        if currentTime - levelStartTime >= totalTimeLimit { return .totalTimeout }
        if !hasReceivedInput, currentTime - levelStartTime > noInputTimeout { return .noInputTimeout }
        if let lastReleaseTime, currentTime - lastReleaseTime > releaseGraceDuration { return .releasedTooEarly }
        if let lastInputTime, currentTime - lastInputTime > noInputTimeout { return .noInputTimeout }
        return nil
    }

    func reset() {
        levelStartTime = nil
        lastInputTime = nil
        lastReleaseTime = nil
        hasReceivedInput = false
        isDraggingNOVA = false
        stableAccumulatedTime = 0
        lastUpdateTime = nil
    }

    private func distance(_ a: CGPoint, _ b: CGPoint) -> CGFloat {
        let dx = a.x - b.x
        let dy = a.y - b.y
        return sqrt(dx * dx + dy * dy)
    }
}

private extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}
