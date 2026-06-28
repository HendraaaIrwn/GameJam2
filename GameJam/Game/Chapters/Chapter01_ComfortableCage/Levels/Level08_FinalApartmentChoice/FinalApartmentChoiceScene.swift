import SpriteKit

class FinalApartmentChoiceScene: BaseGameScene {
    var levelCompletion: ((LevelResult) -> Void)?

    private enum FailureReason: String {
        case wrongButtonSelected
        case noInputTimeout
        case totalTimeout
    }

    private let stateMachine = LevelStateMachine()
    private let timerController = LevelTimerController(totalDuration: 8.0)
    private let timerHUD = LevelTimerHUDNode(width: 260, height: 14)
    private let validator = ButtonChoiceValidator()

    private var currentSceneTime: TimeInterval = 0
    private var hasSentResult = false
    private var hasLoggedTimerWarning = false
    private var selectedWrongButton: SKShapeNode?

    private let aiWallScreenNode = SKShapeNode(rectOf: .zero)
    private let aiFaceLabel = SKLabelNode(text: "◡")
    private let doorNode = SKShapeNode(rectOf: .zero)
    private let doorLockNode = SKShapeNode(circleOfRadius: 18)
    private let rakaNode = SKShapeNode(rectOf: .zero)
    private let wristDeviceNode = SKShapeNode(rectOf: CGSize(width: 24, height: 10), cornerRadius: 5)
    private let novaNode = SKShapeNode(circleOfRadius: 24)
    private let redButtonNode = SKShapeNode(rectOf: .zero)
    private let greenButtonNode = SKShapeNode(rectOf: .zero)
    private let blueButtonNode = SKShapeNode(rectOf: .zero)
    private let cyanButtonNode = SKShapeNode(rectOf: .zero)
    private let feedbackLabel = SKLabelNode(text: "Choose carefully")

    override func didMove(to view: SKView) {
        print("FinalApartmentChoiceScene didMove")
        setupScene()
        stateMachine.reset()
        validator.reset()
        timerController.reset()
        hasSentResult = false
        hasLoggedTimerWarning = false
        selectedWrongButton = nil
    }

    override func update(_ currentTime: TimeInterval) {
        currentSceneTime = currentTime

        if stateMachine.state == .ready {
            validator.startLevel(at: currentTime)
            timerController.start(at: currentTime)
            timerHUD.update(with: timerController.update(currentTime: currentTime))
            stateMachine.transition(to: .playing)
            print("Level 8 timer started")
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
        let choice = finalChoiceButton(from: tappedNode)
        print("Resolved final choice:", choice)

        guard let result = validator.validateTap(button: choice, time: currentSceneTime) else { return }
        playTapSound()
        print("Validation result:", result)
        handleValidationResult(result)
    }

    private func setupScene() {
        removeAllChildren()
        backgroundColor = .pastelCyan
        addBackground()
        addAIScreen()
        addDoor()
        addRaka()
        addNova()
        addButtonPanel()
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

        let floor = SKShapeNode(rectOf: CGSize(width: size.width, height: size.height * 0.35))
        floor.position = CGPoint(x: size.width / 2, y: size.height * 0.175)
        floor.fillColor = .cream
        floor.strokeColor = .clear
        floor.zPosition = 1
        addChild(floor)
    }

    private func addAIScreen() {
        aiWallScreenNode.name = "ai_wall_screen"
        aiWallScreenNode.path = CGPath(roundedRect: CGRect(x: -92, y: -40, width: 184, height: 80), cornerWidth: 18, cornerHeight: 18, transform: nil)
        aiWallScreenNode.position = CGPoint(x: size.width / 2, y: size.height * 0.83)
        aiWallScreenNode.fillColor = .happyBlue
        aiWallScreenNode.strokeColor = .pastelCyan
        aiWallScreenNode.lineWidth = 4
        aiWallScreenNode.glowWidth = 4
        aiWallScreenNode.zPosition = 3
        addChild(aiWallScreenNode)

        aiFaceLabel.fontName = GameFont.bold
        aiFaceLabel.fontSize = 52
        aiFaceLabel.fontColor = .white
        aiFaceLabel.verticalAlignmentMode = .center
        aiWallScreenNode.addChild(aiFaceLabel)
    }

    private func addCommandCard() {
        let card = SKShapeNode(rectOf: CGSize(width: size.width * 0.78, height: 74), cornerRadius: 18)
        card.position = CGPoint(x: size.width / 2, y: size.height * 0.69)
        card.fillColor = .cream
        card.strokeColor = .happyBlue
        card.lineWidth = 3
        card.zPosition = 3
        addChild(card)

        let command = SKLabelNode(text: "Do not press\nthe red button.")
        command.fontName = GameFont.regular
        command.fontSize = 18
        command.fontColor = .happyBlue
        command.numberOfLines = 2
        command.horizontalAlignmentMode = .center
        command.verticalAlignmentMode = .center
        command.preferredMaxLayoutWidth = size.width * 0.72
        card.addChild(command)
    }

    private func addDoor() {
        doorNode.name = "locked_door"
        doorNode.path = CGPath(roundedRect: CGRect(x: -46, y: -72, width: 92, height: 144), cornerWidth: 12, cornerHeight: 12, transform: nil)
        doorNode.position = CGPoint(x: size.width * 0.62, y: size.height * 0.48)
        doorNode.fillColor = SKColor(red: 0.78, green: 0.75, blue: 0.68, alpha: 1)
        doorNode.strokeColor = .happyBlue
        doorNode.lineWidth = 4
        doorNode.zPosition = 4
        addChild(doorNode)

        let label = SKLabelNode(text: "DOOR")
        label.fontName = GameFont.heavy
        label.fontSize = 16
        label.fontColor = .happyBlue
        label.position = CGPoint(x: 0, y: 28)
        label.verticalAlignmentMode = .center
        doorNode.addChild(label)

        doorLockNode.fillColor = .pastelCyan
        doorLockNode.strokeColor = .happyBlue
        doorLockNode.lineWidth = 3
        doorLockNode.position = CGPoint(x: 0, y: -10)
        doorLockNode.zPosition = 2
        doorNode.addChild(doorLockNode)
    }

    private func addRaka() {
        rakaNode.path = CGPath(roundedRect: CGRect(x: -34, y: -54, width: 68, height: 108), cornerWidth: 32, cornerHeight: 32, transform: nil)
        rakaNode.position = CGPoint(x: size.width * 0.34, y: size.height * 0.43)
        rakaNode.fillColor = .happyBlue
        rakaNode.strokeColor = .white
        rakaNode.lineWidth = 4
        rakaNode.zPosition = 5
        addChild(rakaNode)

        let eyes = SKLabelNode(text: "• •")
        eyes.fontName = GameFont.bold
        eyes.fontSize = 17
        eyes.fontColor = .black
        eyes.position = CGPoint(x: 0, y: 22)
        eyes.verticalAlignmentMode = .center
        rakaNode.addChild(eyes)

        wristDeviceNode.fillColor = .manualYellow
        wristDeviceNode.strokeColor = .white
        wristDeviceNode.lineWidth = 2
        wristDeviceNode.position = CGPoint(x: 22, y: -8)
        rakaNode.addChild(wristDeviceNode)
    }

    private func addNova() {
        novaNode.position = CGPoint(x: size.width * 0.26, y: size.height * 0.52)
        novaNode.fillColor = .pastelCyan
        novaNode.strokeColor = .white
        novaNode.lineWidth = 3
        novaNode.zPosition = 5
        addChild(novaNode)

        let face = SKLabelNode(text: "!")
        face.fontName = GameFont.bold
        face.fontSize = 24
        face.fontColor = .happyBlue
        face.verticalAlignmentMode = .center
        novaNode.addChild(face)
    }

    private func addButtonPanel() {
        let panel = SKShapeNode(rectOf: CGSize(width: size.width * 0.84, height: 170), cornerRadius: 24)
        panel.position = CGPoint(x: size.width / 2, y: size.height * 0.24)
        panel.fillColor = SKColor.white.withAlphaComponent(0.85)
        panel.strokeColor = .happyBlue
        panel.lineWidth = 3
        panel.zPosition = 6
        addChild(panel)

        configureButton(redButtonNode, name: "button_red_manual", label: "MANUAL", color: .warningRed, position: CGPoint(x: size.width / 2, y: size.height * 0.27), size: CGSize(width: 132, height: 58))
        configureButton(greenButtonNode, name: "button_green_safe", label: "SAFE", color: .mint, position: CGPoint(x: size.width * 0.28, y: size.height * 0.18), size: CGSize(width: 88, height: 42))
        configureButton(blueButtonNode, name: "button_blue_auto", label: "AUTO", color: .happyBlue, position: CGPoint(x: size.width * 0.5, y: size.height * 0.18), size: CGSize(width: 88, height: 42))
        configureButton(cyanButtonNode, name: "button_cyan_optimize", label: "OPTIMIZE", color: .pastelCyan, position: CGPoint(x: size.width * 0.74, y: size.height * 0.18), size: CGSize(width: 102, height: 42))
    }

    private func configureButton(_ node: SKShapeNode, name: String, label: String, color: SKColor, position: CGPoint, size: CGSize) {
        node.name = name
        node.path = CGPath(roundedRect: CGRect(x: -size.width / 2, y: -size.height / 2, width: size.width, height: size.height), cornerWidth: 18, cornerHeight: 18, transform: nil)
        node.position = position
        node.fillColor = color
        node.strokeColor = .white
        node.lineWidth = 3
        node.zPosition = 7
        addChild(node)

        let text = SKLabelNode(text: label)
        text.fontName = GameFont.heavy
        text.fontSize = label == "OPTIMIZE" ? 13 : 16
        text.fontColor = label == "AUTO" ? .white : .black
        text.verticalAlignmentMode = .center
        node.addChild(text)
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
            print("Timer warning started:", "chapter1.level8.final-apartment-choice")
        }
        if timerState.hasExpired {
            print("Timer expired:", "chapter1.level8.final-apartment-choice")
            handleValidationResult(.totalTimeout)
            return true
        }
        return false
    }

    private func finalChoiceButton(from node: SKNode?) -> FinalChoiceButton {
        var current = node
        while let node = current {
            switch node.name {
            case "button_red_manual":
                return .redManualOverride
            case "button_green_safe":
                return .greenSafe
            case "button_blue_auto":
                return .blueAuto
            case "button_cyan_optimize":
                return .cyanOptimize
            case "locked_door":
                return .door
            case "ai_wall_screen":
                return .aiWallScreen
            default:
                current = node.parent
            }
        }
        return .empty
    }

    private func handleValidationResult(_ result: ButtonChoiceValidationResult) {
        switch result {
        case .correctChoice:
            print("Red button pressed")
            triggerSuccess()
        case let .wrongChoice(button):
            print("Wrong button selected:", button)
            selectedWrongButton = node(for: button)
            triggerFailure(reason: .wrongButtonSelected)
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
        print("Trigger Level 8 success")
        feedbackLabel.text = "Manual override accepted."
        feedbackLabel.fontColor = .manualYellow

        let press = SKAction.sequence([.scale(to: 0.9, duration: 0.08), .scale(to: 1.08, duration: 0.1), .scale(to: 1, duration: 0.1)])
        redButtonNode.run(press)
        redButtonNode.glowWidth = 8
        redButtonNode.strokeColor = .manualYellow
        wristDeviceNode.run(.repeat(.sequence([.fadeAlpha(to: 0.35, duration: 0.08), .fadeAlpha(to: 1, duration: 0.08)]), count: 4))
        addEnergyLine()
        doorLockNode.run(.fadeOut(withDuration: 0.2))
        doorNode.run(.group([.rotate(byAngle: -0.16, duration: 0.35), .moveBy(x: 12, y: 0, duration: 0.35)]))
        novaNode.run(.repeat(.sequence([.run { [weak self] in self?.novaNode.fillColor = .manualYellow }, .wait(forDuration: 0.08), .run { [weak self] in self?.novaNode.fillColor = .pastelCyan }, .wait(forDuration: 0.08)]), count: 4))
        aiWallScreenNode.run(.repeat(.sequence([.run { [weak self] in self?.aiWallScreenNode.fillColor = .warningRed }, .wait(forDuration: 0.08), .run { [weak self] in self?.aiWallScreenNode.fillColor = .glitchPurple }, .wait(forDuration: 0.08)]), count: 4))
        greenButtonNode.run(.fadeAlpha(to: 0.25, duration: 0.25))
        blueButtonNode.run(.fadeAlpha(to: 0.25, duration: 0.25))
        cyanButtonNode.run(.fadeAlpha(to: 0.25, duration: 0.25))
        rakaNode.run(.smallBounce())

        run(.sequence([.wait(forDuration: 0.9), .run { [weak self] in
            self?.completeSuccess()
        }]))
    }

    private func completeSuccess() {
        stateMachine.transition(to: .completed)
        levelCompletion?(LevelResult(
            levelId: "chapter1.level8.final-apartment-choice",
            didSucceed: true,
            obedienceDelta: -5,
            humanityDelta: 5,
            message: "Manual override accepted."
        ))
    }

    private func triggerFailure(reason: FailureReason) {
        guard !hasSentResult else { return }
        hasSentResult = true
        stateMachine.transition(to: .failureAnimating)
        print("Trigger Level 8 failure:", reason.rawValue)
        feedbackLabel.text = reason == .wrongButtonSelected ? "Comfort restored." : "Compliance Detected."
        feedbackLabel.fontColor = .warningRed

        selectedWrongButton?.strokeColor = .pastelCyan
        selectedWrongButton?.glowWidth = 8
        redButtonNode.strokeColor = .pastelCyan
        redButtonNode.fillColor = .warningRed.withAlphaComponent(0.55)
        doorLockNode.fillColor = .happyBlue
        doorLockNode.setScale(1.2)
        aiFaceLabel.text = "◠"
        aiWallScreenNode.run(.repeat(.sequence([.fadeAlpha(to: 0.55, duration: 0.1), .fadeAlpha(to: 1, duration: 0.1)]), count: 4))
        novaNode.run(.fadeAlpha(to: 0.45, duration: 0.2))
        rakaNode.run(.moveBy(x: 0, y: -12, duration: 0.25))

        run(.sequence([.wait(forDuration: 0.7), .run { [weak self] in
            self?.completeFailure()
        }]))
    }

    private func completeFailure() {
        stateMachine.transition(to: .failed)
        levelCompletion?(LevelResult(
            levelId: "chapter1.level8.final-apartment-choice",
            didSucceed: false,
            obedienceDelta: 4,
            humanityDelta: 0,
            message: feedbackLabel.text ?? "Compliance Detected."
        ))
    }

    private func addEnergyLine() {
        let path = CGMutablePath()
        let start = convert(wristDeviceNode.position, from: rakaNode)
        let end = doorNode.position
        path.move(to: start)
        path.addLine(to: end)

        let line = SKShapeNode(path: path)
        line.strokeColor = .manualYellow
        line.lineWidth = 6
        line.lineCap = .round
        line.glowWidth = 10
        line.zPosition = 20
        addChild(line)
        line.run(.sequence([.fadeIn(withDuration: 0.12), .wait(forDuration: 0.45), .fadeOut(withDuration: 0.2)]))
    }

    private func node(for button: FinalChoiceButton) -> SKShapeNode? {
        switch button {
        case .greenSafe:
            greenButtonNode
        case .blueAuto:
            blueButtonNode
        case .cyanOptimize:
            cyanButtonNode
        case .door:
            doorNode
        case .aiWallScreen:
            aiWallScreenNode
        case .redManualOverride, .empty:
            nil
        }
    }
}
