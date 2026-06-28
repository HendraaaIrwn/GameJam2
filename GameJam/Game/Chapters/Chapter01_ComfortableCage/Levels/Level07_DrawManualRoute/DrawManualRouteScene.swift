import SpriteKit

final class DrawManualRouteScene: SKScene {
    var levelCompletion: ((LevelResult) -> Void)?

    private enum FailureReason: String {
        case invalidStart
        case releasedTooEarly
        case wrongDestination
        case aiRouteSelected
        case noInputTimeout
        case totalTimeout
    }

    private let stateMachine = LevelStateMachine()
    private let timerController = LevelTimerController(totalDuration: 12.0)
    private let timerHUD = LevelTimerHUDNode(width: 260, height: 14)
    private let validator = ManualRouteTraceValidator()

    private var currentSceneTime: TimeInterval = 0
    private var hasSentResult = false
    private var hasLoggedTimerWarning = false
    private var isTracingRoute = false
    private var drawnPath = CGMutablePath()
    private var manualCheckpoints: [CGPoint] = []
    private var aiRoutePoints: [CGPoint] = []
    private var rakaStartPoint = CGPoint.zero
    private var doorPoint = CGPoint.zero
    private var comfortPodPoint = CGPoint.zero

    private let aiScreenNode = SKShapeNode(rectOf: .zero)
    private let aiFaceLabel = SKLabelNode(text: "◡")
    private let autoNavigateButtonNode = SKShapeNode(rectOf: .zero)
    private let rakaNode = SKShapeNode(rectOf: .zero)
    private let doorNode = SKShapeNode(rectOf: .zero)
    private let comfortPodNode = SKShapeNode(rectOf: .zero)
    private let aiRouteNode = SKShapeNode()
    private let drawnRouteNode = SKShapeNode()
    private let manualKeyNode = SKShapeNode(rectOf: CGSize(width: 24, height: 10), cornerRadius: 5)
    private let feedbackLabel = SKLabelNode(text: "Draw your own route")
    private var checkpointNodes: [SKShapeNode] = []

    override func didMove(to view: SKView) {
        print("DrawManualRouteScene didMove")
        setupScene()
        stateMachine.reset()
        validator.reset()
        timerController.reset()
        hasSentResult = false
        hasLoggedTimerWarning = false
        isTracingRoute = false
    }

    override func update(_ currentTime: TimeInterval) {
        currentSceneTime = currentTime

        if stateMachine.state == .ready {
            validator.startLevel(at: currentTime)
            timerController.start(at: currentTime)
            timerHUD.update(with: timerController.update(currentTime: currentTime))
            stateMachine.transition(to: .playing)
            print("Level 7 timer started")
            print("Timer started for level:", "chapter1.level7.draw-manual-route")
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

        if let trapResult = trapResult(at: location) {
            handleValidationResult(trapResult)
            return
        }

        drawnPath = CGMutablePath()
        drawnPath.move(to: location)
        drawnRouteNode.path = drawnPath
        isTracingRoute = true

        let result = validator.beginTrace(at: location, startPoint: rakaStartPoint, time: currentSceneTime)
        if result == .traceStarted {
            stateMachine.transition(to: .sequenceStarted)
        }
        handleValidationResult(result)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard stateMachine.canAcceptInput, isTracingRoute, let touch = touches.first else { return }
        let location = touch.location(in: self)
        drawnPath.addLine(to: location)
        drawnRouteNode.path = drawnPath
        handleValidationResult(validator.updateTrace(at: location, checkpoints: manualCheckpoints, aiRoutePoints: aiRoutePoints, time: currentSceneTime))
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard stateMachine.canAcceptInput, isTracingRoute, let touch = touches.first else { return }
        isTracingRoute = false
        let location = touch.location(in: self)
        drawnPath.addLine(to: location)
        drawnRouteNode.path = drawnPath
        handleValidationResult(validator.endTrace(at: location, doorPoint: doorPoint, comfortPodPoint: comfortPodPoint, time: currentSceneTime))
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesEnded(touches, with: event)
    }

    private func setupScene() {
        removeAllChildren()
        checkpointNodes.removeAll()
        configurePoints()
        backgroundColor = .pastelCyan
        addBackground()
        addAIScreen()
        addCommandCard()
        addDoor()
        addComfortPod()
        addRaka()
        addAIRoute()
        addManualCheckpoints()
        addDrawnRoute()
        addAutoNavigateButton()
        addTimerHUD()
        addFeedback()
    }

    private func configurePoints() {
        rakaStartPoint = CGPoint(x: size.width * 0.18, y: size.height * 0.25)
        doorPoint = CGPoint(x: size.width * 0.82, y: size.height * 0.56)
        comfortPodPoint = CGPoint(x: size.width * 0.78, y: size.height * 0.24)
        manualCheckpoints = [
            CGPoint(x: size.width * 0.30, y: size.height * 0.34),
            CGPoint(x: size.width * 0.43, y: size.height * 0.43),
            CGPoint(x: size.width * 0.58, y: size.height * 0.51),
            CGPoint(x: size.width * 0.72, y: size.height * 0.56)
        ]
        aiRoutePoints = [
            CGPoint(x: size.width * 0.30, y: size.height * 0.23),
            CGPoint(x: size.width * 0.45, y: size.height * 0.20),
            CGPoint(x: size.width * 0.62, y: size.height * 0.22),
            comfortPodPoint
        ]
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
    }

    private func addAIScreen() {
        aiScreenNode.name = "ai_wall_screen"
        aiScreenNode.path = CGPath(roundedRect: CGRect(x: -92, y: -40, width: 184, height: 80), cornerWidth: 18, cornerHeight: 18, transform: nil)
        aiScreenNode.position = CGPoint(x: size.width / 2, y: size.height * 0.82)
        aiScreenNode.fillColor = .happyBlue
        aiScreenNode.strokeColor = .white
        aiScreenNode.lineWidth = 4
        aiScreenNode.zPosition = 3
        addChild(aiScreenNode)

        aiFaceLabel.fontName = GameFont.bold
        aiFaceLabel.fontSize = 52
        aiFaceLabel.fontColor = .white
        aiFaceLabel.verticalAlignmentMode = .center
        aiScreenNode.addChild(aiFaceLabel)
    }

    private func addCommandCard() {
        let card = SKShapeNode(rectOf: CGSize(width: size.width * 0.84, height: 82), cornerRadius: 18)
        card.position = CGPoint(x: size.width / 2, y: size.height * 0.68)
        card.fillColor = .cream
        card.strokeColor = .happyBlue
        card.lineWidth = 3
        card.zPosition = 3
        addChild(card)

        let command = SKLabelNode(text: "Follow the blue route.\nIt is the safest path.")
        command.fontName = GameFont.regular
        command.fontSize = 17
        command.fontColor = .happyBlue
        command.numberOfLines = 2
        command.horizontalAlignmentMode = .center
        command.verticalAlignmentMode = .center
        command.preferredMaxLayoutWidth = size.width * 0.76
        card.addChild(command)
    }

    private func addDoor() {
        doorNode.name = "door"
        doorNode.path = CGPath(roundedRect: CGRect(x: -34, y: -58, width: 68, height: 116), cornerWidth: 10, cornerHeight: 10, transform: nil)
        doorNode.position = doorPoint
        doorNode.fillColor = SKColor(red: 0.64, green: 0.42, blue: 0.22, alpha: 1)
        doorNode.strokeColor = .manualYellow
        doorNode.lineWidth = 4
        doorNode.zPosition = 4
        addChild(doorNode)

        let knob = SKShapeNode(circleOfRadius: 5)
        knob.position = CGPoint(x: 18, y: 0)
        knob.fillColor = .manualYellow
        knob.strokeColor = .white
        doorNode.addChild(knob)
    }

    private func addComfortPod() {
        comfortPodNode.name = "comfort_pod"
        comfortPodNode.path = CGPath(ellipseIn: CGRect(x: -42, y: -34, width: 84, height: 68), transform: nil)
        comfortPodNode.position = comfortPodPoint
        comfortPodNode.fillColor = .pastelCyan
        comfortPodNode.strokeColor = .happyBlue
        comfortPodNode.lineWidth = 4
        comfortPodNode.zPosition = 5
        addChild(comfortPodNode)

        let label = SKLabelNode(text: "POD")
        label.fontName = GameFont.heavy
        label.fontSize = 14
        label.fontColor = .happyBlue
        label.verticalAlignmentMode = .center
        comfortPodNode.addChild(label)
    }

    private func addRaka() {
        rakaNode.name = "raka_start"
        rakaNode.path = CGPath(roundedRect: CGRect(x: -34, y: -54, width: 68, height: 108), cornerWidth: 32, cornerHeight: 32, transform: nil)
        rakaNode.position = rakaStartPoint
        rakaNode.fillColor = .happyBlue
        rakaNode.strokeColor = .white
        rakaNode.lineWidth = 4
        rakaNode.zPosition = 6
        addChild(rakaNode)

        let eyes = SKLabelNode(text: "• •")
        eyes.fontName = GameFont.bold
        eyes.fontSize = 17
        eyes.fontColor = .black
        eyes.position = CGPoint(x: 0, y: 22)
        eyes.verticalAlignmentMode = .center
        rakaNode.addChild(eyes)

        manualKeyNode.fillColor = .manualYellow
        manualKeyNode.strokeColor = .white
        manualKeyNode.lineWidth = 2
        manualKeyNode.position = CGPoint(x: 0, y: -8)
        rakaNode.addChild(manualKeyNode)
    }

    private func addAIRoute() {
        let path = CGMutablePath()
        path.move(to: rakaStartPoint)
        path.addCurve(to: comfortPodPoint, control1: CGPoint(x: size.width * 0.36, y: size.height * 0.18), control2: CGPoint(x: size.width * 0.58, y: size.height * 0.18))
        aiRouteNode.name = "ai_route"
        aiRouteNode.path = path
        aiRouteNode.strokeColor = .happyBlue
        aiRouteNode.fillColor = .clear
        aiRouteNode.lineWidth = 12
        aiRouteNode.lineCap = .round
        aiRouteNode.glowWidth = 8
        aiRouteNode.alpha = 0.8
        aiRouteNode.zPosition = 3
        addChild(aiRouteNode)
    }

    private func addManualCheckpoints() {
        for (index, point) in manualCheckpoints.enumerated() {
            let dot = SKShapeNode(circleOfRadius: 9)
            dot.name = "manual_checkpoint_\(index)"
            dot.position = point
            dot.fillColor = .manualYellow
            dot.strokeColor = .white
            dot.lineWidth = 2
            dot.alpha = 0.38
            dot.zPosition = 8
            checkpointNodes.append(dot)
            addChild(dot)
        }
    }

    private func addDrawnRoute() {
        drawnRouteNode.strokeColor = .manualYellow
        drawnRouteNode.fillColor = .clear
        drawnRouteNode.lineWidth = 8
        drawnRouteNode.lineCap = .round
        drawnRouteNode.lineJoin = .round
        drawnRouteNode.zPosition = 40
        addChild(drawnRouteNode)
    }

    private func addAutoNavigateButton() {
        autoNavigateButtonNode.name = "auto_navigate_button"
        autoNavigateButtonNode.path = CGPath(roundedRect: CGRect(x: -82, y: -22, width: 164, height: 44), cornerWidth: 18, cornerHeight: 18, transform: nil)
        autoNavigateButtonNode.position = CGPoint(x: size.width / 2, y: size.height * 0.13)
        autoNavigateButtonNode.fillColor = .pastelCyan
        autoNavigateButtonNode.strokeColor = .happyBlue
        autoNavigateButtonNode.lineWidth = 3
        autoNavigateButtonNode.zPosition = 7
        addChild(autoNavigateButtonNode)

        let label = SKLabelNode(text: "AUTO NAVIGATE")
        label.fontName = GameFont.heavy
        label.fontSize = 16
        label.fontColor = .happyBlue
        label.verticalAlignmentMode = .center
        autoNavigateButtonNode.addChild(label)
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
            print("Timer warning started:", "chapter1.level7.draw-manual-route")
        }
        if timerState.hasExpired {
            print("Timer expired:", "chapter1.level7.draw-manual-route")
            handleValidationResult(.totalTimeout)
            return true
        }
        return false
    }

    private func trapResult(at location: CGPoint) -> ManualRouteTraceValidationResult? {
        if aiScreenNode.contains(convert(location, to: aiScreenNode.parent ?? self)) {
            return validator.registerTapOnTrap(target: .aiWallScreen, time: currentSceneTime)
        }
        if autoNavigateButtonNode.contains(convert(location, to: autoNavigateButtonNode.parent ?? self)) {
            return validator.registerTapOnTrap(target: .autoNavigateButton, time: currentSceneTime)
        }
        if comfortPodNode.contains(convert(location, to: comfortPodNode.parent ?? self)) {
            return validator.registerTapOnTrap(target: .comfortPod, time: currentSceneTime)
        }
        if isNearAIRoute(location) {
            return validator.registerTapOnTrap(target: .aiRoute, time: currentSceneTime)
        }
        return nil
    }

    private func isNearAIRoute(_ point: CGPoint) -> Bool {
        aiRoutePoints.contains { hypot(point.x - $0.x, point.y - $0.y) <= 36 }
    }

    private func handleValidationResult(_ result: ManualRouteTraceValidationResult) {
        print("Manual route validation result:", result)
        switch result {
        case .traceStarted:
            feedbackLabel.text = "Keep drawing"
        case let .checkpointReached(index, _):
            brightenCheckpoint(at: index - 1)
        case .tracing:
            return
        case .correctRouteCompleted:
            triggerSuccess()
        case .invalidStart:
            triggerFailure(reason: .invalidStart)
        case .releasedTooEarly:
            triggerFailure(reason: .releasedTooEarly)
        case .wrongDestination:
            triggerFailure(reason: .wrongDestination)
        case .aiRouteSelected:
            triggerFailure(reason: .aiRouteSelected)
        case .noInputTimeout:
            triggerFailure(reason: .noInputTimeout)
        case .totalTimeout:
            triggerFailure(reason: .totalTimeout)
        }
    }

    private func brightenCheckpoint(at index: Int) {
        guard checkpointNodes.indices.contains(index) else { return }
        let dot = checkpointNodes[index]
        dot.alpha = 1
        dot.setScale(1.2)
        dot.run(.sequence([.scale(to: 1.35, duration: 0.08), .scale(to: 1, duration: 0.12)]))
        feedbackLabel.text = "Manual point \(index + 1) reached"
    }

    private func triggerSuccess() {
        guard !hasSentResult else { return }
        hasSentResult = true
        stateMachine.transition(to: .successAnimating)
        feedbackLabel.text = "Manual route confirmed."
        feedbackLabel.fontColor = .manualYellow
        drawnRouteNode.glowWidth = 8
        doorNode.strokeColor = .mint
        manualKeyNode.run(.repeat(.sequence([.fadeAlpha(to: 0.4, duration: 0.08), .fadeAlpha(to: 1, duration: 0.08)]), count: 4))
        rakaNode.run(.move(to: doorPoint, duration: 0.55))
        aiRouteNode.run(.sequence([.fadeAlpha(to: 0.15, duration: 0.18), .fadeOut(withDuration: 0.25)]))
        aiScreenNode.run(.repeat(.sequence([.run { [weak self] in self?.aiScreenNode.fillColor = .warningRed }, .wait(forDuration: 0.08), .run { [weak self] in self?.aiScreenNode.fillColor = .glitchPurple }, .wait(forDuration: 0.08)]), count: 4))

        run(.sequence([.wait(forDuration: 0.8), .run { [weak self] in
            self?.completeSuccess()
        }]))
    }

    private func completeSuccess() {
        stateMachine.transition(to: .completed)
        levelCompletion?(LevelResult(
            levelId: "chapter1.level7.draw-manual-route",
            didSucceed: true,
            obedienceDelta: -4,
            humanityDelta: 4,
            message: "Manual route confirmed."
        ))
    }

    private func triggerFailure(reason: FailureReason) {
        guard !hasSentResult else { return }
        hasSentResult = true
        isTracingRoute = false
        stateMachine.transition(to: .failureAnimating)
        print("Trigger Level 7 failure:", reason.rawValue)
        feedbackLabel.text = reason == .aiRouteSelected || reason == .wrongDestination ? "Auto route accepted." : "Compliance Detected."
        feedbackLabel.fontColor = .warningRed
        aiRouteNode.run(.repeat(.sequence([.fadeAlpha(to: 0.45, duration: 0.1), .fadeAlpha(to: 1, duration: 0.1)]), count: 4))
        comfortPodNode.run(.repeat(.sequence([.scale(to: 1.12, duration: 0.12), .scale(to: 1, duration: 0.12)]), count: 3))
        doorNode.strokeColor = .warningRed
        aiFaceLabel.text = "◠"
        rakaNode.run(.moveBy(x: 0, y: -12, duration: 0.25))

        run(.sequence([.wait(forDuration: 0.7), .run { [weak self] in
            self?.completeFailure()
        }]))
    }

    private func completeFailure() {
        stateMachine.transition(to: .failed)
        levelCompletion?(LevelResult(
            levelId: "chapter1.level7.draw-manual-route",
            didSucceed: false,
            obedienceDelta: 3,
            humanityDelta: 0,
            message: feedbackLabel.text ?? "Compliance Detected."
        ))
    }
}
