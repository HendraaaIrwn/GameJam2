import Observation
import SpriteKit

@Observable
final class GameFlowViewModel {
    private(set) var score = GameScore.initial
    private(set) var lastResult: LevelResult?
    private(set) var attempt = 1
    private(set) var activeLevel: ActiveLevel = .wakeUpManually

    var scene: SKScene

    init() {
        scene = Self.makeScene(for: .wakeUpManually)
        assignCompletion(to: scene)
    }

    var levelTitle: String {
        activeLevel.title
    }

    var statusText: String {
        lastResult?.message ?? activeLevel.instruction
    }

    var canRetry: Bool {
        lastResult != nil
    }

    func retry() {
        attempt += 1
        lastResult = nil
        scene = Self.makeScene(for: activeLevel)
        assignCompletion(to: scene)
    }

    private func finishLevel(with result: LevelResult) {
        guard lastResult == nil else { return }
        score.apply(result)

        if activeLevel == .rejectAutoRoutine {
            if result.didSucceed {
                print("Level 2 completed:", result.message)
            } else {
                print("Level 2 failed:", result.message)
            }
            print("Score:", score)
        }

        lastResult = result

        if activeLevel == .wakeUpManually && result.didSucceed {
            activeLevel = .rejectAutoRoutine
            lastResult = nil
            scene = Self.makeScene(for: activeLevel)
            assignCompletion(to: scene)
        }
    }

    private func assignCompletion(to scene: SKScene) {
        if let wakeScene = scene as? WakeUpManuallyScene {
            wakeScene.levelCompletion = { [weak self] result in
                self?.finishLevel(with: result)
            }
        }

        if let rejectScene = scene as? RejectAutoRoutineScene {
            rejectScene.levelCompletion = { [weak self] result in
                self?.finishLevel(with: result)
            }
        }
    }

    private static func makeScene(for level: ActiveLevel) -> SKScene {
        let scene: SKScene
        switch level {
        case .wakeUpManually:
            scene = WakeUpManuallyScene(size: CGSize(width: 390, height: 844))
        case .rejectAutoRoutine:
            scene = RejectAutoRoutineScene(size: CGSize(width: 390, height: 844))
        }
        scene.scaleMode = .resizeFill
        return scene
    }
}
