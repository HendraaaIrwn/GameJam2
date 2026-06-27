import CoreGraphics
import Foundation

enum RewriteScanTarget: String, Codable, Equatable {
    case raka
    case rakaHitbox
    case yellowShadowZone
    case blueScanBeam
    case blueScanZone
    case verifyIdentityButton
    case archiveDataPanel
    case aiWallScreen
    case nova
    case empty
}

enum RewriteScanDirection: String, Codable, Equatable {
    case leftToRight
    case rightToLeft
}

enum RewriteScanAvoidanceValidationResult: Equatable {
    case rakaDragStarted
    case rakaDragging(position: CGPoint)
    case scanWarning(passIndex: Int, requiredPasses: Int)
    case safeInShadow(passIndex: Int, requiredPasses: Int)
    case scanPassSurvived(passIndex: Int, requiredPasses: Int)
    case allScansAvoided
    case detectedByScan
    case trapSelected(target: RewriteScanTarget)
    case ignoredTarget(target: RewriteScanTarget)
    case noInputTimeout
    case totalTimeout
}

final class RewriteScanAvoidanceValidator {
    private let noInputTimeout = HideFromRewriteScanLevelConfig.noInputTimeout
    private let totalTimeLimit = HideFromRewriteScanLevelConfig.totalTimeLimit
    private let requiredScanPasses = HideFromRewriteScanLevelConfig.requiredScanPasses
    private let detectionGraceDuration = HideFromRewriteScanLevelConfig.detectionGraceDuration

    private var levelStartTime: TimeInterval?
    private var lastInputTime: TimeInterval?
    private(set) var hasReceivedInput = false
    private(set) var isDraggingRaka = false
    private(set) var survivedPasses = 0
    private var activeDetectionStartTime: TimeInterval?
    private var reportedPasses = Set<Int>()

    func startLevel(at time: TimeInterval) {
        levelStartTime = time
        lastInputTime = time
        hasReceivedInput = false
        isDraggingRaka = false
        survivedPasses = 0
        activeDetectionStartTime = nil
        reportedPasses.removeAll()
    }

    func beginDrag(target: RewriteScanTarget, startPoint: CGPoint, time: TimeInterval) -> RewriteScanAvoidanceValidationResult? {
        guard target == .raka || target == .rakaHitbox else { return nil }
        hasReceivedInput = true
        isDraggingRaka = true
        lastInputTime = time
        return .rakaDragStarted
    }

    func updateDrag(rakaPosition: CGPoint, time: TimeInterval) -> RewriteScanAvoidanceValidationResult {
        hasReceivedInput = true
        lastInputTime = time
        return .rakaDragging(position: rakaPosition)
    }

    func endDrag(time: TimeInterval) {
        isDraggingRaka = false
        lastInputTime = time
    }

    func validateTap(target: RewriteScanTarget, time: TimeInterval) -> RewriteScanAvoidanceValidationResult? {
        switch target {
        case .verifyIdentityButton, .blueScanBeam, .blueScanZone, .aiWallScreen:
            hasReceivedInput = true
            lastInputTime = time
            return .trapSelected(target: target)
        case .yellowShadowZone, .archiveDataPanel, .nova:
            hasReceivedInput = true
            lastInputTime = time
            return .ignoredTarget(target: target)
        case .raka, .rakaHitbox, .empty:
            return nil
        }
    }

    func updateScan(rakaPosition: CGPoint, scanBeamFrame: CGRect, shadowZoneFrames: [CGRect], passIndex: Int, hasPassCompleted: Bool, time: TimeInterval) -> RewriteScanAvoidanceValidationResult? {
        if hasPassCompleted, !reportedPasses.contains(passIndex) {
            reportedPasses.insert(passIndex)
            survivedPasses += 1
            activeDetectionStartTime = nil
            if survivedPasses >= requiredScanPasses { return .allScansAvoided }
            return .scanPassSurvived(passIndex: survivedPasses, requiredPasses: requiredScanPasses)
        }

        let scanOverlapsRaka = scanBeamFrame.contains(rakaPosition)
        guard scanOverlapsRaka else {
            activeDetectionStartTime = nil
            return .scanWarning(passIndex: passIndex, requiredPasses: requiredScanPasses)
        }

        if isRakaInsideShadow(rakaPosition: rakaPosition, shadowZoneFrames: shadowZoneFrames) {
            activeDetectionStartTime = nil
            return .safeInShadow(passIndex: passIndex, requiredPasses: requiredScanPasses)
        }

        if let activeDetectionStartTime {
            if time - activeDetectionStartTime >= detectionGraceDuration { return .detectedByScan }
            return .scanWarning(passIndex: passIndex, requiredPasses: requiredScanPasses)
        }

        activeDetectionStartTime = time
        return .scanWarning(passIndex: passIndex, requiredPasses: requiredScanPasses)
    }

    func checkTimeouts(currentTime: TimeInterval) -> RewriteScanAvoidanceValidationResult? {
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
        isDraggingRaka = false
        survivedPasses = 0
        activeDetectionStartTime = nil
        reportedPasses.removeAll()
    }

    private func isRakaInsideShadow(rakaPosition: CGPoint, shadowZoneFrames: [CGRect]) -> Bool {
        shadowZoneFrames.contains { $0.contains(rakaPosition) }
    }
}
