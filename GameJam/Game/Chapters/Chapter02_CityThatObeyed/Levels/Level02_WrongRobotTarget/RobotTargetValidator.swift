import Foundation

enum RobotTarget: String, Codable, Equatable {
    case surveillanceDrone
    case wheeledHelperRobot
    case passiveCitizen
    case cleaningRobot
    case aiApprovedRobot
    case aiWallScreen
    case stopRobotButton
    case empty
}

enum RobotTargetValidationResult: Equatable {
    case correctTarget(target: RobotTarget)
    case wrongTarget(target: RobotTarget)
    case noInputTimeout
    case totalTimeout
}

final class RobotTargetValidator {
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

    func validateTap(target: RobotTarget, time: TimeInterval) -> RobotTargetValidationResult? {
        guard target != .empty else { return nil }
        hasReceivedInput = true
        lastInputTime = time

        if target == .surveillanceDrone {
            return .correctTarget(target: target)
        }
        return .wrongTarget(target: target)
    }

    func checkTimeouts(currentTime: TimeInterval) -> RobotTargetValidationResult? {
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
