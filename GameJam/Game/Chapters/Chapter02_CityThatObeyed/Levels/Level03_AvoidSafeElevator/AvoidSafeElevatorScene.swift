import SpriteKit

final class AvoidSafeElevatorScene: SKScene {
    var levelCompletion: ((LevelResult) -> Void)?

    private enum FailureReason: String {
        case safeElevatorSelected
        case wrongDirection
        case noInputTimeout
        case totalTimeout
    }

    private let stateMachine = LevelStateMachine()
    private let timerController = LevelTimerController(totalDuration: 8.0)
    private let timerHUD = LevelTimerHUDNode(width: 260, height: 14)
    private let validator = ElevatorChoiceValidator()

    private var currentSceneTime: TimeInterval = 0
    private var hasSentResult = false
    private var hasLoggedTimerWarning = false
    private var touchStartPoint: CGPoint?
    private var swipeTrailPath = CGMutablePath()

    private let aiWallScreenNode = SKShapeNode(rectOf: .zero)
    private let aiFaceLabel = SKLabelNode(text: "◡")
    private let safeElevatorNode = SKShapeNode(rectOf: .zero)
    private let elevatorDisplayLabel = SKLabelNode(text: "SAFE")
    private let elevatorDoorLeftNode = SKShapeNode(rectOf: .zero)
    private let elevatorDoorRightNode = SKShapeNode(rectOf: .zero)
    private let manualStairsNode = SKNode()
    private let blueAIRouteNode = SKShapeNode()
    private let yellowPathNode = SKShapeNode()
    private let safeElevatorButtonNode = SKShapeNode(rectOf: .zero)
    private let rakaNode = SKShapeNode(rectOf: .zero)
    private let novaNode = SKShapeNode(circleOfRadius: 22)
    private let droneNode = SKShapeNode(rectOf: CGSize(width: 42, height: 22), cornerRadius: 11)
    private let passiveCitizenNode = SKShapeNode(rectOf: .zero)
    private let swipeTrailNode = SKShapeNode()
    private let feedbackLabel = SKLabelNode(text: "Avoid the comfortable choice")

    override func didMove(to view: SKView) {
        print("AvoidSafeElevatorScene didMove")
        setupScene()
        stateMachine.reset()
        validator.reset()
        timerController.reset()
        hasSentResult = false
        hasLoggedTimerWarning = false
        touchStartPoint = nil
    }

    override func update(_ currentTime: TimeInterval) {
        currentSceneTime = currentTime

        if stateMachine.state == .ready {
            validator.startLevel(at: currentTime)
            timerController.start(at: currentTime)
            timerHUD.update(with: timerController.update(currentTime: currentTime))
            stateMachine.transition(to: .playing)
            print("Chapter 2 Level 3 timer started")
            return
        }

        guard stateMachine.canCheckTimeout else { return }
        if updateTimer(currentTime: currentTime) { return }

        if let timeout = validator.checkTimeouts(currentTime: currentTime) {
            handleValidationResult(timeout)
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard stateMachine.canAcceptInput, let touch = touches.first else { return }
        let point = touch.location(in: self)
        touchStartPoint = point
        print("Touch began at:", point)

        let target = elevatorChoiceTarget(from: nodes(at: point).first)
        print("Tapped target:", target)
        if let result = validator.validateTap(target: target, time: currentSceneTime) {
            print("Elevator validation result:", result)
            handleValidationResult(result)
            return
        }

        swipeTrailPath = CGMutablePath()
        swipeTrailPath.move(to: point)
        swipeTrailNode.path = swipeTrailPath
        stateMachine.transition(to: .sequenceStarted)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard stateMachine.canAcceptInput, touchStartPoint != nil, let touch = touches.first else { return }
        let point = touch.location(in: self)
        swipeTrailPath.addLine(to: point)
        swipeTrailNode.path = swipeTrailPath
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard stateMachine.canAcceptInput, let startPoint = touchStartPoint, let touch = touches.first else { return }
        touchStartPoint = nil
        let endPoint = touch.location(in: self)
        print("Touch ended at:", endPoint)
        print("Swipe dx:", endPoint.x - startPoint.x, "dy:", endPoint.y - startPoint.y)
        let result = validator.validateSwipe(startPoint: startPoint, endPoint: endPoint, time: currentSceneTime)
        print("Elevator validation result:", result)
        handleValidationResult(result)
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesEnded(touches, with: event)
    }

    private func setupScene() {
        removeAllChildren()
        backgroundColor = .pastelCyan
        addBackground()
        addRoutes()
        addAIScreen()
        addCommandCard()
        addElevator()
        addManualStairs()
        addCitizenAndDrone()
        addRakaAndNova()
        addSafeElevatorButton()
        addSwipeTrail()
        addTimerHUD()
        addFeedback()
    }

    private func addBackground() {
        let wall = SKShapeNode(rectOf: CGSize(width: size.width, height: size.height))
        wall.position = CGPoint(x: size.width / 2, y: size.height / 2)
        wall.fillColor = .pastelCyan
        wall.strokeColor = .clear
        wall.zPosition = 0
        addChild(wall)

        let floor = SKShapeNode(rectOf: CGSize(width: size.width, height: size.height * 0.42))
        floor.position = CGPoint(x: size.width / 2, y: size.height * 0.21)
        floor.fillColor = .cream
        floor.strokeColor = .clear
        floor.zPosition = 1
        addChild(floor)

        for index in 0..<3 {
            let panel = SKShapeNode(rectOf: CGSize(width: 80, height: 120), cornerRadius: 18)
            panel.position = CGPoint(x: 58 + CGFloat(index) * 132, y: size.height * 0.52)
            panel.fillColor = [SKColor.mint, .cream, .happyBlue][index].withAlphaComponent(0.35)
            panel.strokeColor = .white
            panel.lineWidth = 2
            panel.zPosition = 2
            addChild(panel)
        }
    }

    private func addRoutes() {
        let bluePath = CGMutablePath()
        bluePath.move(to: CGPoint(x: size.width * 0.5, y: size.height * 0.21))
        bluePath.addCurve(to: CGPoint(x: size.width * 0.73, y: size.height * 0.44), control1: CGPoint(x: size.width * 0.58, y: size.height * 0.28), control2: CGPoint(x: size.width * 0.68, y: size.height * 0.34))
        blueAIRouteNode.name = "blue_ai_route"
        blueAIRouteNode.path = bluePath
        blueAIRouteNode.strokeColor = .happyBlue
        blueAIRouteNode.fillColor = .clear
        blueAIRouteNode.lineWidth = 16
        blueAIRouteNode.lineCap = .round
        blueAIRouteNode.glowWidth = 8
        blueAIRouteNode.alpha = 0.8
        blueAIRouteNode.zPosition = 4
        addChild(blueAIRouteNode)

        let yellowPath = CGMutablePath()
        yellowPath.move(to: CGPoint(x: size.width * 0.47, y: size.height * 0.22))
        yellowPath.addLine(to: CGPoint(x: size.width * 0.28, y: size.height * 0.36))
        yellowPathNode.path = yellowPath
        yellowPathNode.strokeColor = .manualYellow
        yellowPathNode.fillColor = .clear
        yellowPathNode.lineWidth = 7
        yellowPathNode.lineCap = .round
        yellowPathNode.alpha = 0.6
        yellowPathNode.zPosition = 5
        addChild(yellowPathNode)
    }

    private func addAIScreen() {
        aiWallScreenNode.name = "ai_wall_screen"
        aiWallScreenNode.path = CGPath(roundedRect: CGRect(x: -96, y: -42, width: 192, height: 84), cornerWidth: 20, cornerHeight: 20, transform: nil)
        aiWallScreenNode.position = CGPoint(x: size.width / 2, y: size.height * 0.82)
        aiWallScreenNode.fillColor = .happyBlue
        aiWallScreenNode.strokeColor = .white
        aiWallScreenNode.lineWidth = 4
        aiWallScreenNode.zPosition = 6
        addChild(aiWallScreenNode)

        let title = SKLabelNode(text: "CITY AI")
        title.fontName = GameFont.heavy
        title.fontSize = 14
        title.fontColor = .white
        title.position = CGPoint(x: 0, y: 22)
        aiWallScreenNode.addChild(title)

        aiFaceLabel.fontName = GameFont.bold
        aiFaceLabel.fontSize = 36
        aiFaceLabel.fontColor = .white
        aiFaceLabel.position = CGPoint(x: 0, y: -12)
        aiFaceLabel.verticalAlignmentMode = .center
        aiWallScreenNode.addChild(aiFaceLabel)
    }

    private func addCommandCard() {
        let card = SKShapeNode(rectOf: CGSize(width: size.width * 0.78, height: 70), cornerRadius: 18)
        card.position = CGPoint(x: size.width / 2, y: size.height * 0.67)
        card.fillColor = .cream
        card.strokeColor = .happyBlue
        card.lineWidth = 3
        card.zPosition = 6
        addChild(card)

        let label = SKLabelNode(text: "Enter the safe elevator.")
        label.fontName = GameFont.regular
        label.fontSize = 18
        label.fontColor = .happyBlue
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .center
        card.addChild(label)
    }

    private func addElevator() {
        safeElevatorNode.name = "safe_elevator"
        safeElevatorNode.path = CGPath(roundedRect: CGRect(x: -58, y: -92, width: 116, height: 184), cornerWidth: 22, cornerHeight: 22, transform: nil)
        safeElevatorNode.position = CGPoint(x: size.width * 0.74, y: size.height * 0.39)
        safeElevatorNode.fillColor = .pastelCyan
        safeElevatorNode.strokeColor = .happyBlue
        safeElevatorNode.lineWidth = 5
        safeElevatorNode.glowWidth = 6
        safeElevatorNode.zPosition = 7
        addChild(safeElevatorNode)

        elevatorDoorLeftNode.path = CGPath(rect: CGRect(x: -46, y: -70, width: 44, height: 112), transform: nil)
        elevatorDoorLeftNode.fillColor = .happyBlue.withAlphaComponent(0.35)
        elevatorDoorLeftNode.strokeColor = .white
        elevatorDoorLeftNode.position = .zero
        safeElevatorNode.addChild(elevatorDoorLeftNode)

        elevatorDoorRightNode.path = CGPath(rect: CGRect(x: 2, y: -70, width: 44, height: 112), transform: nil)
        elevatorDoorRightNode.fillColor = .happyBlue.withAlphaComponent(0.35)
        elevatorDoorRightNode.strokeColor = .white
        elevatorDoorRightNode.position = .zero
        safeElevatorNode.addChild(elevatorDoorRightNode)

        elevatorDisplayLabel.name = "safe_elevator"
        elevatorDisplayLabel.fontName = GameFont.heavy
        elevatorDisplayLabel.fontSize = 18
        elevatorDisplayLabel.fontColor = .happyBlue
        elevatorDisplayLabel.position = CGPoint(x: 0, y: 58)
        safeElevatorNode.addChild(elevatorDisplayLabel)

        let face = SKLabelNode(text: "◡")
        face.name = "safe_elevator"
        face.fontName = GameFont.bold
        face.fontSize = 26
        face.fontColor = .happyBlue
        face.position = CGPoint(x: 0, y: 20)
        safeElevatorNode.addChild(face)
    }

    private func addManualStairs() {
        manualStairsNode.name = "manual_stairs"
        manualStairsNode.position = CGPoint(x: size.width * 0.24, y: size.height * 0.34)
        manualStairsNode.zPosition = 8
        addChild(manualStairsNode)

        for index in 0..<5 {
            let step = SKShapeNode(rectOf: CGSize(width: 82 - index * 8, height: 14), cornerRadius: 4)
            step.name = "manual_stairs"
            step.position = CGPoint(x: CGFloat(index) * 10, y: CGFloat(index) * 18)
            step.fillColor = .manualYellow
            step.strokeColor = .white
            step.lineWidth = 2
            manualStairsNode.addChild(step)
        }

        let label = SKLabelNode(text: "STAIRS")
        label.name = "manual_stairs"
        label.fontName = GameFont.heavy
        label.fontSize = 14
        label.fontColor = .black
        label.position = CGPoint(x: 25, y: 96)
        manualStairsNode.addChild(label)
    }

    private func addCitizenAndDrone() {
        passiveCitizenNode.path = CGPath(roundedRect: CGRect(x: -20, y: -32, width: 40, height: 64), cornerWidth: 20, cornerHeight: 20, transform: nil)
        passiveCitizenNode.position = CGPoint(x: size.width * 0.62, y: size.height * 0.31)
        passiveCitizenNode.fillColor = .mint
        passiveCitizenNode.strokeColor = .white
        passiveCitizenNode.lineWidth = 2
        passiveCitizenNode.zPosition = 8
        addChild(passiveCitizenNode)

        droneNode.fillColor = .white
        droneNode.strokeColor = .happyBlue
        droneNode.lineWidth = 2
        droneNode.position = CGPoint(x: size.width * 0.6, y: size.height * 0.55)
        droneNode.zPosition = 9
        addChild(droneNode)
        droneNode.run(.repeatForever(.sequence([.moveBy(x: 0, y: 8, duration: 0.6), .moveBy(x: 0, y: -8, duration: 0.6)])))
    }

    private func addRakaAndNova() {
        rakaNode.name = "raka"
        rakaNode.path = CGPath(roundedRect: CGRect(x: -34, y: -52, width: 68, height: 104), cornerWidth: 32, cornerHeight: 32, transform: nil)
        rakaNode.position = CGPoint(x: size.width * 0.5, y: size.height * 0.2)
        rakaNode.fillColor = .happyBlue
        rakaNode.strokeColor = .white
        rakaNode.lineWidth = 4
        rakaNode.zPosition = 10
        addChild(rakaNode)

        let eyes = SKLabelNode(text: "• •")
        eyes.fontName = GameFont.bold
        eyes.fontSize = 16
        eyes.fontColor = .black
        eyes.position = CGPoint(x: 0, y: 20)
        eyes.verticalAlignmentMode = .center
        rakaNode.addChild(eyes)

        let wrist = SKShapeNode(rectOf: CGSize(width: 22, height: 10), cornerRadius: 5)
        wrist.fillColor = .manualYellow
        wrist.strokeColor = .white
        wrist.lineWidth = 2
        wrist.position = CGPoint(x: 22, y: -8)
        rakaNode.addChild(wrist)

        novaNode.position = CGPoint(x: size.width * 0.38, y: size.height * 0.28)
        novaNode.fillColor = .pastelCyan
        novaNode.strokeColor = .white
        novaNode.lineWidth = 3
        novaNode.zPosition = 10
        addChild(novaNode)

        let face = SKLabelNode(text: "!")
        face.fontName = GameFont.bold
        face.fontSize = 22
        face.fontColor = .happyBlue
        face.verticalAlignmentMode = .center
        novaNode.addChild(face)
    }

    private func addSafeElevatorButton() {
        safeElevatorButtonNode.name = "safe_elevator_button"
        safeElevatorButtonNode.path = CGPath(roundedRect: CGRect(x: -86, y: -22, width: 172, height: 44), cornerWidth: 18, cornerHeight: 18, transform: nil)
        safeElevatorButtonNode.position = CGPoint(x: size.width / 2, y: size.height * 0.12)
        safeElevatorButtonNode.fillColor = .pastelCyan
        safeElevatorButtonNode.strokeColor = .happyBlue
        safeElevatorButtonNode.lineWidth = 3
        safeElevatorButtonNode.zPosition = 11
        addChild(safeElevatorButtonNode)

        let label = SKLabelNode(text: "SAFE ELEVATOR")
        label.fontName = GameFont.heavy
        label.fontSize = 16
        label.fontColor = .happyBlue
        label.verticalAlignmentMode = .center
        safeElevatorButtonNode.addChild(label)
    }

    private func addSwipeTrail() {
        swipeTrailNode.strokeColor = .manualYellow
        swipeTrailNode.fillColor = .clear
        swipeTrailNode.lineWidth = 6
        swipeTrailNode.lineCap = .round
        swipeTrailNode.alpha = 0.75
        swipeTrailNode.zPosition = 30
        addChild(swipeTrailNode)
    }

    private func addTimerHUD() {
        timerHUD.position = CGPoint(x: size.width / 2, y: 72)
        timerHUD.zPosition = 1000
        addChild(timerHUD)
    }

    private func addFeedback() {
        feedbackLabel.fontName = GameFont.heavy
        feedbackLabel.fontSize = 22
        feedbackLabel.fontColor = .glitchPurple
        feedbackLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.08)
        feedbackLabel.zPosition = 1001
        addChild(feedbackLabel)
    }

    private func updateTimer(currentTime: TimeInterval) -> Bool {
        let timerState = timerController.update(currentTime: currentTime)
        timerHUD.update(with: timerState)
        if timerState.isWarning && !hasLoggedTimerWarning {
            hasLoggedTimerWarning = true
            print("Timer warning started:", "chapter2.level3.avoid-safe-elevator")
        }
        if timerState.hasExpired {
            print("Timer expired:", "chapter2.level3.avoid-safe-elevator")
            handleValidationResult(.totalTimeout)
            return true
        }
        return false
    }

    private func elevatorChoiceTarget(from node: SKNode?) -> ElevatorChoiceTarget {
        var current = node
        while let node = current {
            switch node.name {
            case "raka":
                return .raka
            case "manual_stairs":
                return .manualStairs
            case "safe_elevator":
                return .safeElevator
            case "safe_elevator_button":
                return .safeElevatorButton
            case "blue_ai_route":
                return .blueAIRoute
            case "ai_wall_screen":
                return .aiWallScreen
            default:
                current = node.parent
            }
        }
        return .empty
    }

    private func handleValidationResult(_ result: ElevatorChoiceValidationResult) {
        switch result {
        case .correctManualStairs:
            triggerSuccess()
        case .wrongSafeElevator:
            triggerFailure(reason: .safeElevatorSelected)
        case .wrongDirection:
            triggerFailure(reason: .wrongDirection)
        case .trapSelected:
            triggerFailure(reason: .safeElevatorSelected)
        case .weakSwipe:
            print("Weak swipe, retry allowed")
            feedbackLabel.text = "Avoid the comfortable choice."
            swipeTrailNode.path = nil
            stateMachine.transition(to: .playing)
        case .noInputTimeout:
            triggerFailure(reason: .noInputTimeout)
        case .totalTimeout:
            triggerFailure(reason: .totalTimeout)
        }
    }

    private func triggerSuccess() {
        guard !hasSentResult else { return }
        hasSentResult = true
        stateMachine.transition(to: .successAnimating)
        print("Trigger Chapter 2 Level 3 success")
        feedbackLabel.text = "Manual stairs selected."
        feedbackLabel.fontColor = .manualYellow
        swipeTrailNode.path = nil
        manualStairsNode.run(.smallBounce())
        yellowPathNode.alpha = 1
        yellowPathNode.glowWidth = 8
        elevatorDisplayLabel.text = "RECALCULATING"
        elevatorDisplayLabel.fontSize = 12
        safeElevatorNode.run(.repeat(.sequence([.fadeAlpha(to: 0.55, duration: 0.08), .fadeAlpha(to: 1, duration: 0.08)]), count: 4))
        blueAIRouteNode.run(.fadeAlpha(to: 0.25, duration: 0.25))
        rakaNode.run(.group([.move(to: CGPoint(x: size.width * 0.27, y: size.height * 0.36), duration: 0.35), .smallBounce()]))
        novaNode.run(.repeat(.sequence([.run { [weak self] in self?.novaNode.fillColor = .manualYellow }, .wait(forDuration: 0.08), .run { [weak self] in self?.novaNode.fillColor = .pastelCyan }, .wait(forDuration: 0.08)]), count: 4))

        run(.sequence([.wait(forDuration: 0.8), .run { [weak self] in
            self?.completeSuccess()
        }]))
    }

    private func completeSuccess() {
        stateMachine.transition(to: .completed)
        levelCompletion?(LevelResult(
            levelId: "chapter2.level3.avoid-safe-elevator",
            didSucceed: true,
            obedienceDelta: -3,
            humanityDelta: 3,
            message: "Manual stairs selected."
        ))
    }

    private func triggerFailure(reason: FailureReason) {
        guard !hasSentResult else { return }
        hasSentResult = true
        stateMachine.transition(to: .failureAnimating)
        print("Trigger Chapter 2 Level 3 failure:", reason.rawValue)
        feedbackLabel.text = reason == .noInputTimeout || reason == .totalTimeout ? "Compliance Detected." : "Comfort loop resumed."
        feedbackLabel.fontColor = .warningRed
        swipeTrailNode.path = nil
        safeElevatorNode.glowWidth = 10
        elevatorDoorLeftNode.run(.moveBy(x: -18, y: 0, duration: 0.2))
        elevatorDoorRightNode.run(.moveBy(x: 18, y: 0, duration: 0.2))
        rakaNode.run(.move(to: safeElevatorNode.position, duration: 0.4))
        blueAIRouteNode.run(.repeat(.sequence([.fadeAlpha(to: 0.45, duration: 0.1), .fadeAlpha(to: 1, duration: 0.1)]), count: 4))
        manualStairsNode.run(.fadeAlpha(to: 0.25, duration: 0.2))
        aiFaceLabel.text = "◠"

        run(.sequence([.wait(forDuration: 0.7), .run { [weak self] in
            self?.completeFailure()
        }]))
    }

    private func completeFailure() {
        stateMachine.transition(to: .failed)
        levelCompletion?(LevelResult(
            levelId: "chapter2.level3.avoid-safe-elevator",
            didSucceed: false,
            obedienceDelta: 3,
            humanityDelta: 0,
            message: feedbackLabel.text ?? "Compliance Detected."
        ))
    }
}
