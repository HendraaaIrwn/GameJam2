import CoreGraphics
import Foundation

enum CrowdTarget: String, Codable, Equatable {
    case raka
    case crowdCitizen
    case blueFlowRoute
    case yellowManualLane
    case flowWithCrowdButton
    case aiWallScreen
    case empty
}

enum CrowdResistanceValidationResult: Equatable {
    case resistanceProgress(current: Int, required: Int)
    case resisted
    case followedCrowd
    case weakSwipe
    case wrongDirection
    case trapSelected(target: CrowdTarget)
    case noInputTimeout
    case totalTimeout
}

final class CrowdResistanceValidator {
    private let noInputTimeout: TimeInterval = 4.0
    private let totalTimeLimit: TimeInterval = 9.0
    private let requiredSwipes = 3

    private var levelStartTime: TimeInterval?
    private var lastInputTime: TimeInterval?
    private(set) var hasReceivedInput = false
    private(set) var resistanceCount = 0

    func startLevel(at time: TimeInterval) {
        levelStartTime = time
        lastInputTime = time
        hasReceivedInput = false
        resistanceCount = 0
    }

    func validateSwipe(startPoint: CGPoint, endPoint: CGPoint, time: TimeInterval) -> CrowdResistanceValidationResult {
        hasReceivedInput = true
        lastInputTime = time

        let dx = endPoint.x - startPoint.x
        let dy = endPoint.y - startPoint.y
        let horizontalDistance = abs(dx)
        let verticalDistance = abs(dy)
        let isWeakSwipe = horizontalDistance < 45 && verticalDistance < 45
        let isValidResistanceSwipe = dx <= -70 && horizontalDistance > verticalDistance
        let isFollowingCrowdSwipe = dx >= 70 && horizontalDistance > verticalDistance
        let isVerticalSwipe = verticalDistance > horizontalDistance

        if isValidResistanceSwipe {
            resistanceCount += 1
            if resistanceCount >= requiredSwipes { return .resisted }
            return .resistanceProgress(current: resistanceCount, required: requiredSwipes)
        }
        if isFollowingCrowdSwipe { return .followedCrowd }
        if isWeakSwipe { return .weakSwipe }
        if isVerticalSwipe { return .wrongDirection }
        return .wrongDirection
    }

    func validateTap(target: CrowdTarget, time: TimeInterval) -> CrowdResistanceValidationResult? {
        guard target == .flowWithCrowdButton || target == .blueFlowRoute || target == .aiWallScreen else { return nil }
        hasReceivedInput = true
        lastInputTime = time
        return .trapSelected(target: target)
    }

    func checkTimeouts(currentTime: TimeInterval) -> CrowdResistanceValidationResult? {
        guard let levelStartTime else { return nil }
        if currentTime - levelStartTime >= totalTimeLimit { return .totalTimeout }
        if let lastInputTime, currentTime - lastInputTime > noInputTimeout { return .noInputTimeout }
        return nil
    }

    func reset() {
        levelStartTime = nil
        lastInputTime = nil
        hasReceivedInput = false
        resistanceCount = 0
    }
}
