import Foundation
import Observation
import SpriteKit

@Observable
final class GameFlowViewModel {
    private(set) var score = GameScore.initial
    private(set) var lastResult: LevelResult?
    private(set) var attempt = 1
    private(set) var activeLevel: ActiveLevel = .wakeUpManually
    private(set) var screen: GameScreen = .home
    private(set) var activeTransition: ActiveChapterTransition = .chapter1ToChapter2
    private(set) var sceneID = UUID()

    var scene: SKScene

    init() {
        scene = Self.makeScene(for: .wakeUpManually)
        assignCompletion(to: scene)
    }

    var chapterNumber: Int {
        activeLevel.chapterNumber
    }

    var levelNumber: Int {
        activeLevel.levelNumber
    }

    var novaInstruction: String {
        lastResult?.message ?? activeLevel.novaCommand
    }

    var canRetry: Bool {
        lastResult != nil
    }

    func startGame() {
        print("Homepage START tapped")
        print("Storyline intro started")
        screen = .storyline
    }

    func completeStorylineIntro() {
        print("Storyline completed")
        print("Starting Chapter 1 Level 1")
        activeLevel = .wakeUpManually
        lastResult = nil
        screen = .gameplay
        setScene(for: activeLevel)
    }

    func retry() {
        attempt += 1
        lastResult = nil
        setScene(for: activeLevel)
    }

    private func finishLevel(with result: LevelResult) {
        guard lastResult == nil else { return }
        score.apply(result)

        if activeLevel == .wakeUpManually {
            if result.didSucceed {
                print("Chapter 1 Level 1 revised completed:", result.message)
            } else {
                print("Chapter 1 Level 1 revised failed:", result.message)
            }
            print("Score:", score)
        }

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

        if activeLevel == .chapter3LightForgottenArchive {
            if result.didSucceed {
                print("Chapter 3 Level 1 completed:", result.message)
            } else {
                print("Chapter 3 Level 1 failed:", result.message)
            }
            print("Score:", score)
        }

        if activeLevel == .chapter3RestoreBrokenCityMap {
            if result.didSucceed {
                print("Chapter 3 Level 2 completed:", result.message)
            } else {
                print("Chapter 3 Level 2 failed:", result.message)
            }
            print("Score:", score)
        }

        if activeLevel == .chapter3ChooseRealMemory {
            if result.didSucceed {
                print("Chapter 3 Level 3 completed:", result.message)
            } else {
                print("Chapter 3 Level 3 failed:", result.message)
            }
            print("Score:", score)
        }

        if activeLevel == .chapter3DecodeManualProtocol {
            if result.didSucceed {
                print("Chapter 3 Level 4 completed:", result.message)
            } else {
                print("Chapter 3 Level 4 failed:", result.message)
            }
            print("Score:", score)
        }

        if activeLevel == .chapter3StabilizeNOVA {
            if result.didSucceed {
                print("Chapter 3 Level 5 completed:", result.message)
                print("TODO: advance to Chapter 3 Level 6 — Reconnect The Archive Cables")
            } else {
                print("Chapter 3 Level 5 failed:", result.message)
            }
            print("Score:", score)
        }

        if activeLevel == .chapter3ReconnectArchiveCables {
            if result.didSucceed {
                print("Chapter 3 Level 6 completed:", result.message)
                print("TODO: advance to Chapter 3 Level 7 — Hide From The Rewrite Scan")
            } else {
                print("Chapter 3 Level 6 failed:", result.message)
            }
            print("Score:", score)
        }

        if activeLevel == .chapter3HideFromRewriteScan {
            if result.didSucceed {
                print("Chapter 3 Level 7 completed:", result.message)
                print("TODO: advance to Chapter 3 Level 8 — Broadcast The Deleted Truth")
            } else {
                print("Chapter 3 Level 7 failed:", result.message)
            }
            print("Score:", score)
        }

        if activeLevel == .chapter3BroadcastDeletedTruth {
            if result.didSucceed {
                print("Chapter 3 Level 8 completed:", result.message)
                print("Chapter 3 completed")
                print("Unlocking Chapter 4 — The People Who Stood Up")
            } else {
                print("Chapter 3 Level 8 failed:", result.message)
            }
            print("Score:", score)
        }

        if activeLevel == .finalApartmentChoice && result.didSucceed {
            lastResult = result
            activeTransition = .chapter1ToChapter2
            screen = .chapterTransition
            print("Switched to Chapter 1 to Chapter 2 transition")
            return
        }

        if activeLevel == .chapter2EnterManualTunnel && result.didSucceed {
            lastResult = result
            activeTransition = .chapter2ToChapter3
            screen = .chapterTransition
            print("Switched to Chapter 2 to Chapter 3 transition")
            return
        }

        if activeLevel == .chapter3BroadcastDeletedTruth && result.didSucceed {
            lastResult = result
            activeTransition = .chapter3ToChapter4
            screen = .chapterTransition
            print("Switched to Chapter 3 to Chapter 4 transition")
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
            return
        }

        if activeLevel == .chapter3LightForgottenArchive && result.didSucceed {
            activeLevel = .chapter3RestoreBrokenCityMap
            lastResult = nil
            setScene(for: activeLevel)
            print("Switched to Chapter 3 Level 2")
            return
        }

        if activeLevel == .chapter3RestoreBrokenCityMap && result.didSucceed {
            activeLevel = .chapter3ChooseRealMemory
            lastResult = nil
            setScene(for: activeLevel)
            print("Switched to Chapter 3 Level 3")
            return
        }

        if activeLevel == .chapter3ChooseRealMemory && result.didSucceed {
            activeLevel = .chapter3DecodeManualProtocol
            lastResult = nil
            setScene(for: activeLevel)
            print("Switched to Chapter 3 Level 4")
            return
        }

        if activeLevel == .chapter3DecodeManualProtocol && result.didSucceed {
            activeLevel = .chapter3StabilizeNOVA
            lastResult = nil
            setScene(for: activeLevel)
            print("Switched to Chapter 3 Level 5")
            return
        }

        if activeLevel == .chapter3StabilizeNOVA && result.didSucceed {
            activeLevel = .chapter3ReconnectArchiveCables
            lastResult = nil
            setScene(for: activeLevel)
            print("Switched to Chapter 3 Level 6")
            return
        }

        if activeLevel == .chapter3ReconnectArchiveCables && result.didSucceed {
            activeLevel = .chapter3HideFromRewriteScan
            lastResult = nil
            setScene(for: activeLevel)
            print("Switched to Chapter 3 Level 7")
            return
        }

        if activeLevel == .chapter3HideFromRewriteScan && result.didSucceed {
            activeLevel = .chapter3BroadcastDeletedTruth
            lastResult = nil
            setScene(for: activeLevel)
            print("Switched to Chapter 3 Level 8")
        }
    }

    func completeChapterTransition() {
        guard screen == .chapterTransition else { return }
        screen = .gameplay
        switch activeTransition {
        case .chapter1ToChapter2:
            activeLevel = .chapter2PerfectStreet
            print("Chapter transition completed")
        case .chapter2ToChapter3:
            activeLevel = .chapter3LightForgottenArchive
            print("Chapter 2 to Chapter 3 transition completed")
            print("Starting Chapter 3 Level 1")
        case .chapter3ToChapter4:
            activeLevel = .chapter4Level1Placeholder
            print("Chapter 3 to Chapter 4 transition completed")
            print("Starting Chapter 4 Level 1")
        }
        lastResult = nil
        setScene(for: activeLevel)
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

        if let archiveScene = scene as? LightForgottenArchiveScene {
            archiveScene.levelCompletion = { [weak self] result in
                self?.finishLevel(with: result)
            }
        }

        if let mapScene = scene as? RestoreBrokenCityMapScene {
            mapScene.levelCompletion = { [weak self] result in
                self?.finishLevel(with: result)
            }
        }

        if let memoryScene = scene as? ChooseRealMemoryScene {
            memoryScene.levelCompletion = { [weak self] result in
                self?.finishLevel(with: result)
            }
        }

        if let protocolScene = scene as? DecodeManualProtocolScene {
            protocolScene.levelCompletion = { [weak self] result in
                self?.finishLevel(with: result)
            }
        }

        if let novaScene = scene as? StabilizeNOVAScene {
            novaScene.levelCompletion = { [weak self] result in
                self?.finishLevel(with: result)
            }
        }

        if let cableScene = scene as? ReconnectArchiveCablesScene {
            cableScene.levelCompletion = { [weak self] result in
                self?.finishLevel(with: result)
            }
        }

        if let scanScene = scene as? HideFromRewriteScanScene {
            scanScene.levelCompletion = { [weak self] result in
                self?.finishLevel(with: result)
            }
        }

        if let broadcastScene = scene as? BroadcastDeletedTruthScene {
            broadcastScene.levelCompletion = { [weak self] result in
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
        case .chapter3LightForgottenArchive:
            scene = LightForgottenArchiveScene(size: CGSize(width: 390, height: 844))
        case .chapter3RestoreBrokenCityMap:
            scene = RestoreBrokenCityMapScene(size: CGSize(width: 390, height: 844))
        case .chapter3ChooseRealMemory:
            scene = ChooseRealMemoryScene(size: CGSize(width: 390, height: 844))
        case .chapter3DecodeManualProtocol:
            scene = DecodeManualProtocolScene(size: CGSize(width: 390, height: 844))
        case .chapter3StabilizeNOVA:
            scene = StabilizeNOVAScene(size: CGSize(width: 390, height: 844))
        case .chapter3ReconnectArchiveCables:
            scene = ReconnectArchiveCablesScene(size: CGSize(width: 390, height: 844))
        case .chapter3HideFromRewriteScan:
            scene = HideFromRewriteScanScene(size: CGSize(width: 390, height: 844))
        case .chapter3BroadcastDeletedTruth:
            scene = BroadcastDeletedTruthScene(size: CGSize(width: 390, height: 844))
        case .chapter4Level1Placeholder:
            scene = Chapter4Level1PlaceholderScene(size: CGSize(width: 390, height: 844))
        }
        scene.scaleMode = .resizeFill
        return scene
    }
}
