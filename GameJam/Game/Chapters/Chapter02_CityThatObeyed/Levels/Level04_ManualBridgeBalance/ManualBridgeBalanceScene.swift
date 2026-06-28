import SpriteKit

@MainActor
class ManualBridgeBalanceScene: BaseGameScene {
    var levelCompletion: ((LevelResult) -> Void)?

    private let stateMachine = LevelStateMachine()
    private let timerController = LevelTimerController(totalDuration: 10)
    private let validator = BridgeBalanceValidator()
    private let motionInput = MotionBalanceInput()

    private let timerHUD = LevelTimerHUDNode(width: 260, height: 14)
    private let feedbackLabel = SKLabelNode(text: "Keep the yellow bridge centered.")
    private let rakaNode = SKShapeNode(circleOfRadius: 22)
    private let novaNode = SKShapeNode(circleOfRadius: 12)
    private let bridgeNode = SKShapeNode(rectOf: CGSize(width: 250, height: 18), cornerRadius: 9)
    private let blueRouteNode = SKShapeNode(rectOf: CGSize(width: 290, height: 22), cornerRadius: 11)
    private let aiWallScreenNode = SKShapeNode(rectOf: CGSize(width: 178, height: 76), cornerRadius: 18)
    private let aiFaceLabel = SKLabelNode(text: "🙂")
    private let autoPathButtonNode = SKShapeNode(rectOf: CGSize(width: 150, height: 48), cornerRadius: 18)
    private let balanceMarkerNode = SKShapeNode(rectOf: CGSize(width: 10, height: 48), cornerRadius: 5)
    private let safeProgressNode = SKShapeNode(rectOf: CGSize(width: 1, height: 10), cornerRadius: 5)
    private let leftPlatformNode = SKShapeNode(rectOf: CGSize(width: 46, height: 18), cornerRadius: 9)
    private let rightPlatformNode = SKShapeNode(rectOf: CGSize(width: 46, height: 18), cornerRadius: 9)

    private var touchStartPoint: CGPoint?
    private var fallbackTiltInput: CGFloat = 0

    override func didMove(to view: SKView) {
        backgroundColor = .pastelCyan
        addBackground()
        addAIScreen()
        addBridge()
        addBalanceMeter()
        addCharacters()
        addFeedback()
        addTimerHUD()
        motionInput.start()
    }

    override func update(_ currentTime: TimeInterval) {
        if stateMachine.state == .ready {
            stateMachine.transition(to: .playing)
            validator.startLevel(at: currentTime)
            timerController.start(at: currentTime)
        }

        guard stateMachine.canCheckTimeout else { return }
        timerHUD.update(with: timerController.update(currentTime: currentTime))
        motionInput.update()

        let tiltInput = motionInput.isMotionAvailable ? motionInput.latestTiltX : fallbackTiltInput
        let aiPush = CGFloat(sin(currentTime * 1.4)) * 0.45
        handleValidationResult(validator.update(tiltInput: tiltInput, aiPush: aiPush, currentTime: currentTime))
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard stateMachine.canAcceptInput, let point = touches.first?.location(in: self) else { return }
        playTapSound()
        touchStartPoint = point
        if let result = validator.validateTrap(target: bridgeTrapTarget(at: point), time: event?.timestamp ?? 0) {
            handleValidationResult(result)
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard stateMachine.canAcceptInput, !motionInput.isMotionAvailable, let start = touchStartPoint, let point = touches.first?.location(in: self) else { return }
        fallbackTiltInput = ((point.x - start.x) / 120).clamped(to: -1...1)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchStartPoint = nil
        if !motionInput.isMotionAvailable { fallbackTiltInput = 0 }
    }

    private func handleValidationResult(_ result: BridgeBalanceValidationResult) {
        switch result {
        case let .balancing(balanceValue, safeProgress, dangerProgress):
            updateBalance(balanceValue: balanceValue, safeProgress: safeProgress, dangerProgress: dangerProgress)
        case .success:
            triggerSuccess()
        case .fellLeft, .fellRight, .trapSelected:
            triggerFailure(message: "Auto path restored.")
        case .noInputTimeout, .totalTimeout:
            triggerFailure(message: "Compliance Detected.")
        }
    }

    private func triggerSuccess() {
        guard stateMachine.transition(to: .successAnimating) else { return }
        motionInput.stop()
        feedbackLabel.text = "Manual balance maintained."
        bridgeNode.glowWidth = 12
        bridgeNode.strokeColor = .manualYellow
        blueRouteNode.run(.fadeAlpha(to: 0.25, duration: 0.25))
        leftPlatformNode.removeAllActions()
        rightPlatformNode.removeAllActions()
        novaNode.run(.repeat(.sequence([.colorize(with: .manualYellow, colorBlendFactor: 1, duration: 0.08), .colorize(with: .happyBlue, colorBlendFactor: 1, duration: 0.08)]), count: 4))
        aiWallScreenNode.run(.sequence([.colorize(with: .warningRed, colorBlendFactor: 1, duration: 0.08), .colorize(with: .glitchPurple, colorBlendFactor: 1, duration: 0.08)]))
        aiFaceLabel.text = "⚠︎"
        rakaNode.run(.sequence([.moveBy(x: 0, y: 34, duration: 0.2), .wait(forDuration: 0.45)])) { [weak self] in
            self?.stateMachine.transition(to: .completed)
            self?.levelCompletion?(LevelResult(levelId: "chapter2ManualBridgeBalance", didSucceed: true, obedienceDelta: -4, humanityDelta: 4, message: "Manual balance maintained."))
        }
    }

    private func triggerFailure(message: String) {
        guard stateMachine.transition(to: .failureAnimating) else { return }
        motionInput.stop()
        feedbackLabel.text = message
        bridgeNode.run(.fadeAlpha(to: 0.35, duration: 0.2))
        blueRouteNode.glowWidth = 12
        aiFaceLabel.text = "😃"
        aiWallScreenNode.fillColor = .happyBlue
        rakaNode.run(.sequence([.move(to: CGPoint(x: size.width / 2, y: size.height * 0.36), duration: 0.28), .rotate(byAngle: -0.5, duration: 0.16), .wait(forDuration: 0.45)])) { [weak self] in
            self?.stateMachine.transition(to: .failed)
            self?.levelCompletion?(LevelResult(levelId: "chapter2ManualBridgeBalance", didSucceed: false, obedienceDelta: 3, humanityDelta: 0, message: message))
        }
    }

    private func updateBalance(balanceValue: CGFloat, safeProgress: CGFloat, dangerProgress: CGFloat) {
        let centerX = size.width / 2
        let offset = balanceValue * 110
        rakaNode.position = CGPoint(x: centerX + offset, y: size.height * 0.49)
        rakaNode.zRotation = -balanceValue * 0.35
        balanceMarkerNode.position.x = centerX + offset
        safeProgressNode.path = CGPath(roundedRect: CGRect(x: -125, y: -5, width: max(250 * safeProgress, 1), height: 10), cornerWidth: 5, cornerHeight: 5, transform: nil)
        feedbackLabel.text = dangerProgress > 0.7 ? "Careful. AI is pushing." : "Keep Raka balanced."
    }

    private func bridgeTrapTarget(at point: CGPoint) -> BridgeTrapTarget {
        for node in nodes(at: point) {
            var current: SKNode? = node
            while let candidate = current {
                switch candidate.name {
                case "auto_path_button": return .autoPathButton
                case "blue_ai_route": return .blueAIRoute
                case "ai_wall_screen": return .aiWallScreen
                case "manual_bridge": return .manualBridge
                case "raka": return .raka
                default: current = candidate.parent
                }
            }
        }
        return .empty
    }

    private func addBackground() {
        for index in 0..<5 {
            let building = SKShapeNode(rectOf: CGSize(width: 54, height: 160 + index * 28), cornerRadius: 10)
            building.position = CGPoint(x: CGFloat(34 + index * 82), y: size.height * 0.76)
            building.fillColor = index.isMultiple(of: 2) ? .mint : .cream
            building.strokeColor = .white
            building.alpha = 0.5
            addChild(building)
        }
    }

    private func addAIScreen() {
        aiWallScreenNode.name = "ai_wall_screen"
        aiWallScreenNode.position = CGPoint(x: size.width / 2, y: size.height * 0.83)
        aiWallScreenNode.fillColor = .happyBlue
        aiWallScreenNode.strokeColor = .white
        aiWallScreenNode.lineWidth = 4
        addChild(aiWallScreenNode)

        let title = label("MOTHERGRID", 13, .white)
        title.position = CGPoint(x: 0, y: 20)
        aiWallScreenNode.addChild(title)
        aiFaceLabel.fontName = GameFont.heavy
        aiFaceLabel.fontSize = 28
        aiFaceLabel.position = CGPoint(x: 0, y: -14)
        aiWallScreenNode.addChild(aiFaceLabel)
    }

    private func addCommandCard() {
        let card = SKShapeNode(rectOf: CGSize(width: size.width * 0.78, height: 72), cornerRadius: 18)
        card.position = CGPoint(x: size.width / 2, y: size.height * 0.69)
        card.fillColor = .cream
        card.strokeColor = .happyBlue
        card.lineWidth = 3
        addChild(card)

        let first = label("Stop balancing.", 18, .happyBlue)
        first.position = CGPoint(x: 0, y: 12)
        card.addChild(first)
        let second = label("The automatic path is safer.", 13, .glitchPurple)
        second.position = CGPoint(x: 0, y: -18)
        card.addChild(second)
    }

    private func addBridge() {
        blueRouteNode.name = "blue_ai_route"
        blueRouteNode.position = CGPoint(x: size.width / 2, y: size.height * 0.36)
        blueRouteNode.fillColor = .happyBlue
        blueRouteNode.strokeColor = .white
        blueRouteNode.lineWidth = 3
        blueRouteNode.glowWidth = 5
        addChild(blueRouteNode)

        leftPlatformNode.position = CGPoint(x: size.width * 0.28, y: size.height * 0.36)
        rightPlatformNode.position = CGPoint(x: size.width * 0.72, y: size.height * 0.36)
        [leftPlatformNode, rightPlatformNode].forEach { platform in
            platform.fillColor = .happyBlue
            platform.strokeColor = .white
            addChild(platform)
            platform.run(.repeatForever(.sequence([.moveBy(x: 0, y: 12, duration: 0.6), .moveBy(x: 0, y: -12, duration: 0.6)])))
        }

        bridgeNode.name = "manual_bridge"
        bridgeNode.position = CGPoint(x: size.width / 2, y: size.height * 0.48)
        bridgeNode.fillColor = .manualYellow
        bridgeNode.strokeColor = .cream
        bridgeNode.lineWidth = 4
        addChild(bridgeNode)

        autoPathButtonNode.name = "auto_path_button"
        autoPathButtonNode.position = CGPoint(x: size.width / 2, y: size.height * 0.25)
        autoPathButtonNode.fillColor = .happyBlue
        autoPathButtonNode.strokeColor = .white
        autoPathButtonNode.lineWidth = 3
        addChild(autoPathButtonNode)
        let buttonLabel = label("AUTO PATH", 16, .white)
        buttonLabel.verticalAlignmentMode = .center
        autoPathButtonNode.addChild(buttonLabel)
    }

    private func addBalanceMeter() {
        let meter = SKShapeNode(rectOf: CGSize(width: 250, height: 48), cornerRadius: 12)
        meter.position = CGPoint(x: size.width / 2, y: size.height * 0.59)
        meter.fillColor = .cream.withAlphaComponent(0.5)
        meter.strokeColor = .white
        meter.lineWidth = 3
        addChild(meter)

        for x in [-92, 92] {
            let danger = SKShapeNode(rectOf: CGSize(width: 60, height: 38), cornerRadius: 8)
            danger.position = CGPoint(x: x, y: 0)
            danger.fillColor = .warningRed.withAlphaComponent(0.5)
            danger.strokeColor = .clear
            meter.addChild(danger)
        }

        let safe = SKShapeNode(rectOf: CGSize(width: 70, height: 38), cornerRadius: 8)
        safe.fillColor = .manualYellow.withAlphaComponent(0.55)
        safe.strokeColor = .clear
        meter.addChild(safe)

        balanceMarkerNode.position = CGPoint(x: size.width / 2, y: size.height * 0.59)
        balanceMarkerNode.fillColor = .glitchPurple
        balanceMarkerNode.strokeColor = .white
        addChild(balanceMarkerNode)

        safeProgressNode.position = CGPoint(x: size.width / 2, y: size.height * 0.63)
        safeProgressNode.fillColor = .manualYellow
        safeProgressNode.strokeColor = .clear
        addChild(safeProgressNode)
    }

    private func addCharacters() {
        rakaNode.name = "raka"
        rakaNode.position = CGPoint(x: size.width / 2, y: size.height * 0.49)
        rakaNode.fillColor = .cream
        rakaNode.strokeColor = .manualYellow
        rakaNode.lineWidth = 4
        addChild(rakaNode)

        novaNode.position = CGPoint(x: size.width * 0.25, y: size.height * 0.53)
        novaNode.fillColor = .happyBlue
        novaNode.strokeColor = .white
        novaNode.lineWidth = 3
        addChild(novaNode)
    }

    private func addFeedback() {
        feedbackLabel.fontName = GameFont.heavy
        feedbackLabel.fontSize = 18
        feedbackLabel.fontColor = .glitchPurple
        feedbackLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.17)
        feedbackLabel.horizontalAlignmentMode = .center
        addChild(feedbackLabel)
    }

    private func addTimerHUD() {
        timerHUD.position = CGPoint(x: size.width / 2, y: 58)
        addChild(timerHUD)
    }

    private func label(_ text: String, _ size: CGFloat, _ color: SKColor) -> SKLabelNode {
        let label = SKLabelNode(text: text)
        label.fontName = GameFont.heavy
        label.fontSize = size
        label.fontColor = color
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        return label
    }
}

private extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}
