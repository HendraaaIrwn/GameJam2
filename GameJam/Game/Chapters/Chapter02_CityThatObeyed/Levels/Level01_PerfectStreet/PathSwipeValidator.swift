import CoreGraphics
import Foundation

enum StreetTarget: String, Codable, Equatable {
    case yellowManualPath
    case blueAIRoute
    case autonomousChair
    case aiWallScreen
    case followRouteButton
    case raka
    case empty
}

enum PathSwipeValidationResult: Equatable {
    case correctManualPath
    case wrongAIRoute
    case weakSwipe
    case wrongDirection
    case trapSelected(target: StreetTarget)
    case noInputTimeout
    case totalTimeout
}

final class PathSwipeValidator {
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

    func validateSwipe(startPoint: CGPoint, endPoint: CGPoint, time: TimeInterval) -> PathSwipeValidationResult {
        hasReceivedInput = true
        lastInputTime = time

        let dx = endPoint.x - startPoint.x
        let dy = endPoint.y - startPoint.y
        let isStrongEnough = abs(dx) >= 50 || abs(dy) >= 50
        let isManualPathSwipe = dx <= -60 && dy >= 60
        let isAIRouteSwipe = dy >= 60 && abs(dx) < 50
        let isWrongDirection = dx >= 60 || dy <= -50

        if isManualPathSwipe { return .correctManualPath }
        if isAIRouteSwipe { return .wrongAIRoute }
        if isStrongEnough && isWrongDirection { return .wrongDirection }
        return .weakSwipe
    }

    func validateTap(target: StreetTarget, time: TimeInterval) -> PathSwipeValidationResult? {
        guard target != .empty, target != .raka, target != .yellowManualPath else { return nil }
        hasReceivedInput = true
        lastInputTime = time

        switch target {
        case .blueAIRoute, .autonomousChair, .aiWallScreen, .followRouteButton:
            return .trapSelected(target: target)
        case .yellowManualPath, .raka, .empty:
            return nil
        }
    }

    func checkTimeouts(currentTime: TimeInterval) -> PathSwipeValidationResult? {
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
