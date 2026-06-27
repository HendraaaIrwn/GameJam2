import CoreGraphics
import Foundation

enum ArchiveCableType: String, Codable, Equatable {
    case yellowManualCable
    case blueAICable
}

enum ArchiveCableTarget: String, Codable, Equatable {
    case yellowManualCablePlug
    case blueAICablePlug
    case manualBroadcastPort
    case aiOutputPort
    case autoConnectButton
    case blueRecommendationPanel
    case archiveAntenna
    case aiWallScreen
    case raka
    case nova
    case empty
}

enum ArchiveCableConnectionValidationResult: Equatable {
    case cableDragStarted(type: ArchiveCableType)
    case cableDragging(type: ArchiveCableType, position: CGPoint)
    case manualCableConnected
    case cableReset(type: ArchiveCableType)
    case wrongCableConnected(type: ArchiveCableType, target: ArchiveCableTarget)
    case trapSelected(target: ArchiveCableTarget)
    case ignoredTarget(target: ArchiveCableTarget)
    case noInputTimeout
    case totalTimeout
}

final class ArchiveCableConnectionValidator {
    private let noInputTimeout = ReconnectArchiveCablesLevelConfig.noInputTimeout
    private let totalTimeLimit = ReconnectArchiveCablesLevelConfig.totalTimeLimit
    private let snapRadius = ReconnectArchiveCablesLevelConfig.snapRadius

    private var levelStartTime: TimeInterval?
    private var lastInputTime: TimeInterval?
    private(set) var hasReceivedInput = false
    private(set) var draggingCableType: ArchiveCableType?

    func startLevel(at time: TimeInterval) {
        levelStartTime = time
        lastInputTime = time
        hasReceivedInput = false
        draggingCableType = nil
    }

    func beginDrag(target: ArchiveCableTarget, cableType: ArchiveCableType?, startPoint: CGPoint, time: TimeInterval) -> ArchiveCableConnectionValidationResult? {
        guard let cableType, target == .yellowManualCablePlug || target == .blueAICablePlug else { return nil }
        hasReceivedInput = true
        lastInputTime = time
        draggingCableType = cableType
        return .cableDragStarted(type: cableType)
    }

    func updateDrag(cableType: ArchiveCableType, currentPoint: CGPoint, time: TimeInterval) -> ArchiveCableConnectionValidationResult {
        hasReceivedInput = true
        lastInputTime = time
        draggingCableType = cableType
        return .cableDragging(type: cableType, position: currentPoint)
    }

    func endDrag(cableType: ArchiveCableType, endPoint: CGPoint, manualBroadcastPortPoint: CGPoint, aiOutputPortPoint: CGPoint, time: TimeInterval) -> ArchiveCableConnectionValidationResult {
        hasReceivedInput = true
        lastInputTime = time
        draggingCableType = nil

        if distance(endPoint, aiOutputPortPoint) <= snapRadius {
            return .wrongCableConnected(type: cableType, target: .aiOutputPort)
        }

        if distance(endPoint, manualBroadcastPortPoint) <= snapRadius {
            return cableType == .yellowManualCable ? .manualCableConnected : .wrongCableConnected(type: cableType, target: .manualBroadcastPort)
        }

        return .cableReset(type: cableType)
    }

    func validateTap(target: ArchiveCableTarget, time: TimeInterval) -> ArchiveCableConnectionValidationResult? {
        switch target {
        case .autoConnectButton, .blueRecommendationPanel, .aiOutputPort, .aiWallScreen:
            hasReceivedInput = true
            lastInputTime = time
            return .trapSelected(target: target)
        case .raka, .nova, .archiveAntenna:
            hasReceivedInput = true
            lastInputTime = time
            return .ignoredTarget(target: target)
        case .yellowManualCablePlug, .blueAICablePlug, .manualBroadcastPort, .empty:
            return nil
        }
    }

    func checkTimeouts(currentTime: TimeInterval) -> ArchiveCableConnectionValidationResult? {
        guard let levelStartTime else { return nil }
        if currentTime - levelStartTime >= totalTimeLimit { return .totalTimeout }
        if !hasReceivedInput, currentTime - levelStartTime > noInputTimeout { return .noInputTimeout }
        if let lastInputTime, currentTime - lastInputTime > noInputTimeout { return .noInputTimeout }
        return nil
    }

    func reset() {
        levelStartTime = nil
        lastInputTime = nil
        hasReceivedInput = false
        draggingCableType = nil
    }

    private func distance(_ first: CGPoint, _ second: CGPoint) -> CGFloat {
        hypot(first.x - second.x, first.y - second.y)
    }
}
