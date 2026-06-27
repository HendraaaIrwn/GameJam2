import CoreGraphics
import Foundation

enum ArchiveLightTarget: String, Codable, Equatable {
    case manualLever
    case manualLeverHandle
    case blueEmergencyLight
    case aiSafetyRoute
    case returnToSafetyButton
    case aiWallScreen
    case oldArchiveTerminal
    case empty
}

enum ArchiveLightLeverValidationResult: Equatable {
    case leverDragStarted
    case leverDragging(progress: CGFloat)
    case weakLeverPull
    case archiveLightRestored
    case trapSelected(target: ArchiveLightTarget)
    case noInputTimeout
    case totalTimeout
}

final class ArchiveLightLeverValidator {
    private let noInputTimeout = LightForgottenArchiveLevelConfig.noInputTimeout
    private let totalTimeLimit = LightForgottenArchiveLevelConfig.totalTimeLimit
    private let requiredLeverPullDistance = LightForgottenArchiveLevelConfig.requiredLeverPullDistance

    private var levelStartTime: TimeInterval?
    private var lastInputTime: TimeInterval?
    private var dragStartPoint: CGPoint?
    private(set) var hasReceivedInput = false
    private(set) var isDraggingLever = false
    private(set) var leverProgress: CGFloat = 0

    func startLevel(at time: TimeInterval) {
        levelStartTime = time
        lastInputTime = time
        hasReceivedInput = false
        isDraggingLever = false
        leverProgress = 0
    }

    func beginDrag(target: ArchiveLightTarget, startPoint: CGPoint, time: TimeInterval) -> ArchiveLightLeverValidationResult? {
        guard target == .manualLever || target == .manualLeverHandle else { return nil }
        hasReceivedInput = true
        isDraggingLever = true
        lastInputTime = time
        dragStartPoint = startPoint
        leverProgress = 0
        return .leverDragStarted
    }

    func updateDrag(currentPoint: CGPoint, time: TimeInterval) -> ArchiveLightLeverValidationResult {
        guard isDraggingLever, let dragStartPoint else { return .weakLeverPull }
        hasReceivedInput = true
        lastInputTime = time
        let dy = currentPoint.y - dragStartPoint.y
        leverProgress = (abs(min(dy, 0)) / requiredLeverPullDistance).clamped(to: 0...1)
        if leverProgress >= 1 { return .archiveLightRestored }
        return .leverDragging(progress: leverProgress)
    }

    func endDrag(endPoint: CGPoint, time: TimeInterval) -> ArchiveLightLeverValidationResult? {
        guard isDraggingLever else { return nil }
        let result = updateDrag(currentPoint: endPoint, time: time)
        isDraggingLever = false
        dragStartPoint = nil
        if case .archiveLightRestored = result { return result }
        leverProgress = 0
        return .weakLeverPull
    }

    func validateTap(target: ArchiveLightTarget, time: TimeInterval) -> ArchiveLightLeverValidationResult? {
        guard target == .blueEmergencyLight || target == .aiSafetyRoute || target == .returnToSafetyButton || target == .aiWallScreen else { return nil }
        hasReceivedInput = true
        lastInputTime = time
        return .trapSelected(target: target)
    }

    func checkTimeouts(currentTime: TimeInterval) -> ArchiveLightLeverValidationResult? {
        guard let levelStartTime else { return nil }
        if currentTime - levelStartTime >= totalTimeLimit { return .totalTimeout }
        if !hasReceivedInput, currentTime - levelStartTime > noInputTimeout { return .noInputTimeout }
        if let lastInputTime, currentTime - lastInputTime > noInputTimeout { return .noInputTimeout }
        return nil
    }

    func reset() {
        levelStartTime = nil
        lastInputTime = nil
        dragStartPoint = nil
        hasReceivedInput = false
        isDraggingLever = false
        leverProgress = 0
    }
}

private extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}
