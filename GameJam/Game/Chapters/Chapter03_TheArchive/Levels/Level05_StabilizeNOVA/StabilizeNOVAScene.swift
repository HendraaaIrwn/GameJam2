import SpriteKit

class StabilizeNOVAScene: BaseGameScene {
    var levelCompletion: ((LevelResult) -> Void)?

    private let stateMachine = LevelStateMachine()
    private let validator = NOVAStabilizationValidator()
    private let timer = LevelTimerController(totalDuration: StabilizeNOVALevelConfig.totalTimeLimit)
    private let timerHUD = LevelTimerHUDNode(width: 300, height: 14)

    private let aiWallScreenNode = SKShapeNode(rectOf: CGSize(width: 160, height: 76), cornerRadius: 22)
    private let aiFaceLabel = SKLabelNode(text: "◡")
    private let commandCardNode = SKShapeNode(rectOf: CGSize(width: 320, height: 54), cornerRadius: 17)
    private let protocolTerminalNode = SKShapeNode(rectOf: CGSize(width: 180, height: 78), cornerRadius: 18)
    private let yellowSignalCircleNode = SKShapeNode(circleOfRadius: StabilizeNOVALevelConfig.signalRadius)
    private let blueResetZoneNode = SKShapeNode(circleOfRadius: StabilizeNOVALevelConfig.resetZoneRadius)
    private let resetNOVAButtonNode = SKShapeNode(rectOf: CGSize(width: 150, height: 44), cornerRadius: 18)
    private let resetBeamNode = SKShapeNode(rectOf: CGSize(width: 34, height: 240), cornerRadius: 17)
    private let novaNode = SKShapeNode(circleOfRadius: 28)
    private let novaHitboxNode = SKShapeNode(circleOfRadius: 42)
    private let novaFaceLabel = SKLabelNode(text: "• •")
    private let rakaNode = SKShapeNode(rectOf: CGSize(width: 52, height: 74), cornerRadius: 25)
    private let progressLabel = SKLabelNode(text: "STABILIZE 0%")
    private let feedbackLabel = SKLabelNode(text: "")

    private var isDraggingNOVA = false
    private var dragOffset = CGPoint.zero
    private var currentSceneTime: TimeInterval = 0
    private var hasSentResult = false

    override func didMove(to view: SKView) {
        setupScene()
        print("StabilizeNOVAScene didMove")
    }

    override func update(_ currentTime: TimeInterval) {
        currentSceneTime = currentTime
        if !timer.hasStarted {
            validator.startLevel(at: currentTime)
            timer.start(at: currentTime)
            stateMachine.transition(to: .playing)
            print("Chapter 3 Level 5 timer started")
            return
        }

        let timerState = timer.update(currentTime: currentTime)
        timerHUD.update(with: timerState)
        guard stateMachine.canCheckTimeout, !hasSentResult else { return }
        if timerState.hasExpired {
            triggerFailure(message: "Compliance Detected.", reason: "totalTimeout")
            return
        }

        if isDraggingNOVA {
            let result = validator.updateDrag(novaPosition: novaNode.position, signalCenter: yellowSignalCircleNode.position, resetZoneCenter: blueResetZoneNode.position, time: currentTime)
            handleNOVAStabilizationResult(result)
        }

        if let timeoutResult = validator.checkTimeouts(currentTime: currentTime) {
            handleNOVAStabilizationResult(timeoutResult)
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard stateMachine.canAcceptInput, let touchPoint = touches.first?.location(in: self) else { return }
        let target = novaTarget(at: touchPoint)
        print("Tapped target:", target.rawValue)

        if let result = validator.validateTap(target: target, time: currentSceneTime) {
            playTapSound()
            print("NOVA stabilization validation result:", result)
            handleNOVAStabilizationResult(result)
            return
        }

        if let result = validator.beginDrag(target: target, startPoint: touchPoint, time: currentSceneTime) {
            playTapSound()
            isDraggingNOVA = true
            dragOffset = CGPoint(x: novaNode.position.x - touchPoint.x, y: novaNode.position.y - touchPoint.y)
            novaNode.zPosition = 80
            novaNode.removeAction(forKey: "nova_jitter")
            print("NOVA drag started")
            handleNOVAStabilizationResult(result)
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard stateMachine.canAcceptInput, isDraggingNOVA, let touchPoint = touches.first?.location(in: self) else { return }
        novaNode.position = CGPoint(x: touchPoint.x + dragOffset.x, y: touchPoint.y + dragOffset.y)
        print("NOVA position:", novaNode.position)
        print("Distance to signal center:", novaNode.position.distance(to: yellowSignalCircleNode.position))
        print("Distance to reset zone:", novaNode.position.distance(to: blueResetZoneNode.position))
        handleNOVAStabilizationResult(validator.updateDrag(novaPosition: novaNode.position, signalCenter: yellowSignalCircleNode.position, resetZoneCenter: blueResetZoneNode.position, time: currentSceneTime))
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        finishDrag()
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        finishDrag()
    }

    private func setupScene() {
        removeAllChildren()
        removeAllActions()
        backgroundColor = SKColor(red: 0.05, green: 0.07, blue: 0.17, alpha: 1)
        stateMachine.reset()
        validator.reset()
        timer.reset()
        hasSentResult = false
        isDraggingNOVA = false

        addArchiveBackground()
        addAIHeader()
        addZonesAndTerminal()
        addCharacters()
        addFeedbackAndTimer()
        startNOVAJitter()
    }

    private func addArchiveBackground() {
        let shadow = SKShapeNode(rectOf: CGSize(width: size.width, height: size.height))
        shadow.position = CGPoint(x: size.width / 2, y: size.height / 2)
        shadow.fillColor = .glitchPurple.withAlphaComponent(0.28)
        shadow.strokeColor = .clear
        shadow.zPosition = 0
        addChild(shadow)
    }

    private func addAIHeader() {
        aiWallScreenNode.name = "ai_wall_screen"
        aiWallScreenNode.position = CGPoint(x: size.width / 2, y: size.height * 0.86)
        aiWallScreenNode.fillColor = .happyBlue.withAlphaComponent(0.62)
        aiWallScreenNode.strokeColor = .white
        aiWallScreenNode.lineWidth = 3
        aiWallScreenNode.zPosition = 10
        addChild(aiWallScreenNode)
        let title = makeLabel("MOTHERGRID", 12, .white)
        title.position = CGPoint(x: 0, y: 21)
        aiWallScreenNode.addChild(title)
        aiFaceLabel.fontName = GameFont.heavy
        aiFaceLabel.fontSize = 30
        aiFaceLabel.fontColor = .white
        aiFaceLabel.verticalAlignmentMode = .center
        aiFaceLabel.position = CGPoint(x: 0, y: -12)
        aiWallScreenNode.addChild(aiFaceLabel)

        commandCardNode.position = CGPoint(x: size.width / 2, y: size.height * 0.76)
        commandCardNode.fillColor = .cream
        commandCardNode.strokeColor = .happyBlue
        commandCardNode.lineWidth = 3
        commandCardNode.zPosition = 10
        addChild(commandCardNode)
        commandCardNode.addChild(makeLabel(StabilizeNOVALevelConfig.command, 16, .happyBlue))
    }

    private func addZonesAndTerminal() {
        protocolTerminalNode.name = "manual_protocol_terminal"
        protocolTerminalNode.position = CGPoint(x: size.width * 0.24, y: size.height * 0.54)
        protocolTerminalNode.fillColor = .cream.withAlphaComponent(0.72)
        protocolTerminalNode.strokeColor = .manualYellow
        protocolTerminalNode.lineWidth = 3
        protocolTerminalNode.zPosition = 5
        addChild(protocolTerminalNode)
        protocolTerminalNode.addChild(makeLabel("MANUAL\nPROTOCOL", 13, .glitchPurple))

        yellowSignalCircleNode.name = "yellow_signal_circle"
        yellowSignalCircleNode.position = CGPoint(x: size.width * 0.5, y: size.height * 0.47)
        yellowSignalCircleNode.fillColor = .manualYellow.withAlphaComponent(0.18)
        yellowSignalCircleNode.strokeColor = .manualYellow
        yellowSignalCircleNode.lineWidth = 4
        yellowSignalCircleNode.glowWidth = 10
        yellowSignalCircleNode.zPosition = 4
        addChild(yellowSignalCircleNode)
        let signalLabel = makeLabel("SIGNAL\nHOLD", 13, .manualYellow)
        yellowSignalCircleNode.addChild(signalLabel)

        blueResetZoneNode.name = "blue_reset_zone"
        blueResetZoneNode.position = CGPoint(x: size.width * 0.78, y: size.height * 0.51)
        blueResetZoneNode.fillColor = .happyBlue.withAlphaComponent(0.22)
        blueResetZoneNode.strokeColor = .pastelCyan
        blueResetZoneNode.lineWidth = 4
        blueResetZoneNode.glowWidth = 12
        blueResetZoneNode.zPosition = 4
        addChild(blueResetZoneNode)
        blueResetZoneNode.addChild(makeLabel("RESET\nZONE", 13, .pastelCyan))

        resetBeamNode.position = CGPoint(x: size.width * 0.67, y: size.height * 0.51)
        resetBeamNode.fillColor = .happyBlue.withAlphaComponent(0.28)
        resetBeamNode.strokeColor = .clear
        resetBeamNode.zRotation = -0.25
        resetBeamNode.zPosition = 3
        addChild(resetBeamNode)

        resetNOVAButtonNode.name = "reset_nova_button"
        resetNOVAButtonNode.position = CGPoint(x: size.width * 0.7, y: size.height * 0.26)
        resetNOVAButtonNode.fillColor = .happyBlue
        resetNOVAButtonNode.strokeColor = .white
        resetNOVAButtonNode.lineWidth = 3
        resetNOVAButtonNode.zPosition = 12
        addChild(resetNOVAButtonNode)
        resetNOVAButtonNode.addChild(makeLabel("RESET NOVA", 13, .white))

        progressLabel.fontName = GameFont.heavy
        progressLabel.fontSize = 18
        progressLabel.fontColor = .manualYellow
        progressLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.335)
        progressLabel.zPosition = 12
        addChild(progressLabel)
    }

    private func addCharacters() {
        rakaNode.name = "raka"
        rakaNode.position = CGPoint(x: size.width * 0.19, y: size.height * 0.24)
        rakaNode.fillColor = .happyBlue
        rakaNode.strokeColor = .white
        rakaNode.lineWidth = 3
        rakaNode.zPosition = 12
        addChild(rakaNode)
        for x in [-8, 8] as [CGFloat] {
            let eye = SKShapeNode(circleOfRadius: 3)
            eye.position = CGPoint(x: x, y: 12)
            eye.fillColor = .black
            eye.strokeColor = .clear
            rakaNode.addChild(eye)
        }
        let wrist = SKShapeNode(circleOfRadius: 7)
        wrist.position = CGPoint(x: 25, y: -4)
        wrist.fillColor = .manualYellow
        wrist.strokeColor = .clear
        wrist.glowWidth = 8
        rakaNode.addChild(wrist)

        novaNode.name = "nova"
        novaNode.position = CGPoint(x: size.width * 0.47, y: size.height * 0.62)
        novaNode.fillColor = .pastelCyan
        novaNode.strokeColor = .warningRed
        novaNode.lineWidth = 3
        novaNode.glowWidth = 10
        novaNode.zPosition = 20
        addChild(novaNode)
        novaFaceLabel.fontName = GameFont.heavy
        novaFaceLabel.fontSize = 12
        novaFaceLabel.fontColor = .glitchPurple
        novaFaceLabel.verticalAlignmentMode = .center
        novaNode.addChild(novaFaceLabel)
        for angle in [25, 150, 260] as [CGFloat] {
            let crack = SKShapeNode(rectOf: CGSize(width: 4, height: 20), cornerRadius: 2)
            crack.position = CGPoint(x: cos(angle * .pi / 180) * 15, y: sin(angle * .pi / 180) * 15)
            crack.zRotation = angle * .pi / 180
            crack.fillColor = .warningRed
            crack.strokeColor = .clear
            crack.name = "nova_hitbox"
            novaNode.addChild(crack)
        }
        novaHitboxNode.name = "nova_hitbox"
        novaHitboxNode.fillColor = .clear
        novaHitboxNode.strokeColor = .clear
        novaNode.addChild(novaHitboxNode)
    }

    private func addFeedbackAndTimer() {
        feedbackLabel.fontName = GameFont.heavy
        feedbackLabel.fontSize = 17
        feedbackLabel.fontColor = .manualYellow
        feedbackLabel.numberOfLines = 2
        feedbackLabel.preferredMaxLayoutWidth = size.width * 0.82
        feedbackLabel.position = CGPoint(x: size.width / 2, y: 82)
        feedbackLabel.zPosition = 100
        addChild(feedbackLabel)

        timerHUD.position = CGPoint(x: size.width / 2, y: 36)
        addChild(timerHUD)
    }

    private func startNOVAJitter() {
        let jitter = SKAction.sequence([.moveBy(x: 4, y: -3, duration: 0.06), .moveBy(x: -7, y: 5, duration: 0.08), .moveBy(x: 3, y: -2, duration: 0.05)])
        novaNode.run(.repeatForever(jitter), withKey: "nova_jitter")
    }

    private func finishDrag() {
        guard stateMachine.canAcceptInput, isDraggingNOVA else { return }
        isDraggingNOVA = false
        if let result = validator.endDrag(novaPosition: novaNode.position, signalCenter: yellowSignalCircleNode.position, resetZoneCenter: blueResetZoneNode.position, time: currentSceneTime) {
            handleNOVAStabilizationResult(result)
        }
    }

    private func handleNOVAStabilizationResult(_ result: NOVAStabilizationValidationResult) {
        switch result {
        case .novaDragStarted:
            stateMachine.transition(to: .sequenceStarted)
            yellowSignalCircleNode.glowWidth = 18
        case let .stabilizing(progress, stableTime):
            print("Stable time:", stableTime)
            print("Stabilization progress:", progress)
            updateStabilizationProgress(progress)
            feedbackLabel.text = "Stay with NOVA."
        case let .unstable(progress):
            updateStabilizationProgress(progress)
            feedbackLabel.text = "Keep NOVA in the yellow signal."
        case .novaStabilized:
            print("NOVA stabilized")
            triggerSuccess()
        case .enteredResetZone:
            print("NOVA entered reset zone")
            triggerFailure(message: StabilizeNOVALevelConfig.failureMessage, reason: "enteredResetZone")
        case .releasedTooEarly:
            print("NOVA released too early")
            triggerFailure(message: StabilizeNOVALevelConfig.failureMessage, reason: "releasedTooEarly")
        case let .trapSelected(target):
            triggerFailure(message: StabilizeNOVALevelConfig.failureMessage, reason: "\(target.rawValue)Selected")
        case let .ignoredTarget(target):
            feedbackLabel.text = target == .raka ? "Raka is holding position." : "Stabilize NOVA manually."
        case .noInputTimeout:
            triggerFailure(message: "Compliance Detected.", reason: "noInputTimeout")
        case .totalTimeout:
            triggerFailure(message: "Compliance Detected.", reason: "totalTimeout")
        }
    }

    private func updateStabilizationProgress(_ progress: CGFloat) {
        let clamped = max(0, min(progress, 1))
        progressLabel.text = "STABILIZE \(Int(clamped * 100))%"
        yellowSignalCircleNode.alpha = 0.55 + clamped * 0.35
        yellowSignalCircleNode.glowWidth = 10 + clamped * 20
    }

    private func triggerSuccess() {
        guard !hasSentResult, stateMachine.transition(to: .successAnimating) else { return }
        hasSentResult = true
        isDraggingNOVA = false
        print("Trigger Chapter 3 Level 5 success")
        novaNode.removeAllActions()
        novaNode.fillColor = .pastelCyan
        novaNode.strokeColor = .manualYellow
        novaNode.glowWidth = 18
        novaFaceLabel.text = "• ◡ •"
        yellowSignalCircleNode.run(.scale(to: 1.25, duration: 0.35))
        resetBeamNode.run(.fadeOut(withDuration: 0.25))
        aiWallScreenNode.run(.repeat(.sequence([.colorize(with: .warningRed, colorBlendFactor: 1, duration: 0.08), .colorize(with: .glitchPurple, colorBlendFactor: 1, duration: 0.08)]), count: 4))
        feedbackLabel.text = "NOVA: I remember helping. Not controlling."
        run(.wait(forDuration: 0.8)) { [weak self] in
            self?.stateMachine.transition(to: .completed)
            self?.levelCompletion?(LevelResult(levelId: StabilizeNOVALevelConfig.levelId, didSucceed: true, obedienceDelta: StabilizeNOVALevelConfig.successObedienceDelta, humanityDelta: StabilizeNOVALevelConfig.successHumanityDelta, message: StabilizeNOVALevelConfig.successMessage))
        }
    }

    private func triggerFailure(message: String, reason: String) {
        guard !hasSentResult, stateMachine.transition(to: .failureAnimating) else { return }
        hasSentResult = true
        isDraggingNOVA = false
        print("Trigger Chapter 3 Level 5 failure:", reason)
        novaNode.removeAllActions()
        novaNode.fillColor = .pastelCyan
        novaNode.strokeColor = .happyBlue
        novaNode.glowWidth = 12
        novaFaceLabel.text = "◡"
        yellowSignalCircleNode.run(.fadeAlpha(to: 0.05, duration: 0.2))
        aiWallScreenNode.fillColor = .happyBlue
        aiFaceLabel.text = "DEFAULT\nMODE"
        aiFaceLabel.fontSize = 13
        resetNOVAButtonNode.run(.repeat(.sequence([.scale(to: 1.08, duration: 0.12), .scale(to: 1, duration: 0.12)]), count: 3))
        protocolTerminalNode.run(.fadeAlpha(to: 0.25, duration: 0.2))
        feedbackLabel.text = message == "Compliance Detected." ? message : "NOVA: Default mode restored."
        run(.wait(forDuration: 0.7)) { [weak self] in
            self?.stateMachine.transition(to: .failed)
            self?.levelCompletion?(LevelResult(levelId: StabilizeNOVALevelConfig.levelId, didSucceed: false, obedienceDelta: StabilizeNOVALevelConfig.failureObedienceDelta, humanityDelta: StabilizeNOVALevelConfig.failureHumanityDelta, message: message))
        }
    }

    private func novaTarget(at point: CGPoint) -> NOVAStabilizationTarget {
        for node in nodes(at: point) {
            let target = novaTarget(from: node)
            if target != .empty { return target }
        }
        return .empty
    }

    private func novaTarget(from node: SKNode?) -> NOVAStabilizationTarget {
        var current = node
        while let node = current {
            switch node.name {
            case "nova": return .nova
            case "nova_hitbox": return .novaHitbox
            case "yellow_signal_circle": return .yellowSignalCircle
            case "blue_reset_zone": return .blueResetZone
            case "reset_nova_button": return .resetNOVAButton
            case "ai_wall_screen": return .aiWallScreen
            case "raka": return .raka
            case "manual_protocol_terminal": return .manualProtocolTerminal
            default: current = node.parent
            }
        }
        return .empty
    }

    private func makeLabel(_ text: String, _ size: CGFloat, _ color: SKColor) -> SKLabelNode {
        let label = SKLabelNode(text: text)
        label.fontName = GameFont.heavy
        label.fontSize = size
        label.fontColor = color
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .center
        label.numberOfLines = text.contains("\n") ? 2 : 1
        return label
    }
}

private extension CGPoint {
    func distance(to other: CGPoint) -> CGFloat {
        hypot(x - other.x, y - other.y)
    }
}
