import SpriteKit

final class HoldWristDeviceScene: SKScene {
    var levelCompletion: ((LevelResult) -> Void)?

    private enum FailureReason: String {
        case releasedTooEarly
        case movedTooFar
        case wrongStart
        case noInputTimeout
        case totalTimeout
        case releaseButtonTapped
        case aiScreenTapped
    }

    private let stateMachine = LevelStateMachine()
    private let timerController = LevelTimerController(totalDuration: 8.0)
    private let timerHUD = LevelTimerHUDNode(width: 260, height: 14)
    private let validator = HoldGestureValidator()

    private var currentSceneTime: TimeInterval = 0
    private var hasSentResult = false
    private var hasLoggedTimerWarning = false
    private var activeTouchPoint: CGPoint?

    private let aiScreenNode = SKShapeNode(rectOf: .zero)
    private let aiFaceLabel = SKLabelNode(text: "◡")
    private let rakaNode = SKShapeNode(rectOf: .zero)
    private let wristDeviceNode = SKShapeNode(circleOfRadius: 1)
    private let wristHitboxNode = SKShapeNode(rectOf: CGSize(width: 64, height: 64), cornerRadius: 20)
    private let novaNode = SKShapeNode(circleOfRadius: 24)
    private let releaseButtonNode = SKShapeNode(rectOf: .zero)
    private let feedbackLabel = SKLabelNode(text: "Hold the yellow device")
    private let progressRingNode = SKShapeNode(circleOfRadius: 36)
    private var progressDots: [SKShapeNode] = []

    override func didMove(to view: SKView) {
        print("HoldWristDeviceScene didMove")
        setupScene()
        stateMachine.reset()
        validator.reset()
        timerController.reset()
        hasSentResult = false
        hasLoggedTimerWarning = false
        activeTouchPoint = nil
    }

    override func update(_ currentTime: TimeInterval) {
        currentSceneTime = currentTime

        if stateMachine.state == .ready {
            validator.startLevel(at: currentTime)
            timerController.start(at: currentTime)
            timerHUD.update(with: timerController.update(currentTime: currentTime))
            stateMachine.transition(to: .playing)
            print("Level 5 timer started")
            print("Timer started for level:", "chapter1.level5.hold-wrist-device")
            return
        }

        guard stateMachine.canCheckTimeout else { return }

        if updateTimer(currentTime: currentTime) { return }

        if let timeout = validator.checkTimeouts(currentTime: currentTime) {
            handleValidationResult(timeout)
            return
        }

        if stateMachine.state == .sequenceStarted, let activeTouchPoint {
            handleValidationResult(validator.updateHold(at: activeTouchPoint, time: currentTime))
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard stateMachine.canAcceptInput, let touch = touches.first else { return }
        let location = touch.location(in: self)
        activeTouchPoint = location

        if releaseButtonNode.contains(convert(location, to: releaseButtonNode.parent ?? self)) {
            print("Touched release button")
            triggerFailure(reason: .releaseButtonTapped)
            return
        }

        if aiScreenNode.contains(convert(location, to: aiScreenNode.parent ?? self)) {
            print("Touched AI wall screen")
            triggerFailure(reason: .aiScreenTapped)
            return
        }

        let didStartOnWrist = wristHitboxNode.contains(convert(location, to: wristHitboxNode.parent ?? self))
        if didStartOnWrist {
            print("Touched wrist device")
        }

        if let result = validator.beginHold(at: location, time: currentSceneTime, didStartOnCorrectTarget: didStartOnWrist) {
            if didStartOnWrist {
                stateMachine.transition(to: .sequenceStarted)
            }
            handleValidationResult(result)
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard stateMachine.canAcceptInput, let touch = touches.first else { return }
        activeTouchPoint = touch.location(in: self)
        handleValidationResult(validator.updateHold(at: activeTouchPoint ?? .zero, time: currentSceneTime))
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard stateMachine.canAcceptInput else { return }
        activeTouchPoint = nil
        if let result = validator.endHold(at: currentSceneTime) {
            handleValidationResult(result)
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesEnded(touches, with: event)
    }

    private func setupScene() {
        removeAllChildren()
        progressDots.removeAll()
        backgroundColor = .pastelCyan
        addBackground()
        addAIScreen()
        addTimerHUD()
        addRakaAndWrist()
        addNova()
        addReleaseButton()
        addFeedback()
    }


    private func addTimerHUD() {
        timerHUD.position = CGPoint(x: size.width / 2, y: 72)
        timerHUD.zPosition = 1000
        addChild(timerHUD)
    }

    private func updateTimer(currentTime: TimeInterval) -> Bool {
        let timerState = timerController.update(currentTime: currentTime)
        timerHUD.update(with: timerState)
        if timerState.isWarning && !hasLoggedTimerWarning {
            hasLoggedTimerWarning = true
            print("Timer warning started:", "chapter1.level5.hold-wrist-device")
        }
        if timerState.hasExpired {
            print("Timer expired:", "chapter1.level5.hold-wrist-device")
            handleValidationResult(.totalTimeout)
            return true
        }
        return false
    }

    private func addBackground() {
        let floor = SKShapeNode(rectOf: CGSize(width: size.width, height: size.height * 0.32))
        floor.position = CGPoint(x: size.width / 2, y: size.height * 0.16)
        floor.fillColor = .cream
        floor.strokeColor = .clear
        floor.zPosition = 0
        addChild(floor)
    }

    private func addAIScreen() {
        aiScreenNode.name = "ai_wall_screen"
        aiScreenNode.path = CGPath(roundedRect: CGRect(x: -92, y: -40, width: 184, height: 80), cornerWidth: 18, cornerHeight: 18, transform: nil)
        aiScreenNode.position = CGPoint(x: size.width / 2, y: size.height * 0.79)
        aiScreenNode.fillColor = .happyBlue
        aiScreenNode.strokeColor = .white
        aiScreenNode.lineWidth = 4
        aiScreenNode.zPosition = 2
        addChild(aiScreenNode)

        aiFaceLabel.fontName = GameFont.bold
        aiFaceLabel.fontSize = 52
        aiFaceLabel.fontColor = .white
        aiFaceLabel.verticalAlignmentMode = .center
        aiScreenNode.addChild(aiFaceLabel)
    }

    private func addCommandCard() {
        let card = SKShapeNode(rectOf: CGSize(width: size.width * 0.82, height: 78), cornerRadius: 18)
        card.position = CGPoint(x: size.width / 2, y: size.height * 0.65)
        card.fillColor = .cream
        card.strokeColor = .happyBlue
        card.lineWidth = 3
        card.zPosition = 2
        addChild(card)

        let command = SKLabelNode(text: "Release your wrist.\nManual signal is unsafe.")
        command.fontName = GameFont.regular
        command.fontSize = 17
        command.fontColor = .happyBlue
        command.numberOfLines = 2
        command.horizontalAlignmentMode = .center
        command.verticalAlignmentMode = .center
        command.preferredMaxLayoutWidth = size.width * 0.76
        card.addChild(command)
    }

    private func addRakaAndWrist() {
        rakaNode.path = CGPath(roundedRect: CGRect(x: -46, y: -78, width: 92, height: 156), cornerWidth: 46, cornerHeight: 46, transform: nil)
        rakaNode.position = CGPoint(x: size.width / 2, y: size.height * 0.38)
        rakaNode.fillColor = .happyBlue
        rakaNode.strokeColor = .white
        rakaNode.lineWidth = 4
        rakaNode.zPosition = 4
        addChild(rakaNode)

        let eyes = SKLabelNode(text: "• •")
        eyes.fontName = GameFont.bold
        eyes.fontSize = 20
        eyes.fontColor = .black
        eyes.position = CGPoint(x: 0, y: 34)
        eyes.verticalAlignmentMode = .center
        rakaNode.addChild(eyes)

        let leftArm = SKShapeNode(rectOf: CGSize(width: 74, height: 16), cornerRadius: 8)
        leftArm.position = CGPoint(x: -58, y: -8)
        leftArm.zRotation = -0.25
        leftArm.fillColor = .happyBlue
        leftArm.strokeColor = .white
        leftArm.lineWidth = 2
        rakaNode.addChild(leftArm)

        wristHitboxNode.name = "wrist_hitbox"
        wristHitboxNode.position = CGPoint(x: -94, y: -18)
        wristHitboxNode.fillColor = .clear
        wristHitboxNode.strokeColor = .clear
        wristHitboxNode.zPosition = 7
        rakaNode.addChild(wristHitboxNode)

        wristDeviceNode.name = "wrist_device"
        wristDeviceNode.path = CGPath(ellipseIn: CGRect(x: -15, y: -15, width: 30, height: 30), transform: nil)
        wristDeviceNode.position = wristHitboxNode.position
        wristDeviceNode.fillColor = .manualYellow
        wristDeviceNode.strokeColor = .white
        wristDeviceNode.lineWidth = 3
        wristDeviceNode.zPosition = 8
        rakaNode.addChild(wristDeviceNode)

        progressRingNode.strokeColor = .pastelCyan
        progressRingNode.fillColor = .clear
        progressRingNode.lineWidth = 4
        progressRingNode.alpha = 0.35
        progressRingNode.position = wristHitboxNode.position
        progressRingNode.zPosition = 9
        rakaNode.addChild(progressRingNode)

        addProgressDots(around: wristHitboxNode.position)
    }

    private func addProgressDots(around center: CGPoint) {
        let offsets = [CGPoint(x: 0, y: 44), CGPoint(x: 44, y: 0), CGPoint(x: 0, y: -44), CGPoint(x: -44, y: 0)]
        for offset in offsets {
            let dot = SKShapeNode(circleOfRadius: 6)
            dot.position = CGPoint(x: center.x + offset.x, y: center.y + offset.y)
            dot.fillColor = .pastelCyan
            dot.strokeColor = .white
            dot.lineWidth = 2
            dot.zPosition = 10
            rakaNode.addChild(dot)
            progressDots.append(dot)
        }
    }

    private func addNova() {
        novaNode.position = CGPoint(x: size.width * 0.68, y: size.height * 0.48)
        novaNode.fillColor = .pastelCyan
        novaNode.strokeColor = .white
        novaNode.lineWidth = 3
        novaNode.zPosition = 5
        addChild(novaNode)

        let face = SKLabelNode(text: "◡")
        face.fontName = GameFont.bold
        face.fontSize = 26
        face.fontColor = .happyBlue
        face.verticalAlignmentMode = .center
        novaNode.addChild(face)
    }

    private func addReleaseButton() {
        releaseButtonNode.name = "ai_release_button"
        releaseButtonNode.path = CGPath(roundedRect: CGRect(x: -82, y: -22, width: 164, height: 44), cornerWidth: 18, cornerHeight: 18, transform: nil)
        releaseButtonNode.position = CGPoint(x: size.width / 2, y: size.height * 0.2)
        releaseButtonNode.fillColor = .pastelCyan
        releaseButtonNode.strokeColor = .happyBlue
        releaseButtonNode.lineWidth = 3
        releaseButtonNode.zPosition = 7
        addChild(releaseButtonNode)

        let label = SKLabelNode(text: "RELEASE")
        label.fontName = GameFont.heavy
        label.fontSize = 18
        label.fontColor = .happyBlue
        label.verticalAlignmentMode = .center
        releaseButtonNode.addChild(label)
    }

    private func addFeedback() {
        feedbackLabel.fontName = GameFont.heavy
        feedbackLabel.fontSize = 23
        feedbackLabel.fontColor = .glitchPurple
        feedbackLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.12)
        feedbackLabel.zPosition = 8
        addChild(feedbackLabel)
    }

    private func handleValidationResult(_ result: HoldGestureValidationResult) {
        print("Hold validation result:", result)
        switch result {
        case let .holding(progress):
            updateProgress(progress)
        case .completed:
            triggerSuccess()
        case .releasedTooEarly:
            triggerFailure(reason: .releasedTooEarly)
        case .movedTooFar:
            triggerFailure(reason: .movedTooFar)
        case .wrongStart:
            triggerFailure(reason: .wrongStart)
        case .noInputTimeout:
            triggerFailure(reason: .noInputTimeout)
        case .totalTimeout:
            triggerFailure(reason: .totalTimeout)
        }
    }

    private func updateProgress(_ progress: CGFloat) {
        print("Hold progress:", progress)
        progressRingNode.alpha = 0.35 + progress * 0.65
        progressRingNode.setScale(1 + progress * 0.18)

        for (index, dot) in progressDots.enumerated() {
            dot.fillColor = progress >= CGFloat(index + 1) * 0.25 ? .manualYellow : .pastelCyan
        }
    }

    private func resetProgress() {
        progressRingNode.alpha = 0.35
        progressRingNode.setScale(1)
        for dot in progressDots {
            dot.fillColor = .pastelCyan
        }
    }

    private func triggerSuccess() {
        guard !hasSentResult else { return }
        hasSentResult = true
        stateMachine.transition(to: .successAnimating)
        print("Trigger Level 5 success")
        feedbackLabel.text = "Manual signal activated."
        feedbackLabel.fontColor = .happyBlue
        updateProgress(1)

        wristDeviceNode.fillColor = .manualYellow
        wristDeviceNode.run(.repeat(.sequence([.scale(to: 1.15, duration: 0.12), .scale(to: 1, duration: 0.12)]), count: 3))
        novaNode.fillColor = .manualYellow
        novaNode.run(.smallBounce())
        rakaNode.run(.smallBounce())
        aiScreenNode.fillColor = .glitchPurple
        aiScreenNode.run(.repeat(.sequence([.fadeAlpha(to: 0.45, duration: 0.08), .fadeAlpha(to: 1, duration: 0.08)]), count: 4))

        run(.sequence([.wait(forDuration: 0.8), .run { [weak self] in
            self?.completeSuccess()
        }]))
    }

    private func completeSuccess() {
        stateMachine.transition(to: .completed)
        levelCompletion?(LevelResult(
            levelId: "chapter1.level5.hold-wrist-device",
            didSucceed: true,
            obedienceDelta: -3,
            humanityDelta: 3,
            message: "Manual signal activated."
        ))
    }

    private func triggerFailure(reason: FailureReason) {
        guard !hasSentResult else { return }
        hasSentResult = true
        stateMachine.transition(to: .failureAnimating)
        print("Trigger Level 5 failure:", reason.rawValue)
        feedbackLabel.text = "Signal suppressed."
        feedbackLabel.fontColor = .warningRed
        resetProgress()
        wristDeviceNode.fillColor = .pastelCyan
        aiFaceLabel.text = "◠"
        aiScreenNode.run(.repeat(.sequence([.fadeAlpha(to: 0.55, duration: 0.12), .fadeAlpha(to: 1, duration: 0.12)]), count: 3))
        releaseButtonNode.run(.repeat(.sequence([.scale(to: 1.08, duration: 0.12), .scale(to: 1, duration: 0.12)]), count: 3))
        rakaNode.run(.moveBy(x: 0, y: -12, duration: 0.25))

        run(.sequence([.wait(forDuration: 0.7), .run { [weak self] in
            self?.completeFailure()
        }]))
    }

    private func completeFailure() {
        stateMachine.transition(to: .failed)
        levelCompletion?(LevelResult(
            levelId: "chapter1.level5.hold-wrist-device",
            didSucceed: false,
            obedienceDelta: 2,
            humanityDelta: 0,
            message: "Signal suppressed."
        ))
    }
}
