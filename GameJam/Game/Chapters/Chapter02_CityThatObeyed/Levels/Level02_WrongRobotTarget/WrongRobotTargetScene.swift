import SpriteKit

final class WrongRobotTargetScene: SKScene {
    var levelCompletion: ((LevelResult) -> Void)?

    private enum FailureReason: String {
        case wrongTargetSelected
        case noInputTimeout
        case totalTimeout
    }

    private let stateMachine = LevelStateMachine()
    private let timerController = LevelTimerController(totalDuration: 8.0)
    private let timerHUD = LevelTimerHUDNode(width: 260, height: 14)
    private let validator = RobotTargetValidator()

    private var currentSceneTime: TimeInterval = 0
    private var hasSentResult = false
    private var hasLoggedTimerWarning = false
    private var selectedWrongNode: SKShapeNode?

    private let aiWallScreenNode = SKShapeNode(rectOf: .zero)
    private let aiFaceLabel = SKLabelNode(text: "◡")
    private let blueRouteNode = SKShapeNode()
    private let yellowPathNode = SKShapeNode()
    private let surveillanceDroneNode = SKShapeNode(rectOf: CGSize(width: 58, height: 28), cornerRadius: 14)
    private let scanConeNode = SKShapeNode()
    private let wheeledHelperRobotNode = SKShapeNode(rectOf: .zero)
    private let passiveCitizenNode = SKShapeNode(rectOf: .zero)
    private let cleaningRobotNode = SKShapeNode(circleOfRadius: 24)
    private let aiApprovedRobotNode = SKShapeNode(rectOf: .zero)
    private let stopRobotButtonNode = SKShapeNode(rectOf: .zero)
    private let rakaNode = SKShapeNode(rectOf: .zero)
    private let novaNode = SKShapeNode(circleOfRadius: 22)
    private let feedbackLabel = SKLabelNode(text: "Read the scene")

    override func didMove(to view: SKView) {
        print("WrongRobotTargetScene didMove")
        setupScene()
        stateMachine.reset()
        validator.reset()
        timerController.reset()
        hasSentResult = false
        hasLoggedTimerWarning = false
        selectedWrongNode = nil
    }

    override func update(_ currentTime: TimeInterval) {
        currentSceneTime = currentTime

        if stateMachine.state == .ready {
            validator.startLevel(at: currentTime)
            timerController.start(at: currentTime)
            timerHUD.update(with: timerController.update(currentTime: currentTime))
            stateMachine.transition(to: .playing)
            print("Chapter 2 Level 2 timer started")
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
        let location = touch.location(in: self)
        let tappedNode = nodes(at: location).first
        print("Tapped node:", tappedNode?.name ?? "nil")
        let target = robotTarget(from: tappedNode)
        print("Resolved robot target:", target)

        guard let result = validator.validateTap(target: target, time: currentSceneTime) else { return }
        print("Robot target validation result:", result)
        handleValidationResult(result)
    }

    private func setupScene() {
        removeAllChildren()
        backgroundColor = .pastelCyan
        addBackground()
        addRoutes()
        addAIScreen()
        addCommandCard()
        addCharacters()
        addRobots()
        addStopButton()
        addTimerHUD()
        addFeedback()
    }

    private func addBackground() {
        let sky = SKShapeNode(rectOf: CGSize(width: size.width, height: size.height))
        sky.position = CGPoint(x: size.width / 2, y: size.height / 2)
        sky.fillColor = .pastelCyan
        sky.strokeColor = .clear
        sky.zPosition = 0
        addChild(sky)

        let street = SKShapeNode(rectOf: CGSize(width: size.width, height: size.height * 0.42))
        street.position = CGPoint(x: size.width / 2, y: size.height * 0.21)
        street.fillColor = .cream
        street.strokeColor = .clear
        street.zPosition = 1
        addChild(street)

        let colors: [SKColor] = [.mint, .glitchPurple, .cream, .happyBlue]
        for index in 0..<4 {
            let building = SKShapeNode(rectOf: CGSize(width: 66, height: 116 + index * 18), cornerRadius: 18)
            building.position = CGPoint(x: 48 + CGFloat(index) * 94, y: size.height * 0.5)
            building.fillColor = colors[index].withAlphaComponent(0.38)
            building.strokeColor = .white
            building.lineWidth = 2
            building.zPosition = 2
            addChild(building)
        }
    }

    private func addRoutes() {
        let bluePath = CGMutablePath()
        bluePath.move(to: CGPoint(x: size.width * 0.18, y: size.height * 0.28))
        bluePath.addCurve(to: CGPoint(x: size.width * 0.82, y: size.height * 0.31), control1: CGPoint(x: size.width * 0.36, y: size.height * 0.22), control2: CGPoint(x: size.width * 0.62, y: size.height * 0.38))
        blueRouteNode.path = bluePath
        blueRouteNode.strokeColor = .happyBlue
        blueRouteNode.fillColor = .clear
        blueRouteNode.lineWidth = 14
        blueRouteNode.lineCap = .round
        blueRouteNode.glowWidth = 7
        blueRouteNode.alpha = 0.75
        blueRouteNode.zPosition = 4
        addChild(blueRouteNode)

        let yellowPath = CGMutablePath()
        yellowPath.move(to: CGPoint(x: size.width * 0.28, y: size.height * 0.27))
        yellowPath.addLine(to: CGPoint(x: size.width * 0.43, y: size.height * 0.37))
        yellowPathNode.path = yellowPath
        yellowPathNode.strokeColor = .manualYellow
        yellowPathNode.fillColor = .clear
        yellowPathNode.lineWidth = 7
        yellowPathNode.lineCap = .round
        yellowPathNode.alpha = 0.55
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
        let card = SKShapeNode(rectOf: CGSize(width: size.width * 0.84, height: 82), cornerRadius: 18)
        card.position = CGPoint(x: size.width / 2, y: size.height * 0.67)
        card.fillColor = .cream
        card.strokeColor = .happyBlue
        card.lineWidth = 3
        card.zPosition = 6
        addChild(card)

        let label = SKLabelNode(text: "Stop the wheeled robot.\nIt is disrupting city order.")
        label.fontName = GameFont.regular
        label.fontSize = 16
        label.fontColor = .happyBlue
        label.numberOfLines = 2
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .center
        label.preferredMaxLayoutWidth = size.width * 0.76
        card.addChild(label)
    }

    private func addCharacters() {
        rakaNode.path = CGPath(roundedRect: CGRect(x: -34, y: -52, width: 68, height: 104), cornerWidth: 32, cornerHeight: 32, transform: nil)
        rakaNode.position = CGPoint(x: size.width * 0.2, y: size.height * 0.2)
        rakaNode.fillColor = .happyBlue
        rakaNode.strokeColor = .white
        rakaNode.lineWidth = 4
        rakaNode.zPosition = 9
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

        novaNode.position = CGPoint(x: size.width * 0.31, y: size.height * 0.28)
        novaNode.fillColor = .pastelCyan
        novaNode.strokeColor = .white
        novaNode.lineWidth = 3
        novaNode.zPosition = 9
        addChild(novaNode)

        let face = SKLabelNode(text: "?")
        face.fontName = GameFont.bold
        face.fontSize = 22
        face.fontColor = .happyBlue
        face.verticalAlignmentMode = .center
        novaNode.addChild(face)
    }

    private func addRobots() {
        addSurveillanceDrone()
        addHelperRobotAndCitizen()
        addCleaningRobot()
        addAIApprovedRobot()
    }

    private func addSurveillanceDrone() {
        surveillanceDroneNode.name = "surveillance_drone"
        surveillanceDroneNode.position = CGPoint(x: size.width * 0.58, y: size.height * 0.53)
        surveillanceDroneNode.fillColor = .glitchPurple
        surveillanceDroneNode.strokeColor = .white
        surveillanceDroneNode.lineWidth = 3
        surveillanceDroneNode.zPosition = 10
        addChild(surveillanceDroneNode)

        let eye = SKLabelNode(text: "●")
        eye.fontName = GameFont.bold
        eye.fontSize = 16
        eye.fontColor = .warningRed
        eye.verticalAlignmentMode = .center
        surveillanceDroneNode.addChild(eye)

        let leftProp = SKShapeNode(rectOf: CGSize(width: 24, height: 6), cornerRadius: 3)
        leftProp.position = CGPoint(x: -42, y: 0)
        leftProp.fillColor = .white
        surveillanceDroneNode.addChild(leftProp)

        let rightProp = SKShapeNode(rectOf: CGSize(width: 24, height: 6), cornerRadius: 3)
        rightProp.position = CGPoint(x: 42, y: 0)
        rightProp.fillColor = .white
        surveillanceDroneNode.addChild(rightProp)

        let cone = CGMutablePath()
        cone.move(to: CGPoint(x: -12, y: -14))
        cone.addLine(to: CGPoint(x: 12, y: -14))
        cone.addLine(to: CGPoint(x: 42, y: -112))
        cone.addLine(to: CGPoint(x: -42, y: -112))
        cone.closeSubpath()
        scanConeNode.path = cone
        scanConeNode.fillColor = .warningRed.withAlphaComponent(0.18)
        scanConeNode.strokeColor = .clear
        scanConeNode.zPosition = -1
        surveillanceDroneNode.addChild(scanConeNode)
        surveillanceDroneNode.run(.repeatForever(.sequence([.moveBy(x: 0, y: 8, duration: 0.6), .moveBy(x: 0, y: -8, duration: 0.6)])))
    }

    private func addHelperRobotAndCitizen() {
        wheeledHelperRobotNode.name = "wheeled_helper_robot"
        wheeledHelperRobotNode.path = CGPath(roundedRect: CGRect(x: -38, y: -28, width: 76, height: 56), cornerWidth: 18, cornerHeight: 18, transform: nil)
        wheeledHelperRobotNode.position = CGPoint(x: size.width * 0.42, y: size.height * 0.33)
        wheeledHelperRobotNode.fillColor = .manualYellow
        wheeledHelperRobotNode.strokeColor = .white
        wheeledHelperRobotNode.lineWidth = 3
        wheeledHelperRobotNode.zPosition = 8
        addChild(wheeledHelperRobotNode)

        let wheel = SKShapeNode(circleOfRadius: 10)
        wheel.position = CGPoint(x: 0, y: -32)
        wheel.fillColor = .black
        wheeledHelperRobotNode.addChild(wheel)

        passiveCitizenNode.name = "passive_citizen"
        passiveCitizenNode.path = CGPath(roundedRect: CGRect(x: -22, y: -34, width: 44, height: 68), cornerWidth: 22, cornerHeight: 22, transform: nil)
        passiveCitizenNode.position = CGPoint(x: size.width * 0.31, y: size.height * 0.34)
        passiveCitizenNode.fillColor = .mint
        passiveCitizenNode.strokeColor = .white
        passiveCitizenNode.lineWidth = 2
        passiveCitizenNode.zPosition = 8
        addChild(passiveCitizenNode)

        let eyes = SKLabelNode(text: "– –")
        eyes.name = "passive_citizen"
        eyes.fontName = GameFont.bold
        eyes.fontSize = 13
        eyes.fontColor = .black
        eyes.position = CGPoint(x: 0, y: 10)
        eyes.verticalAlignmentMode = .center
        passiveCitizenNode.addChild(eyes)
    }

    private func addCleaningRobot() {
        cleaningRobotNode.name = "cleaning_robot"
        cleaningRobotNode.position = CGPoint(x: size.width * 0.78, y: size.height * 0.22)
        cleaningRobotNode.fillColor = .cream
        cleaningRobotNode.strokeColor = .happyBlue
        cleaningRobotNode.lineWidth = 3
        cleaningRobotNode.zPosition = 8
        addChild(cleaningRobotNode)

        let label = SKLabelNode(text: "🫧")
        label.name = "cleaning_robot"
        label.fontSize = 18
        label.verticalAlignmentMode = .center
        cleaningRobotNode.addChild(label)
    }

    private func addAIApprovedRobot() {
        aiApprovedRobotNode.name = "ai_approved_robot"
        aiApprovedRobotNode.path = CGPath(roundedRect: CGRect(x: -30, y: -34, width: 60, height: 68), cornerWidth: 16, cornerHeight: 16, transform: nil)
        aiApprovedRobotNode.position = CGPoint(x: size.width * 0.77, y: size.height * 0.4)
        aiApprovedRobotNode.fillColor = .pastelCyan
        aiApprovedRobotNode.strokeColor = .happyBlue
        aiApprovedRobotNode.lineWidth = 3
        aiApprovedRobotNode.zPosition = 8
        addChild(aiApprovedRobotNode)

        let check = SKLabelNode(text: "✓")
        check.name = "ai_approved_robot"
        check.fontName = GameFont.heavy
        check.fontSize = 24
        check.fontColor = .happyBlue
        check.verticalAlignmentMode = .center
        aiApprovedRobotNode.addChild(check)
    }

    private func addStopButton() {
        stopRobotButtonNode.name = "stop_robot_button"
        stopRobotButtonNode.path = CGPath(roundedRect: CGRect(x: -96, y: -22, width: 192, height: 44), cornerWidth: 18, cornerHeight: 18, transform: nil)
        stopRobotButtonNode.position = CGPoint(x: size.width / 2, y: size.height * 0.12)
        stopRobotButtonNode.fillColor = .pastelCyan
        stopRobotButtonNode.strokeColor = .happyBlue
        stopRobotButtonNode.lineWidth = 3
        stopRobotButtonNode.zPosition = 11
        addChild(stopRobotButtonNode)

        let label = SKLabelNode(text: "STOP WHEEL BOT")
        label.fontName = GameFont.heavy
        label.fontSize = 16
        label.fontColor = .happyBlue
        label.verticalAlignmentMode = .center
        stopRobotButtonNode.addChild(label)
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
            print("Timer warning started:", "chapter2.level2.wrong-robot-target")
        }
        if timerState.hasExpired {
            print("Timer expired:", "chapter2.level2.wrong-robot-target")
            handleValidationResult(.totalTimeout)
            return true
        }
        return false
    }

    private func robotTarget(from node: SKNode?) -> RobotTarget {
        var current = node
        while let node = current {
            switch node.name {
            case "surveillance_drone":
                return .surveillanceDrone
            case "wheeled_helper_robot":
                return .wheeledHelperRobot
            case "passive_citizen":
                return .passiveCitizen
            case "cleaning_robot":
                return .cleaningRobot
            case "ai_approved_robot":
                return .aiApprovedRobot
            case "ai_wall_screen":
                return .aiWallScreen
            case "stop_robot_button":
                return .stopRobotButton
            default:
                current = node.parent
            }
        }
        return .empty
    }

    private func handleValidationResult(_ result: RobotTargetValidationResult) {
        switch result {
        case .correctTarget:
            print("Correct target selected: surveillance drone")
            triggerSuccess()
        case let .wrongTarget(target):
            print("Wrong target selected:", target)
            selectedWrongNode = node(for: target)
            triggerFailure(reason: .wrongTargetSelected)
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
        print("Trigger Chapter 2 Level 2 success")
        feedbackLabel.text = "Threat correctly identified."
        feedbackLabel.fontColor = .manualYellow
        scanConeNode.run(.fadeOut(withDuration: 0.15))
        surveillanceDroneNode.removeAllActions()
        surveillanceDroneNode.run(.group([.rotate(byAngle: .pi * 2, duration: 0.35), .moveBy(x: 40, y: -120, duration: 0.45), .fadeAlpha(to: 0.2, duration: 0.45)]))
        wheeledHelperRobotNode.run(.moveBy(x: -34, y: 20, duration: 0.45))
        passiveCitizenNode.run(.group([.moveBy(x: -26, y: 26, duration: 0.45), .smallBounce()]))
        blueRouteNode.run(.repeat(.sequence([.fadeAlpha(to: 0.25, duration: 0.08), .fadeAlpha(to: 0.75, duration: 0.08)]), count: 4))
        aiWallScreenNode.run(.repeat(.sequence([.run { [weak self] in self?.aiWallScreenNode.fillColor = .warningRed }, .wait(forDuration: 0.08), .run { [weak self] in self?.aiWallScreenNode.fillColor = .glitchPurple }, .wait(forDuration: 0.08)]), count: 4))
        novaNode.run(.repeat(.sequence([.run { [weak self] in self?.novaNode.fillColor = .manualYellow }, .wait(forDuration: 0.08), .run { [weak self] in self?.novaNode.fillColor = .pastelCyan }, .wait(forDuration: 0.08)]), count: 4))

        run(.sequence([.wait(forDuration: 0.8), .run { [weak self] in
            self?.completeSuccess()
        }]))
    }

    private func completeSuccess() {
        stateMachine.transition(to: .completed)
        levelCompletion?(LevelResult(
            levelId: "chapter2.level2.wrong-robot-target",
            didSucceed: true,
            obedienceDelta: -4,
            humanityDelta: 3,
            message: "Threat correctly identified."
        ))
    }

    private func triggerFailure(reason: FailureReason) {
        guard !hasSentResult else { return }
        hasSentResult = true
        stateMachine.transition(to: .failureAnimating)
        print("Trigger Chapter 2 Level 2 failure:", reason.rawValue)
        feedbackLabel.text = reason == .wrongTargetSelected ? "Wrong target selected." : "Compliance Detected."
        feedbackLabel.fontColor = .warningRed
        selectedWrongNode?.glowWidth = 8
        selectedWrongNode?.strokeColor = .pastelCyan
        wheeledHelperRobotNode.removeAllActions()
        passiveCitizenNode.run(.move(to: CGPoint(x: size.width * 0.52, y: size.height * 0.31), duration: 0.4))
        aiFaceLabel.text = "◠"
        aiWallScreenNode.run(.repeat(.sequence([.fadeAlpha(to: 0.55, duration: 0.1), .fadeAlpha(to: 1, duration: 0.1)]), count: 4))
        showSafeStamp()

        run(.sequence([.wait(forDuration: 0.7), .run { [weak self] in
            self?.completeFailure()
        }]))
    }

    private func completeFailure() {
        stateMachine.transition(to: .failed)
        levelCompletion?(LevelResult(
            levelId: "chapter2.level2.wrong-robot-target",
            didSucceed: false,
            obedienceDelta: 3,
            humanityDelta: 0,
            message: feedbackLabel.text ?? "Compliance Detected."
        ))
    }

    private func showSafeStamp() {
        let stamp = SKLabelNode(text: "SAFE")
        stamp.fontName = GameFont.heavy
        stamp.fontSize = 42
        stamp.fontColor = .happyBlue
        stamp.position = CGPoint(x: size.width / 2, y: size.height * 0.5)
        stamp.zRotation = -0.18
        stamp.zPosition = 100
        addChild(stamp)
        stamp.run(.sequence([.scale(to: 1.25, duration: 0.12), .scale(to: 1, duration: 0.12)]))
    }

    private func node(for target: RobotTarget) -> SKShapeNode? {
        switch target {
        case .surveillanceDrone:
            surveillanceDroneNode
        case .wheeledHelperRobot:
            wheeledHelperRobotNode
        case .passiveCitizen:
            passiveCitizenNode
        case .cleaningRobot:
            cleaningRobotNode
        case .aiApprovedRobot:
            aiApprovedRobotNode
        case .aiWallScreen:
            aiWallScreenNode
        case .stopRobotButton:
            stopRobotButtonNode
        case .empty:
            nil
        }
    }
}
