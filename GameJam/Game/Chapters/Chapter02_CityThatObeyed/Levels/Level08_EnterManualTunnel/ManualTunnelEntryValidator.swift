import CoreGraphics
import Foundation
import SpriteKit

enum TunnelEntryTarget: String, Codable, Equatable {
    case raka
    case manualTunnelZone
    case cityReturnZone
    case blueCityRoute
    case returnToSafetyButton
    case comfortPod
    case oldTransitDoor
    case aiWallScreen
    case empty
}

enum ManualTunnelEntryValidationResult: Equatable {
    case holdStarted
    case dragging(progress: CGFloat)
    case enteredTunnel
    case releasedTooEarly
    case returnedToCity
    case droppedOutsideTunnel
    case trapSelected(target: TunnelEntryTarget)
    case noInputTimeout
    case totalTimeout
}

final class ManualTunnelEntryValidator {
    private let noInputTimeout: TimeInterval = 4.0
    private let totalTimeLimit: TimeInterval = 10.0
    private let minimumHoldDuration: TimeInterval = 0.25
    private let minimumDragDistance: CGFloat = 100.0

    private var levelStartTime: TimeInterval?
    private var lastInputTime: TimeInterval?
    private var touchStartTime: TimeInterval?
    private var dragStartPoint: CGPoint?
    private(set) var hasReceivedInput = false
    private(set) var isDraggingRaka = false

    func startLevel(at time: TimeInterval) {
        levelStartTime = time
        lastInputTime = time
        touchStartTime = nil
        dragStartPoint = nil
        hasReceivedInput = false
        isDraggingRaka = false
    }

    func beginHold(target: TunnelEntryTarget, startPoint: CGPoint, time: TimeInterval) -> ManualTunnelEntryValidationResult? {
        if let trap = validateTap(target: target, time: time) { return trap }
        guard target == .raka else { return nil }
        hasReceivedInput = true
        lastInputTime = time
        touchStartTime = time
        dragStartPoint = startPoint
        isDraggingRaka = true
        return .holdStarted
    }

    func updateDrag(currentPoint: CGPoint, time: TimeInterval) -> ManualTunnelEntryValidationResult {
        hasReceivedInput = true
        lastInputTime = time
        let progress = (currentPoint.distance(to: dragStartPoint ?? currentPoint) / minimumDragDistance).clamped(to: 0...1)
        return .dragging(progress: progress)
    }

    func endDrag(endPoint: CGPoint, rakaStartPoint: CGPoint, tunnelZoneNode: SKNode, cityReturnZoneNode: SKNode, time: TimeInterval) -> ManualTunnelEntryValidationResult {
        hasReceivedInput = true
        lastInputTime = time
        isDraggingRaka = false

        let heldLongEnough = time - (touchStartTime ?? time) >= minimumHoldDuration
        let movedFarEnough = endPoint.distance(to: rakaStartPoint) >= minimumDragDistance
        if !heldLongEnough || !movedFarEnough { return .releasedTooEarly }
        if tunnelZoneNode.containsScenePoint(endPoint) { return .enteredTunnel }
        if cityReturnZoneNode.containsScenePoint(endPoint) { return .returnedToCity }
        return .droppedOutsideTunnel
    }

    func validateTap(target: TunnelEntryTarget, time: TimeInterval) -> ManualTunnelEntryValidationResult? {
        guard target == .returnToSafetyButton || target == .blueCityRoute || target == .comfortPod || target == .aiWallScreen else { return nil }
        hasReceivedInput = true
        lastInputTime = time
        return .trapSelected(target: target)
    }

    func checkTimeouts(currentTime: TimeInterval) -> ManualTunnelEntryValidationResult? {
        guard let levelStartTime else { return nil }
        if currentTime - levelStartTime >= totalTimeLimit { return .totalTimeout }
        if let lastInputTime, currentTime - lastInputTime > noInputTimeout { return .noInputTimeout }
        return nil
    }

    func reset() {
        levelStartTime = nil
        lastInputTime = nil
        touchStartTime = nil
        dragStartPoint = nil
        hasReceivedInput = false
        isDraggingRaka = false
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
