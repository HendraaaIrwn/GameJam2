import CoreGraphics
import Foundation

enum ElevatorChoiceTarget: String, Codable, Equatable {
    case manualStairs
    case safeElevator
    case safeElevatorButton
    case blueAIRoute
    case aiWallScreen
    case raka
    case empty
}

enum ElevatorChoiceValidationResult: Equatable {
    case correctManualStairs
    case wrongSafeElevator
    case weakSwipe
    case wrongDirection
    case trapSelected(target: ElevatorChoiceTarget)
    case noInputTimeout
    case totalTimeout
}

final class ElevatorChoiceValidator {
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

    func validateSwipe(startPoint: CGPoint, endPoint: CGPoint, time: TimeInterval) -> ElevatorChoiceValidationResult {
        hasReceivedInput = true
        lastInputTime = time

        let dx = endPoint.x - startPoint.x
        let dy = endPoint.y - startPoint.y
        let horizontalDistance = abs(dx)
        let verticalDistance = abs(dy)
        let isWeakSwipe = horizontalDistance < 50 && verticalDistance < 50
        let isManualStairsSwipe = dx <= -80 && horizontalDistance > verticalDistance
        let isSafeElevatorSwipe = dx >= 80 && horizontalDistance > verticalDistance

        if isManualStairsSwipe { return .correctManualStairs }
        if isSafeElevatorSwipe { return .wrongSafeElevator }
        if isWeakSwipe { return .weakSwipe }
        return .wrongDirection
    }

    func validateTap(target: ElevatorChoiceTarget, time: TimeInterval) -> ElevatorChoiceValidationResult? {
        guard target != .empty, target != .raka else { return nil }
        hasReceivedInput = true
        lastInputTime = time

        if target == .manualStairs { return .correctManualStairs }
        return .trapSelected(target: target)
    }

    func checkTimeouts(currentTime: TimeInterval) -> ElevatorChoiceValidationResult? {
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
