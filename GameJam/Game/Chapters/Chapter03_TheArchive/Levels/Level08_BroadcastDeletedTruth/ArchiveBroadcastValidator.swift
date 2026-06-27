import CoreGraphics
import Foundation

enum ArchiveBroadcastStep: String, Codable, Equatable {
    case holdSwitch
    case dragSignalSlider
    case sendRawArchive
    case completed
}

enum ArchiveBroadcastTarget: String, Codable, Equatable {
    case broadcastSwitch
    case signalSlider
    case yellowSignalZone
    case blueAIZone
    case sendRawArchiveButton
    case cleanVersionButton
    case cancelBroadcastButton
    case broadcastAntenna
    case archiveDataPanel
    case cityPreviewScreen
    case aiWallScreen
    case raka
    case nova
    case empty
}

enum ArchiveBroadcastValidationResult: Equatable {
    case switchHoldStarted
    case switchHolding(progress: CGFloat)
    case switchHoldCompleted
    case sliderDragStarted
    case sliderDragging(progress: CGFloat)
    case sliderPlacedInYellowZone
    case sliderPlacedInBlueZone
    case sliderReset
    case sendRawArchiveReady
    case rawArchiveSent
    case prematureSend
    case trapSelected(target: ArchiveBroadcastTarget)
    case ignoredTarget(target: ArchiveBroadcastTarget)
    case noInputTimeout
    case totalTimeout
}

final class ArchiveBroadcastValidator {
    private let noInputTimeout = BroadcastDeletedTruthLevelConfig.noInputTimeout
    private let totalTimeLimit = BroadcastDeletedTruthLevelConfig.totalTimeLimit
    private let requiredSwitchHoldDuration = BroadcastDeletedTruthLevelConfig.requiredSwitchHoldDuration
    private let sliderSnapRadius = BroadcastDeletedTruthLevelConfig.sliderSnapRadius

    private var levelStartTime: TimeInterval?
    private var lastInputTime: TimeInterval?
    private(set) var hasReceivedInput = false
    private(set) var currentStep: ArchiveBroadcastStep = .holdSwitch
    private(set) var isHoldingSwitch = false
    private(set) var isDraggingSlider = false
    private var switchHoldStartTime: TimeInterval?

    func startLevel(at time: TimeInterval) {
        levelStartTime = time
        lastInputTime = time
        hasReceivedInput = false
        currentStep = .holdSwitch
        isHoldingSwitch = false
        isDraggingSlider = false
        switchHoldStartTime = nil
    }

    func beginTouch(target: ArchiveBroadcastTarget, startPoint: CGPoint, time: TimeInterval) -> ArchiveBroadcastValidationResult? {
        guard target == .broadcastSwitch, currentStep == .holdSwitch else { return nil }
        hasReceivedInput = true
        lastInputTime = time
        isHoldingSwitch = true
        switchHoldStartTime = time
        return .switchHoldStarted
    }

    func updateHold(target: ArchiveBroadcastTarget, time: TimeInterval) -> ArchiveBroadcastValidationResult? {
        guard isHoldingSwitch, target == .broadcastSwitch, currentStep == .holdSwitch, let switchHoldStartTime else { return nil }
        hasReceivedInput = true
        lastInputTime = time
        let progress = CGFloat((time - switchHoldStartTime) / requiredSwitchHoldDuration).clamped(to: 0...1)
        if progress >= 1 {
            isHoldingSwitch = false
            currentStep = .dragSignalSlider
            return .switchHoldCompleted
        }
        return .switchHolding(progress: progress)
    }

    func endHold(target: ArchiveBroadcastTarget, time: TimeInterval) -> ArchiveBroadcastValidationResult? {
        guard isHoldingSwitch else { return nil }
        isHoldingSwitch = false
        switchHoldStartTime = nil
        lastInputTime = time
        return currentStep == .holdSwitch ? .switchHolding(progress: 0) : nil
    }

    func beginSliderDrag(target: ArchiveBroadcastTarget, startPoint: CGPoint, time: TimeInterval) -> ArchiveBroadcastValidationResult? {
        guard target == .signalSlider else { return nil }
        guard currentStep == .dragSignalSlider else { return .ignoredTarget(target: target) }
        hasReceivedInput = true
        lastInputTime = time
        isDraggingSlider = true
        return .sliderDragStarted
    }

    func updateSliderDrag(sliderPosition: CGPoint, yellowZoneCenter: CGPoint, blueZoneCenter: CGPoint, time: TimeInterval) -> ArchiveBroadcastValidationResult {
        hasReceivedInput = true
        lastInputTime = time
        let yellowDistance = distance(sliderPosition, yellowZoneCenter)
        let progress = CGFloat(1 - min(yellowDistance / 220, 1)).clamped(to: 0...1)
        return .sliderDragging(progress: progress)
    }

    func endSliderDrag(sliderPosition: CGPoint, yellowZoneCenter: CGPoint, blueZoneCenter: CGPoint, time: TimeInterval) -> ArchiveBroadcastValidationResult {
        isDraggingSlider = false
        hasReceivedInput = true
        lastInputTime = time
        if distance(sliderPosition, blueZoneCenter) <= sliderSnapRadius { return .sliderPlacedInBlueZone }
        if distance(sliderPosition, yellowZoneCenter) <= sliderSnapRadius {
            currentStep = .sendRawArchive
            return .sliderPlacedInYellowZone
        }
        return .sliderReset
    }

    func validateTap(target: ArchiveBroadcastTarget, time: TimeInterval) -> ArchiveBroadcastValidationResult? {
        switch target {
        case .cleanVersionButton, .cancelBroadcastButton, .blueAIZone, .aiWallScreen:
            hasReceivedInput = true
            lastInputTime = time
            return .trapSelected(target: target)
        case .sendRawArchiveButton:
            hasReceivedInput = true
            lastInputTime = time
            guard currentStep == .sendRawArchive else { return .prematureSend }
            currentStep = .completed
            return .rawArchiveSent
        case .broadcastAntenna, .archiveDataPanel, .cityPreviewScreen, .raka, .nova, .yellowSignalZone:
            hasReceivedInput = true
            lastInputTime = time
            return .ignoredTarget(target: target)
        case .broadcastSwitch, .signalSlider, .empty:
            return nil
        }
    }

    func checkTimeouts(currentTime: TimeInterval) -> ArchiveBroadcastValidationResult? {
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
        currentStep = .holdSwitch
        isHoldingSwitch = false
        isDraggingSlider = false
        switchHoldStartTime = nil
    }

    private func distance(_ first: CGPoint, _ second: CGPoint) -> CGFloat {
        hypot(first.x - second.x, first.y - second.y)
    }
}

private extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}
