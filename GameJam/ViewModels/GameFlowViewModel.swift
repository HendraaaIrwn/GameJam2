import Foundation
import Observation
import SpriteKit

@Observable
final class GameFlowViewModel {
    private(set) var score = GameScore.initial
    private(set) var lastResult: LevelResult?
    private(set) var attempt = 1
    private(set) var activeLevel: ActiveLevel = .wakeUpManually
    private(set) var sceneID = UUID()

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
        setScene(for: activeLevel)
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

        if activeLevel == .openSmartCurtain {
            if result.didSucceed {
                print("Level 3 completed:", result.message)
            } else {
                print("Level 3 failed:", result.message)
            }
            print("Score:", score)
        }

        if activeLevel == .manualBreakfast {
            if result.didSucceed {
                print("Level 4 completed:", result.message)
            } else {
                print("Level 4 failed:", result.message)
            }
            print("Score:", score)
        }

        if activeLevel == .holdWristDevice {
            if result.didSucceed {
                print("Level 5 completed:", result.message)
                print("TODO: Level 6 routing")
            } else {
                print("Level 5 failed:", result.message)
            }
            print("Score:", score)
        }

        lastResult = result

        if activeLevel == .wakeUpManually && result.didSucceed {
            activeLevel = .rejectAutoRoutine
            lastResult = nil
            setScene(for: activeLevel)
            print("Switched to Level 2")
            return
        }

        if activeLevel == .rejectAutoRoutine && result.didSucceed {
            activeLevel = .openSmartCurtain
            lastResult = nil
            setScene(for: activeLevel)
            print("Switched to Level 3")
            return
        }

        if activeLevel == .openSmartCurtain && result.didSucceed {
            activeLevel = .manualBreakfast
            lastResult = nil
            setScene(for: activeLevel)
            print("Switched to Level 4")
            return
        }

        if activeLevel == .manualBreakfast && result.didSucceed {
            activeLevel = .holdWristDevice
            lastResult = nil
            setScene(for: activeLevel)
            print("Switched to Level 5")
        }
    }

    private func setScene(for level: ActiveLevel) {
        scene = Self.makeScene(for: level)
        assignCompletion(to: scene)
        sceneID = UUID()
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

        if let curtainScene = scene as? OpenSmartCurtainScene {
            curtainScene.levelCompletion = { [weak self] result in
                self?.finishLevel(with: result)
            }
        }

        if let breakfastScene = scene as? ManualBreakfastScene {
            breakfastScene.levelCompletion = { [weak self] result in
                self?.finishLevel(with: result)
            }
        }

        if let holdScene = scene as? HoldWristDeviceScene {
            holdScene.levelCompletion = { [weak self] result in
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
        case .openSmartCurtain:
            scene = OpenSmartCurtainScene(size: CGSize(width: 390, height: 844))
        case .manualBreakfast:
            scene = ManualBreakfastScene(size: CGSize(width: 390, height: 844))
        case .holdWristDevice:
            scene = HoldWristDeviceScene(size: CGSize(width: 390, height: 844))
        }
        scene.scaleMode = .resizeFill
        return scene
    }
}
