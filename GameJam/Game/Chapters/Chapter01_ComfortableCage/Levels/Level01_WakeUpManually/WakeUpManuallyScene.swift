import SpriteKit

final class WakeUpManuallyScene: SKScene {
    var levelCompletion: ((LevelResult) -> Void)?

    private let stateMachine = LevelStateMachine()
    private let validator = TapSequenceValidator()
    private let timerController = LevelTimerController(totalDuration: 8.0)
    private let timerHUD = LevelTimerHUDNode(width: 260, height: 14)

    private var currentSceneTime: TimeInterval = 0
    private var hasSentResult = false
    private var hasLoggedTimerWarning = false

    private let aiScreenNode = SKShapeNode(rectOf: .zero)
    private let blanketNode = SKShapeNode(rectOf: .zero)
    private let bodyNode = SKShapeNode(rectOf: .zero)
    private let headNode = SKShapeNode(circleOfRadius: 1)
    private let wristNode = SKShapeNode(circleOfRadius: 1)
    private let eyesNode = SKLabelNode(text: "– –")
    private let progressLabel = SKLabelNode(text: "0 / 4")
    private let feedbackLabel = SKLabelNode(text: "")

    override func didMove(to view: SKView) {
        setupScene()
        stateMachine.reset()
        validator.reset()
        timerController.reset()
        hasSentResult = false
        hasLoggedTimerWarning = false
    }

    override func update(_ currentTime: TimeInterval) {
        currentSceneTime = currentTime

        if stateMachine.state == .ready {
            validator.start(at: currentTime)
            timerController.start(at: currentTime)
            timerHUD.update(with: timerController.update(currentTime: currentTime))
            stateMachine.transition(to: .playing)
            print("Timer started for level:", "chapter1.level1.wake-up-manually")
            return
        }

        guard stateMachine.canCheckTimeout else { return }

        let timerState = timerController.update(currentTime: currentTime)
        timerHUD.update(with: timerState)
        logTimerWarningIfNeeded(timerState, levelId: "chapter1.level1.wake-up-manually")
        if timerState.hasExpired {
            print("Timer expired:", "chapter1.level1.wake-up-manually")
            triggerFailure()
            return
        }

        guard let timeout = validator.checkTimeouts(currentTime: currentTime) else { return }
        handleValidationResult(timeout)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard stateMachine.canAcceptInput, let touch = touches.first else { return }

        let zone = tapZone(at: touch.location(in: self))
        let result = validator.registerTap(zone: zone, time: currentSceneTime)
        handleValidationResult(result)
    }

    private func setupScene() {
        removeAllChildren()
        backgroundColor = .pastelCyan

        addBackground()
        addAIScreen()
        addCommandCard()
        addTimerHUD()
        addBedAndRaka()
        addProgressAndFeedback()
    }

    private func addBackground() {
        let floor = SKShapeNode(rectOf: CGSize(width: size.width, height: size.height * 0.36))
        floor.position = CGPoint(x: size.width / 2, y: size.height * 0.18)
        floor.fillColor = .cream
        floor.strokeColor = .clear
        floor.zPosition = 0
        addChild(floor)

        let window = SKShapeNode(rectOf: CGSize(width: size.width * 0.72, height: size.height * 0.16), cornerRadius: 24)
        window.position = CGPoint(x: size.width / 2, y: size.height * 0.78)
        window.fillColor = .mint
        window.strokeColor = .white
        window.lineWidth = 4
        window.zPosition = 1
        addChild(window)
    }

    private func addAIScreen() {
        aiScreenNode.path = CGPath(roundedRect: CGRect(x: -92, y: -44, width: 184, height: 88), cornerWidth: 18, cornerHeight: 18, transform: nil)
        aiScreenNode.position = CGPoint(x: size.width / 2, y: size.height * 0.76)
        aiScreenNode.fillColor = .happyBlue
        aiScreenNode.strokeColor = .white
        aiScreenNode.lineWidth = 4
        aiScreenNode.zPosition = 2
        addChild(aiScreenNode)

        let face = SKLabelNode(text: "◡")
        face.fontName = GameFont.bold
        face.fontSize = 54
        face.fontColor = .white
        face.verticalAlignmentMode = .center
        aiScreenNode.addChild(face)
    }

    private func addCommandCard() {
        let card = SKShapeNode(rectOf: CGSize(width: size.width * 0.78, height: 78), cornerRadius: 18)
        card.position = CGPoint(x: size.width / 2, y: size.height * 0.63)
        card.fillColor = .white.withAlphaComponent(0.9)
        card.strokeColor = .glitchPurple
        card.lineWidth = 3
        card.zPosition = 2
        addChild(card)

        let command = SKLabelNode(text: "Stay asleep.\nYour schedule has been optimized.")
        command.fontName = GameFont.regular
        command.fontSize = 18
        command.fontColor = .glitchPurple
        command.numberOfLines = 2
        command.horizontalAlignmentMode = .center
        command.verticalAlignmentMode = .center
        command.preferredMaxLayoutWidth = size.width * 0.7
        card.addChild(command)
    }


    private func addTimerHUD() {
        timerHUD.position = CGPoint(x: size.width / 2, y: 72)
        timerHUD.zPosition = 1000
        addChild(timerHUD)
    }

    private func logTimerWarningIfNeeded(_ timerState: LevelTimerState, levelId: String) {
        guard timerState.isWarning, !hasLoggedTimerWarning else { return }
        hasLoggedTimerWarning = true
        print("Timer warning started:", levelId)
    }

    private func addBedAndRaka() {
        let bed = SKShapeNode(rectOf: CGSize(width: size.width * 0.78, height: size.height * 0.22), cornerRadius: 28)
        bed.position = CGPoint(x: size.width / 2, y: size.height * 0.4)
        bed.fillColor = .mint
        bed.strokeColor = .happyBlue
        bed.lineWidth = 5
        bed.zPosition = 2
        addChild(bed)

        bodyNode.path = CGPath(roundedRect: CGRect(x: -86, y: -28, width: 172, height: 56), cornerWidth: 28, cornerHeight: 28, transform: nil)
        bodyNode.position = CGPoint(x: size.width * 0.52, y: size.height * 0.42)
        bodyNode.fillColor = SKColor(red: 0.96, green: 0.69, blue: 0.48, alpha: 1)
        bodyNode.strokeColor = .white
        bodyNode.lineWidth = 3
        bodyNode.zPosition = 4
        addChild(bodyNode)

        headNode.path = CGPath(ellipseIn: CGRect(x: -34, y: -34, width: 68, height: 68), transform: nil)
        headNode.position = CGPoint(x: size.width * 0.32, y: size.height * 0.44)
        headNode.fillColor = SKColor(red: 0.98, green: 0.75, blue: 0.57, alpha: 1)
        headNode.strokeColor = .white
        headNode.lineWidth = 3
        headNode.zPosition = 5
        addChild(headNode)

        eyesNode.fontName = GameFont.bold
        eyesNode.fontSize = 18
        eyesNode.fontColor = .glitchPurple
        eyesNode.verticalAlignmentMode = .center
        eyesNode.zPosition = 6
        headNode.addChild(eyesNode)

        wristNode.path = CGPath(ellipseIn: CGRect(x: -16, y: -16, width: 32, height: 32), transform: nil)
        wristNode.position = CGPoint(x: size.width * 0.67, y: size.height * 0.44)
        wristNode.fillColor = .manualYellow
        wristNode.strokeColor = .white
        wristNode.lineWidth = 3
        wristNode.zPosition = 7
        addChild(wristNode)

        blanketNode.path = CGPath(roundedRect: CGRect(x: -110, y: -44, width: 220, height: 88), cornerWidth: 26, cornerHeight: 26, transform: nil)
        blanketNode.position = CGPoint(x: size.width * 0.54, y: size.height * 0.38)
        blanketNode.fillColor = SKColor(red: 0.75, green: 0.82, blue: 1.0, alpha: 0.88)
        blanketNode.strokeColor = .white
        blanketNode.lineWidth = 3
        blanketNode.zPosition = 6
        addChild(blanketNode)
    }

    private func addProgressAndFeedback() {
        progressLabel.fontName = GameFont.bold
        progressLabel.fontSize = 22
        progressLabel.fontColor = .happyBlue
        progressLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.25)
        progressLabel.zPosition = 8
        addChild(progressLabel)

        feedbackLabel.fontName = GameFont.heavy
        feedbackLabel.fontSize = 24
        feedbackLabel.fontColor = .glitchPurple
        feedbackLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.16)
        feedbackLabel.zPosition = 8
        addChild(feedbackLabel)
    }

    private func tapZone(at point: CGPoint) -> TapZone {
        if wristNode.contains(convert(point, to: wristNode.parent ?? self)) { return .wrist }
        if headNode.contains(convert(point, to: headNode.parent ?? self)) { return .head }
        if bodyNode.contains(convert(point, to: bodyNode.parent ?? self)) { return .body }
        return .wrong
    }

    private func handleValidationResult(_ result: TapSequenceValidationResult) {
        switch result {
        case let .correctStep(progress, total):
            stateMachine.transition(to: .sequenceStarted)
            progressLabel.text = "\(progress) / \(total)"
            feedbackLabel.text = "Manual input detected..."
        case .completed:
            triggerSuccess()
        case .wrong, .noInputTimeout, .gapTimeout, .totalTimeout:
            triggerFailure()
        }
    }

    private func triggerSuccess() {
        guard !hasSentResult else { return }
        hasSentResult = true
        stateMachine.transition(to: .successAnimating)
        progressLabel.text = "4 / 4"
        feedbackLabel.text = "Manual Action Detected."
        feedbackLabel.fontColor = .happyBlue
        eyesNode.text = "• •"

        bodyNode.run(.smallBounce())
        headNode.run(.smallBounce())
        wristNode.run(.repeat(.sequence([.fadeAlpha(to: 0.45, duration: 0.15), .fadeAlpha(to: 1, duration: 0.15)]), count: 4))
        blanketNode.run(.group([.moveBy(x: 0, y: 80, duration: 0.35), .fadeOut(withDuration: 0.35)]))

        run(.sequence([.wait(forDuration: 0.45), .run { [weak self] in
            self?.completeSuccess()
        }]))
    }

    private func completeSuccess() {
        stateMachine.transition(to: .completed)
        levelCompletion?(LevelResult(
            levelId: "chapter1.level1.wake-up-manually",
            didSucceed: true,
            obedienceDelta: -2,
            humanityDelta: 2,
            message: "Manual Action Detected."
        ))
    }

    private func triggerFailure() {
        guard !hasSentResult else { return }
        hasSentResult = true
        stateMachine.transition(to: .failureAnimating)
        feedbackLabel.text = "Compliance Detected."
        feedbackLabel.fontColor = .warningRed
        blanketNode.run(.group([.scaleY(to: 1.16, duration: 0.25), .fadeAlpha(to: 1, duration: 0.25)]))
        aiScreenNode.run(.repeat(.sequence([.fadeAlpha(to: 0.55, duration: 0.12), .fadeAlpha(to: 1, duration: 0.12)]), count: 3))

        run(.sequence([.wait(forDuration: 0.45), .run { [weak self] in
            self?.completeFailure()
        }]))
    }

    private func completeFailure() {
        stateMachine.transition(to: .failed)
        levelCompletion?(LevelResult(
            levelId: "chapter1.level1.wake-up-manually",
            didSucceed: false,
            obedienceDelta: 2,
            humanityDelta: 0,
            message: "Compliance Detected."
        ))
    }
}
