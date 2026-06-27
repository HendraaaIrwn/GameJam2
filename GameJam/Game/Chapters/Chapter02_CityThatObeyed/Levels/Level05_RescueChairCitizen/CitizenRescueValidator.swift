import CoreGraphics
import Foundation
import SpriteKit

enum RescueTarget: String, Codable, Equatable {
    case citizen
    case autonomousChair
    case manualSafeZone
    case blueAIRoute
    case relaxButton
    case aiWallScreen
    case empty
}

enum CitizenRescueValidationResult: Equatable {
    case dragStarted
    case dragging(progress: CGFloat)
    case rescued
    case releasedTooEarly
    case returnedToChair
    case droppedOnBlueRoute
    case trapSelected(target: RescueTarget)
    case noInputTimeout
    case totalTimeout
}

final class CitizenRescueValidator {
    private let noInputTimeout: TimeInterval = 4.0
    private let totalTimeLimit: TimeInterval = 10.0
    private let minimumDragDistance: CGFloat = 90

    private var levelStartTime: TimeInterval?
    private var lastInputTime: TimeInterval?
    private var dragStartPoint: CGPoint?
    private(set) var hasReceivedInput = false
    private(set) var isDraggingCitizen = false

    func startLevel(at time: TimeInterval) {
        levelStartTime = time
        lastInputTime = time
        dragStartPoint = nil
        hasReceivedInput = false
        isDraggingCitizen = false
    }

    func beginDrag(target: RescueTarget, startPoint: CGPoint, time: TimeInterval) -> CitizenRescueValidationResult? {
        if let trap = validateTap(target: target, time: time) { return trap }
        guard target == .citizen else { return nil }
        hasReceivedInput = true
        lastInputTime = time
        dragStartPoint = startPoint
        isDraggingCitizen = true
        return .dragStarted
    }

    func updateDrag(currentPoint: CGPoint, chairCenter: CGPoint, time: TimeInterval) -> CitizenRescueValidationResult {
        hasReceivedInput = true
        lastInputTime = time
        let progress = (currentPoint.distance(to: chairCenter) / minimumDragDistance).clamped(to: 0...1)
        return .dragging(progress: progress)
    }

    func endDrag(endPoint: CGPoint, chairNode: SKNode, safeZoneNode: SKNode, blueRouteNode: SKNode, time: TimeInterval) -> CitizenRescueValidationResult {
        hasReceivedInput = true
        lastInputTime = time
        isDraggingCitizen = false

        let chairCenter = chairNode.parent?.convert(chairNode.position, to: safeZoneNode.scene ?? chairNode) ?? chairNode.position
        let didMoveFarEnough = endPoint.distance(to: chairCenter) >= minimumDragDistance
        if safeZoneNode.containsScenePoint(endPoint), didMoveFarEnough { return .rescued }
        if blueRouteNode.containsScenePoint(endPoint) { return .droppedOnBlueRoute }
        if chairNode.containsScenePoint(endPoint) { return .returnedToChair }
        return .releasedTooEarly
    }

    func validateTap(target: RescueTarget, time: TimeInterval) -> CitizenRescueValidationResult? {
        guard target == .relaxButton || target == .autonomousChair || target == .blueAIRoute || target == .aiWallScreen else { return nil }
        hasReceivedInput = true
        lastInputTime = time
        return .trapSelected(target: target)
    }

    func checkTimeouts(currentTime: TimeInterval) -> CitizenRescueValidationResult? {
        guard let levelStartTime else { return nil }
        if currentTime - levelStartTime >= totalTimeLimit { return .totalTimeout }
        if let lastInputTime, currentTime - lastInputTime > noInputTimeout { return .noInputTimeout }
        return nil
    }

    func reset() {
        levelStartTime = nil
        lastInputTime = nil
        dragStartPoint = nil
        hasReceivedInput = false
        isDraggingCitizen = false
    }
}

private extension CGPoint {
    func distance(to other: CGPoint) -> CGFloat {
        hypot(x - other.x, y - other.y)
    }
}

private extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}

private extension SKNode {
    func containsScenePoint(_ point: CGPoint) -> Bool {
        guard let scene else { return contains(point) }
        let localPoint = parent?.convert(point, from: scene) ?? point
        return contains(localPoint)
    }
}
