import CoreGraphics
import Foundation

enum BridgeTrapTarget: String, Codable, Equatable {
    case autoPathButton
    case blueAIRoute
    case aiWallScreen
    case manualBridge
    case raka
    case empty
}

enum BridgeBalanceValidationResult: Equatable {
    case balancing(balanceValue: CGFloat, safeProgress: CGFloat, dangerProgress: CGFloat)
    case success
    case fellLeft
    case fellRight
    case trapSelected(target: BridgeTrapTarget)
    case noInputTimeout
    case totalTimeout
}

final class BridgeBalanceValidator {
    private let noInputTimeout: TimeInterval = 4.0
    private let totalTimeLimit: TimeInterval = 10.0
    private let requiredSafeTime: TimeInterval = 4.0
    private let safeThreshold: CGFloat = 0.28
    private let failThreshold: CGFloat = 0.9
    private let meaningfulInputThreshold: CGFloat = 0.08

    private var levelStartTime: TimeInterval?
    private var lastInputTime: TimeInterval?
    private var lastUpdateTime: TimeInterval?
    private(set) var balanceValue: CGFloat = 0
    private(set) var safeTime: TimeInterval = 0

    func startLevel(at time: TimeInterval) {
        levelStartTime = time
        lastInputTime = time
        lastUpdateTime = time
        balanceValue = 0
        safeTime = 0
    }

    func validateTrap(target: BridgeTrapTarget, time: TimeInterval) -> BridgeBalanceValidationResult? {
        guard target == .autoPathButton || target == .blueAIRoute || target == .aiWallScreen else { return nil }
        lastInputTime = time
        return .trapSelected(target: target)
    }

    func update(tiltInput: CGFloat, aiPush: CGFloat, currentTime: TimeInterval) -> BridgeBalanceValidationResult {
        guard let levelStartTime else { return .balancing(balanceValue: balanceValue, safeProgress: 0, dangerProgress: 0) }

        if currentTime - levelStartTime >= totalTimeLimit { return .totalTimeout }
        if abs(tiltInput) > meaningfulInputThreshold { lastInputTime = currentTime }
        if let lastInputTime, currentTime - lastInputTime > noInputTimeout { return .noInputTimeout }

        let deltaTime = CGFloat(max(currentTime - (lastUpdateTime ?? currentTime), 0))
        lastUpdateTime = currentTime
        balanceValue += aiPush * deltaTime
        balanceValue -= tiltInput * 1.8 * deltaTime
        balanceValue *= 0.96
        balanceValue = balanceValue.clamped(to: -1.2...1.2)

        if balanceValue <= -failThreshold { return .fellLeft }
        if balanceValue >= failThreshold { return .fellRight }

        if abs(balanceValue) <= safeThreshold {
            safeTime += TimeInterval(deltaTime)
        }

        if safeTime >= requiredSafeTime { return .success }

        return .balancing(
            balanceValue: balanceValue,
            safeProgress: CGFloat(safeTime / requiredSafeTime).clamped(to: 0...1),
            dangerProgress: (abs(balanceValue) / failThreshold).clamped(to: 0...1)
        )
    }

    func reset() {
        levelStartTime = nil
        lastInputTime = nil
        lastUpdateTime = nil
        balanceValue = 0
        safeTime = 0
    }
}

private extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}
