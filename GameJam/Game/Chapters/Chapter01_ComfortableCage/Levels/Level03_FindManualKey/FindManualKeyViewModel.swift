import Foundation
import SwiftUI

@Observable
final class FindManualKeyViewModel {
    private(set) var flashlightPosition = CGPoint(x: 0.5, y: 0.5)
    private(set) var feedbackMessage = "Drag light, then tap item."
    private(set) var feedbackColor: Color = FindManualKeyLevelConfig.feedbackNeutralColor
    private(set) var timeRemaining: TimeInterval = FindManualKeyLevelConfig.totalTimeLimit
    private(set) var isCompleted = false

    let items = FindManualKeyLevelConfig.items
    var onComplete: ((LevelResult) -> Void)?

    private let validator = ManualKeySearchValidator()
    private var timerTask: Task<Void, Never>?

    var timerProgress: Double {
        timeRemaining / FindManualKeyLevelConfig.totalTimeLimit
    }

    var isWarning: Bool {
        timeRemaining <= 3
    }

    func startLevel() {
        guard timerTask == nil else { return }
        resetState()

        let startTime = Date().timeIntervalSince1970
        validator.startLevel(at: startTime)

        timerTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .milliseconds(50))
                guard let self, !self.isCompleted else { continue }

                let now = Date().timeIntervalSince1970
                timeRemaining = max(0, FindManualKeyLevelConfig.totalTimeLimit - (now - startTime))

                if let timeoutResult = validator.checkTimeouts(currentTime: now) {
                    handleValidationResult(timeoutResult)
                    return
                }
            }
        }
    }

    func stopLevel() {
        timerTask?.cancel()
        timerTask = nil
        validator.reset()
    }

    func moveFlashlight(to position: CGPoint) {
        flashlightPosition = CGPoint(
            x: min(1, max(0, position.x)),
            y: min(1, max(0, position.y))
        )
    }

    func confirmSelection() {
        guard !isCompleted else { return }
        let target = itemUnderFlashlight()?.target ?? .empty
        guard let result = validator.validateTap(target: target, time: Date().timeIntervalSince1970) else {
            feedbackMessage = FindManualKeyLevelConfig.distractionMessage
            feedbackColor = FindManualKeyLevelConfig.feedbackNeutralColor
            return
        }
        handleValidationResult(result)
    }

    func opacity(for item: ManualKeyItem) -> Double {
        let distance = hypot(flashlightPosition.x - item.position.x, flashlightPosition.y - item.position.y)
        let near = Double(FindManualKeyLevelConfig.flashlightRadiusRatio * 1.35)
        return min(1, max(0.08, 1 - (distance / near)))
    }

    private func resetState() {
        flashlightPosition = CGPoint(x: 0.5, y: 0.5)
        feedbackMessage = FindManualKeyLevelConfig.command
        feedbackColor = FindManualKeyLevelConfig.feedbackNeutralColor
        timeRemaining = FindManualKeyLevelConfig.totalTimeLimit
        isCompleted = false
        validator.reset()
    }

    private func itemUnderFlashlight() -> ManualKeyItem? {
        items.first { item in
            let halfW = item.hitboxSize.width / 2
            let halfH = item.hitboxSize.height / 2
            return flashlightPosition.x >= item.position.x - halfW &&
                flashlightPosition.x <= item.position.x + halfW &&
                flashlightPosition.y >= item.position.y - halfH &&
                flashlightPosition.y <= item.position.y + halfH
        }
    }

    private func handleValidationResult(_ result: ManualKeySearchValidationResult) {
        switch result {
        case .manualKeySelected:
            feedbackMessage = FindManualKeyLevelConfig.successMessage
            feedbackColor = FindManualKeyLevelConfig.feedbackSuccessColor
            finish(with: makeResult(didSucceed: true))
        case .smartKeySelected, .trapSelected, .noInputTimeout, .totalTimeout:
            feedbackMessage = FindManualKeyLevelConfig.failureMessage
            feedbackColor = FindManualKeyLevelConfig.feedbackFailureColor
            finish(with: makeResult(didSucceed: false))
        case .distractionSelected(let target):
            feedbackMessage = distractionText(for: target)
            feedbackColor = FindManualKeyLevelConfig.feedbackNeutralColor
        }
    }

    private func distractionText(for target: ManualKeyTableTarget) -> String {
        switch target {
        case .brokenCable:
            return "That is a broken cable."
        case .oldPhoto:
            return "That is an old photo."
        case .table:
            return "That is not the manual key."
        default:
            return FindManualKeyLevelConfig.distractionMessage
        }
    }

    private func makeResult(didSucceed: Bool) -> LevelResult {
        LevelResult(
            levelId: FindManualKeyLevelConfig.levelId,
            didSucceed: didSucceed,
            obedienceDelta: didSucceed ? FindManualKeyLevelConfig.successObedienceDelta : FindManualKeyLevelConfig.failureObedienceDelta,
            humanityDelta: didSucceed ? FindManualKeyLevelConfig.successHumanityDelta : FindManualKeyLevelConfig.failureHumanityDelta,
            message: didSucceed ? FindManualKeyLevelConfig.successMessage : FindManualKeyLevelConfig.failureMessage
        )
    }

    private func finish(with result: LevelResult) {
        guard !isCompleted else { return }
        isCompleted = true
        timerTask?.cancel()
        timerTask = nil

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) { [weak self] in
            self?.onComplete?(result)
        }
    }
}
