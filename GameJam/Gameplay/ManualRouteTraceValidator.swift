import CoreGraphics
import Foundation

enum RouteTarget: String, Codable, Equatable {
    case rakaStart
    case manualCheckpoint
    case door
    case aiRoute
    case comfortPod
    case aiWallScreen
    case autoNavigateButton
    case empty
}

enum ManualRouteTraceValidationResult: Equatable {
    case traceStarted
    case checkpointReached(index: Int, total: Int)
    case tracing(progress: CGFloat)
    case correctRouteCompleted
    case invalidStart
    case releasedTooEarly
    case wrongDestination
    case aiRouteSelected
    case noInputTimeout
    case totalTimeout
}

final class ManualRouteTraceValidator {
    private let noInputTimeout: TimeInterval = 5.0
    private let totalTimeLimit: TimeInterval = 12.0
    private let startHitRadius: CGFloat = 60
    private let checkpointHitRadius: CGFloat = 42
    private let doorHitRadius: CGFloat = 55
    private let aiRouteDangerRadius: CGFloat = 36
    private let aiRouteGraceDistance: CGFloat = 50
    private let requiredCheckpointCount = 4

    private var levelStartTime: TimeInterval?
    private var lastInputTime: TimeInterval?
    private var startPoint: CGPoint?
    private var hasReceivedInput = false
    private var isTracing = false
    private var nextCheckpointIndex = 0
    private(set) var reachedCheckpointCount = 0

    func startLevel(at time: TimeInterval) {
        levelStartTime = time
        lastInputTime = time
        startPoint = nil
        hasReceivedInput = false
        isTracing = false
        nextCheckpointIndex = 0
        reachedCheckpointCount = 0
    }

    func beginTrace(at point: CGPoint, startPoint: CGPoint, time: TimeInterval) -> ManualRouteTraceValidationResult {
        hasReceivedInput = true
        lastInputTime = time

        guard distance(point, startPoint) <= startHitRadius else { return .invalidStart }
        self.startPoint = startPoint
        isTracing = true
        nextCheckpointIndex = 0
        reachedCheckpointCount = 0
        return .traceStarted
    }

    func updateTrace(at point: CGPoint, checkpoints: [CGPoint], aiRoutePoints: [CGPoint], time: TimeInterval) -> ManualRouteTraceValidationResult {
        guard isTracing else { return .invalidStart }
        hasReceivedInput = true
        lastInputTime = time

        if isPastAIRouteGrace(point), aiRoutePoints.contains(where: { distance(point, $0) <= aiRouteDangerRadius }) {
            isTracing = false
            return .aiRouteSelected
        }

        if nextCheckpointIndex < checkpoints.count, distance(point, checkpoints[nextCheckpointIndex]) <= checkpointHitRadius {
            reachedCheckpointCount += 1
            nextCheckpointIndex += 1
            return .checkpointReached(index: nextCheckpointIndex, total: checkpoints.count)
        }

        let progress = checkpoints.isEmpty ? 0 : CGFloat(reachedCheckpointCount) / CGFloat(checkpoints.count)
        return .tracing(progress: progress)
    }

    func endTrace(at point: CGPoint, doorPoint: CGPoint, comfortPodPoint: CGPoint, time: TimeInterval) -> ManualRouteTraceValidationResult {
        guard isTracing else { return .releasedTooEarly }
        hasReceivedInput = true
        lastInputTime = time
        isTracing = false

        if distance(point, comfortPodPoint) <= doorHitRadius { return .wrongDestination }
        if reachedCheckpointCount >= requiredCheckpointCount && distance(point, doorPoint) <= doorHitRadius { return .correctRouteCompleted }
        return .releasedTooEarly
    }

    func registerTapOnTrap(target: RouteTarget, time: TimeInterval) -> ManualRouteTraceValidationResult? {
        hasReceivedInput = true
        lastInputTime = time

        switch target {
        case .aiRoute, .autoNavigateButton, .aiWallScreen:
            return .aiRouteSelected
        case .comfortPod:
            return .wrongDestination
        default:
            return nil
        }
    }

    func checkTimeouts(currentTime: TimeInterval) -> ManualRouteTraceValidationResult? {
        guard let levelStartTime else { return nil }
        if currentTime - levelStartTime >= totalTimeLimit { return .totalTimeout }
        if let lastInputTime, currentTime - lastInputTime > noInputTimeout { return .noInputTimeout }
        return nil
    }

    func reset() {
        levelStartTime = nil
        lastInputTime = nil
        startPoint = nil
        hasReceivedInput = false
        isTracing = false
        nextCheckpointIndex = 0
        reachedCheckpointCount = 0
    }

    private func isPastAIRouteGrace(_ point: CGPoint) -> Bool {
        guard let startPoint else { return false }
        return distance(point, startPoint) >= aiRouteGraceDistance
    }

    private func distance(_ first: CGPoint, _ second: CGPoint) -> CGFloat {
        hypot(first.x - second.x, first.y - second.y)
    }
}
