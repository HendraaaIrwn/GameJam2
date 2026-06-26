import CoreGraphics
import Foundation

enum HoldGestureValidationResult: Equatable {
    case holding(progress: CGFloat)
    case completed
    case releasedTooEarly
    case movedTooFar
    case wrongStart
    case noInputTimeout
    case totalTimeout
}

final class HoldGestureValidator {
    private let requiredHoldDuration: TimeInterval = 1.5
    private let noInputTimeout: TimeInterval = 4.0
    private let maxAllowedDrift: CGFloat = 40

    private var levelStartTime: TimeInterval?
    private var holdStartTime: TimeInterval?
    private var startPoint: CGPoint?
    private var isHolding = false
    private var hasReceivedInput = false

    func startLevel(at time: TimeInterval) {
        levelStartTime = time
        holdStartTime = nil
        startPoint = nil
        isHolding = false
        hasReceivedInput = false
    }

    func beginHold(at point: CGPoint, time: TimeInterval, didStartOnCorrectTarget: Bool) -> HoldGestureValidationResult? {
        hasReceivedInput = true
        guard didStartOnCorrectTarget else { return .wrongStart }
        holdStartTime = time
        startPoint = point
        isHolding = true
        return .holding(progress: 0)
    }

    func updateHold(at point: CGPoint, time: TimeInterval) -> HoldGestureValidationResult {
        guard isHolding, let holdStartTime, let startPoint else { return .releasedTooEarly }

        let drift = hypot(point.x - startPoint.x, point.y - startPoint.y)
        if drift > maxAllowedDrift {
            isHolding = false
            return .movedTooFar
        }

        let progress = min((time - holdStartTime) / requiredHoldDuration, 1.0)
        if progress >= 1 {
            isHolding = false
            return .completed
        }

        return .holding(progress: progress)
    }

    func endHold(at time: TimeInterval) -> HoldGestureValidationResult? {
        guard isHolding, let holdStartTime else { return nil }
        isHolding = false
        let progress = min((time - holdStartTime) / requiredHoldDuration, 1.0)
        return progress >= 1 ? .completed : .releasedTooEarly
    }

    func checkTimeouts(currentTime: TimeInterval) -> HoldGestureValidationResult? {
        guard let levelStartTime else { return nil }
        if !hasReceivedInput && currentTime - levelStartTime > noInputTimeout { return .noInputTimeout }
        return nil
    }

    func reset() {
        levelStartTime = nil
        holdStartTime = nil
        startPoint = nil
        isHolding = false
        hasReceivedInput = false
    }
}
