import Foundation
import Observation
import SpriteKit

@Observable
final class GameFlowViewModel {
    private(set) var score = GameScore.initial
    private(set) var lastResult: LevelResult?
    private(set) var attempt = 1
    private(set) var activeLevel: ActiveLevel = .wakeUpManually
    private(set) var screen: GameScreen = .gameplay
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
            } else {
                print("Level 5 failed:", result.message)
            }
            print("Score:", score)
        }

        if activeLevel == .findManualKey {
            if result.didSucceed {
                print("Level 6 completed:", result.message)
            } else {
                print("Level 6 failed:", result.message)
            }
            print("Score:", score)
        }

        if activeLevel == .drawManualRoute {
            if result.didSucceed {
                print("Level 7 completed:", result.message)
            } else {
                print("Level 7 failed:", result.message)
            }
            print("Score:", score)
        }

        if activeLevel == .finalApartmentChoice {
            if result.didSucceed {
                print("Level 8 completed:", result.message)
                print("Chapter 1 completed")
                print("TODO: unlock Chapter 2")
            } else {
                print("Level 8 failed:", result.message)
            }
            print("Score:", score)
        }

        if activeLevel == .chapter2PerfectStreet {
            if result.didSucceed {
                print("Chapter 2 Level 1 completed:", result.message)
            } else {
                print("Chapter 2 Level 1 failed:", result.message)
            }
            print("Score:", score)
        }

        if activeLevel == .chapter2WrongRobotTarget {
            if result.didSucceed {
                print("Chapter 2 Level 2 completed:", result.message)
            } else {
                print("Chapter 2 Level 2 failed:", result.message)
            }
            print("Score:", score)
        }

        if activeLevel == .chapter2AvoidSafeElevator {
            if result.didSucceed {
                print("Chapter 2 Level 3 completed:", result.message)
            } else {
                print("Chapter 2 Level 3 failed:", result.message)
            }
            print("Score:", score)
        }

        if activeLevel == .chapter2ManualBridgeBalance {
            if result.didSucceed {
                print("Chapter 2 Level 4 completed:", result.message)
            } else {
                print("Chapter 2 Level 4 failed:", result.message)
            }
            print("Score:", score)
        }

        if activeLevel == .chapter2RescueChairCitizen {
            if result.didSucceed {
                print("Chapter 2 Level 5 completed:", result.message)
            } else {
                print("Chapter 2 Level 5 failed:", result.message)
            }
            print("Score:", score)
        }

        if activeLevel == .chapter2WalkAgainstCrowd {
            if result.didSucceed {
                print("Chapter 2 Level 6 completed:", result.message)
            } else {
                print("Chapter 2 Level 6 failed:", result.message)
            }
            print("Score:", score)
        }

        if activeLevel == .chapter2FindOldTransitSwitch {
            if result.didSucceed {
                print("Chapter 2 Level 7 completed:", result.message)
            } else {
                print("Chapter 2 Level 7 failed:", result.message)
            }
            print("Score:", score)
        }

        if activeLevel == .chapter2EnterManualTunnel {
            if result.didSucceed {
                print("Chapter 2 Level 8 completed:", result.message)
                print("Chapter 2 completed")
                print("Unlocking Chapter 3 — The Archive")
                print("TODO: advance to Chapter 3 — The Archive")
            } else {
                print("Chapter 2 Level 8 failed:", result.message)
            }
            print("Score:", score)
        }

        if activeLevel == .finalApartmentChoice && result.didSucceed {
            lastResult = result
            screen = .chapterTransition
            print("Switched to Chapter 1 to Chapter 2 transition")
            return
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
            return
        }

        if activeLevel == .holdWristDevice && result.didSucceed {
            activeLevel = .findManualKey
            lastResult = nil
            setScene(for: activeLevel)
            print("Switched to Level 6")
            return
        }

        if activeLevel == .findManualKey && result.didSucceed {
            activeLevel = .drawManualRoute
            lastResult = nil
            setScene(for: activeLevel)
            print("Switched to Level 7")
            return
        }

        if activeLevel == .drawManualRoute && result.didSucceed {
            activeLevel = .finalApartmentChoice
            lastResult = nil
            setScene(for: activeLevel)
            print("Switched to Level 8")
            return
        }

        if activeLevel == .chapter2PerfectStreet && result.didSucceed {
            activeLevel = .chapter2WrongRobotTarget
            lastResult = nil
            setScene(for: activeLevel)
            print("Switched to Chapter 2 Level 2")
            return
        }

        if activeLevel == .chapter2WrongRobotTarget && result.didSucceed {
            activeLevel = .chapter2AvoidSafeElevator
            lastResult = nil
            setScene(for: activeLevel)
            print("Switched to Chapter 2 Level 3")
            return
        }

        if activeLevel == .chapter2AvoidSafeElevator && result.didSucceed {
            activeLevel = .chapter2ManualBridgeBalance
            lastResult = nil
            setScene(for: activeLevel)
            print("Switched to Chapter 2 Level 4")
            return
        }

        if activeLevel == .chapter2ManualBridgeBalance && result.didSucceed {
            activeLevel = .chapter2RescueChairCitizen
            lastResult = nil
            setScene(for: activeLevel)
            print("Switched to Chapter 2 Level 5")
            return
        }

        if activeLevel == .chapter2RescueChairCitizen && result.didSucceed {
            activeLevel = .chapter2WalkAgainstCrowd
            lastResult = nil
            setScene(for: activeLevel)
            print("Switched to Chapter 2 Level 6")
            return
        }

        if activeLevel == .chapter2WalkAgainstCrowd && result.didSucceed {
            activeLevel = .chapter2FindOldTransitSwitch
            lastResult = nil
            setScene(for: activeLevel)
            print("Switched to Chapter 2 Level 7")
            return
        }

        if activeLevel == .chapter2FindOldTransitSwitch && result.didSucceed {
            activeLevel = .chapter2EnterManualTunnel
            lastResult = nil
            setScene(for: activeLevel)
            print("Switched to Chapter 2 Level 8")
        }
    }

    func completeChapterTransition() {
        guard screen == .chapterTransition else { return }
        screen = .gameplay
        activeLevel = .chapter2PerfectStreet
        lastResult = nil
        setScene(for: activeLevel)
        print("Chapter transition completed")
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

        if let keyScene = scene as? FindManualKeyScene {
            keyScene.levelCompletion = { [weak self] result in
                self?.finishLevel(with: result)
            }
        }

        if let routeScene = scene as? DrawManualRouteScene {
            routeScene.levelCompletion = { [weak self] result in
                self?.finishLevel(with: result)
            }
        }

        if let finalScene = scene as? FinalApartmentChoiceScene {
            finalScene.levelCompletion = { [weak self] result in
                self?.finishLevel(with: result)
            }
        }

        if let streetScene = scene as? PerfectStreetScene {
            streetScene.levelCompletion = { [weak self] result in
                self?.finishLevel(with: result)
            }
        }

        if let robotScene = scene as? WrongRobotTargetScene {
            robotScene.levelCompletion = { [weak self] result in
                self?.finishLevel(with: result)
            }
        }

        if let elevatorScene = scene as? AvoidSafeElevatorScene {
            elevatorScene.levelCompletion = { [weak self] result in
                self?.finishLevel(with: result)
            }
        }

        if let bridgeScene = scene as? ManualBridgeBalanceScene {
            bridgeScene.levelCompletion = { [weak self] result in
                self?.finishLevel(with: result)
            }
        }

        if let rescueScene = scene as? RescueChairCitizenScene {
            rescueScene.levelCompletion = { [weak self] result in
                self?.finishLevel(with: result)
            }
        }

        if let crowdScene = scene as? WalkAgainstCrowdScene {
            crowdScene.levelCompletion = { [weak self] result in
                self?.finishLevel(with: result)
            }
        }

        if let transitScene = scene as? FindOldTransitSwitchScene {
            transitScene.levelCompletion = { [weak self] result in
                self?.finishLevel(with: result)
            }
        }

        if let tunnelScene = scene as? EnterManualTunnelScene {
            tunnelScene.levelCompletion = { [weak self] result in
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
        case .findManualKey:
            scene = FindManualKeyScene(size: CGSize(width: 390, height: 844))
        case .drawManualRoute:
            scene = DrawManualRouteScene(size: CGSize(width: 390, height: 844))
        case .finalApartmentChoice:
            scene = FinalApartmentChoiceScene(size: CGSize(width: 390, height: 844))
        case .chapter2PerfectStreet:
            scene = PerfectStreetScene(size: CGSize(width: 390, height: 844))
        case .chapter2WrongRobotTarget:
            scene = WrongRobotTargetScene(size: CGSize(width: 390, height: 844))
        case .chapter2AvoidSafeElevator:
            scene = AvoidSafeElevatorScene(size: CGSize(width: 390, height: 844))
        case .chapter2ManualBridgeBalance:
            scene = ManualBridgeBalanceScene(size: CGSize(width: 390, height: 844))
        case .chapter2RescueChairCitizen:
            scene = RescueChairCitizenScene(size: CGSize(width: 390, height: 844))
        case .chapter2WalkAgainstCrowd:
            scene = WalkAgainstCrowdScene(size: CGSize(width: 390, height: 844))
        case .chapter2FindOldTransitSwitch:
            scene = FindOldTransitSwitchScene(size: CGSize(width: 390, height: 844))
        case .chapter2EnterManualTunnel:
            scene = EnterManualTunnelScene(size: CGSize(width: 390, height: 844))
        }
        scene.scaleMode = .resizeFill
        return scene
    }
}
