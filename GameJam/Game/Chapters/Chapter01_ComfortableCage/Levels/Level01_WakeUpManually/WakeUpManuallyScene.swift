import SpriteKit

class WakeUpManuallyScene: BaseGameScene {
    var levelCompletion: ((LevelResult) -> Void)?

    private let stateMachine = LevelStateMachine()
    private let validator = WakeUpTapValidator()
    private let timerController = LevelTimerController(totalDuration: WakeUpManuallyLevelConfig.totalTimeLimit)
    private let timerHUD = LevelTimerHUDNode(width: 360, height: 24)

    private var currentSceneTime: TimeInterval = 0
    private var hasSentResult = false
    private var hasLoggedTimerWarning = false
    private var hintShown = false

    private let requiredTaps = WakeUpManuallyLevelConfig.requiredWakeTaps

    private let bedNode = SKSpriteNode(imageNamed: "bed_background")
    private let sleepingRakaNode = SKSpriteNode(imageNamed: "raka_sleeping")
    private let awakeRakaNode = SKSpriteNode(imageNamed: "raka_awake")
    private let pillowNode = SKShapeNode()
    private let mattressNode = SKShapeNode()
    private let floorNode = SKShapeNode()

    private var progressDots: [SKShapeNode] = []
    private let feedbackLabel = SKLabelNode(text: "")
    private var faceHitboxNode: SKShapeNode!
    private var baseRakaScale: CGFloat = 1.0

    override func didMove(to view: SKView) {
        print("WakeUpManuallyScene aligned with Chapter 1 style")
        setupScene()
        stateMachine.reset()
        validator.reset()
        timerController.reset()
        hasSentResult = false
        hasLoggedTimerWarning = false
        hintShown = false
    }

    override func update(_ currentTime: TimeInterval) {
        currentSceneTime = currentTime

        if stateMachine.state == .ready {
            validator.start(at: currentTime)
            timerController.start(at: currentTime)
            timerHUD.update(with: timerController.update(currentTime: currentTime))
            stateMachine.transition(to: .playing)
            return
        }

        guard stateMachine.canCheckTimeout else { return }

        let timerState = timerController.update(currentTime: currentTime)
        timerHUD.update(with: timerState)
        logTimerWarningIfNeeded(timerState, levelId: WakeUpManuallyLevelConfig.levelId)
        showHintIfNeeded(timerState)

        if timerState.hasExpired {
            handleWakeUpFaceTapResult(.totalTimeout, tapLocation: .zero)
            return
        }

        guard let timeoutResult = validator.checkTimeouts(currentTime: currentTime) else { return }
        handleWakeUpFaceTapResult(timeoutResult, tapLocation: .zero)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard stateMachine.canAcceptInput, let touch = touches.first else { return }

        let point = touch.location(in: self)
        let isFaceTap = faceHitboxNode.contains(convert(point, to: faceHitboxNode.parent ?? self))
        if isFaceTap { playTapSound() }
        let result = validator.registerTap(isFaceTap: isFaceTap, time: currentSceneTime)
        handleWakeUpFaceTapResult(result, tapLocation: point)
    }

    private func setupScene() {
        removeAllChildren()
        backgroundColor = SKColor.init(hex: 0xB1DFE7)
        addBedBackground()
        addRakaHalfBody()
        addFaceHitbox()
        addProgressDots()
        addFeedbackAndTimer()
    }

    private func addBedBackground() {
        bedNode.position = CGPoint(x: size.width * 0.5, y: size.height * 0.43)
        bedNode.zPosition = 5
        let bedScaleWidth = bedNode.size.width > 0 ? (size.width * 1.1) / bedNode.size.width : 1
        let bedScaleHeight = bedNode.size.height > 0 ? (size.height * 0.4) / bedNode.size.height : 1
        bedNode.xScale = bedScaleWidth
        bedNode.yScale = bedScaleHeight
        addChild(bedNode)
    }

    private func addFloor() {
        let floorHeight = size.height * 0.22
        floorNode.path = UIBezierPath(roundedRect: CGRect(
            x: 0, y: 0,
            width: size.width, height: floorHeight
        ), cornerRadius: 0).cgPath
        floorNode.fillColor = SKColor(hex: 0xA6D0BF)
        floorNode.strokeColor = .clear
        floorNode.position = .zero
        floorNode.zPosition = 5
        addChild(floorNode)
    }

    private func addMattress() {
        let mattressWidth = size.width * 0.94
        let mattressHeight = size.height * 0.14
        mattressNode.path = CGPath(roundedRect: CGRect(
            x: -mattressWidth / 2, y: -mattressHeight / 2,
            width: mattressWidth, height: mattressHeight
        ), cornerWidth: 24, cornerHeight: 24, transform: nil)
        mattressNode.position = CGPoint(x: size.width * 0.5, y: size.height * 0.26)
        mattressNode.fillColor = SKColor(hex: 0xE7FFF0)
        mattressNode.strokeColor = .mint
        mattressNode.lineWidth = 3
        mattressNode.zPosition = 6
        addChild(mattressNode)
    }

    private func addRakaHalfBody() {
        let scaleTarget = size.height * 0.48
        let scaleFactor = (sleepingRakaNode.size.height > 0) ? (scaleTarget / sleepingRakaNode.size.height) : 1.0
        baseRakaScale = scaleFactor * 1.4

        for node in [sleepingRakaNode, awakeRakaNode] {
            node.setScale(baseRakaScale)
            node.position = CGPoint(x: size.width * 0.5, y: size.height * 0.32)
            node.zPosition = 20
            addChild(node)
        }
        awakeRakaNode.isHidden = true

        sleepingRakaNode.run(.repeatForever(.sequence([
            .scale(to: baseRakaScale * 0.985, duration: 2.0),
            .scale(to: baseRakaScale * 1.015, duration: 2.0)
        ])), withKey: "rakaBreathing")
    }

    private func addPillow() {
        let pillowWidth = size.width * 0.95
        let pillowHeight = size.height * 0.08
        pillowNode.path = CGPath(roundedRect: CGRect(
            x: -pillowWidth / 2, y: -pillowHeight / 2,
            width: pillowWidth, height: pillowHeight
        ), cornerWidth: 20, cornerHeight: 20, transform: nil)
        pillowNode.position = CGPoint(x: size.width * 0.5, y: size.height * 0.34)
        pillowNode.fillColor = SKColor(hex: 0xFFF4DC)
        pillowNode.strokeColor = SKColor(hex: 0xE9D8B8)
        pillowNode.lineWidth = 2
        pillowNode.zPosition = 7

        let shadowNode = SKShapeNode()
        shadowNode.path = CGPath(roundedRect: CGRect(
            x: -pillowWidth / 2 + 6, y: -pillowHeight / 2 - 4,
            width: pillowWidth - 12, height: pillowHeight - 4
        ), cornerWidth: 16, cornerHeight: 16, transform: nil)
        shadowNode.fillColor = SKColor(red: 0.90, green: 0.86, blue: 0.78, alpha: 1.0)
        shadowNode.strokeColor = .clear
        shadowNode.zPosition = -1
        pillowNode.addChild(shadowNode)

        addChild(pillowNode)
    }

    private func addFaceHitbox() {
        let hitboxWidth = size.width * 0.52
        let hitboxHeight = size.height * 0.26
        faceHitboxNode = SKShapeNode(rectOf: CGSize(width: hitboxWidth, height: hitboxHeight), cornerRadius: 28)
        faceHitboxNode.position = CGPoint(x: size.width * 0.5, y: size.height * 0.40)
        faceHitboxNode.fillColor = .clear
        faceHitboxNode.strokeColor = .clear
        faceHitboxNode.lineWidth = 0
        faceHitboxNode.name = "raka_face_hitbox"
        faceHitboxNode.zPosition = 50
        addChild(faceHitboxNode)
    }

    private func addProgressDots() {
        progressDots.removeAll()
        let dotRadius: CGFloat = 9
        let spacing: CGFloat = 13
        let totalWidth = CGFloat(requiredTaps) * (dotRadius * 2 + spacing) - spacing
        let startX = size.width / 2 - totalWidth / 2
        let dotY: CGFloat = size.height * 0.1

        for i in 0 ..< requiredTaps {
            let dot = SKShapeNode(circleOfRadius: dotRadius)
            dot.position = CGPoint(x: startX + CGFloat(i) * (dotRadius * 2 + spacing) + dotRadius, y: dotY)
            dot.fillColor = .clear
//            dot.strokeColor = .manualYellow.withAlphaComponent(0.5)
            dot.strokeColor = .appManualOrange.withAlphaComponent(0.5)
            dot.lineWidth = 3
            dot.zPosition = 80
            dot.name = "progress_dot_\(i)"
            addChild(dot)
            progressDots.append(dot)
        }
    }

    private func addFeedbackAndTimer() {
        feedbackLabel.fontName = GameFont.heavy
        feedbackLabel.fontSize = 22
        feedbackLabel.fontColor = .glitchPurple
        feedbackLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.66)
        feedbackLabel.zPosition = 80
        addChild(feedbackLabel)

        timerHUD.position = CGPoint(x: size.width / 2, y: 54)
        timerHUD.zPosition = 1000
        addChild(timerHUD)
    }

    private func showHintIfNeeded(_ timerState: LevelTimerState) {
        guard !hintShown, timerState.elapsed >= 2 else { return }
        hintShown = true
        feedbackLabel.text = "Tap Raka's face to wake him manually."
    }

    private func updateProgressDots(filled: Int) {
        for i in 0 ..< progressDots.count {
            let dot = progressDots[i]
            if i < filled {
                dot.fillColor = .manualYellow
                dot.strokeColor = .manualYellow
                dot.setScale(1.0)
                if i == filled - 1 {
                    dot.run(.sequence([.scale(to: 1.45, duration: 0.06), .scale(to: 1.0, duration: 0.08)]))
                }
            } else {
                dot.fillColor = .clear
                dot.strokeColor = .manualYellow.withAlphaComponent(0.5)
                dot.setScale(1.0)
            }
        }
    }

    private func handleWakeUpFaceTapResult(_ result: WakeUpFaceTapValidationResult, tapLocation: CGPoint) {
        switch result {
        case let .faceTapped(currentCount, _):
            stateMachine.transition(to: .sequenceStarted)
            updateProgressDots(filled: currentCount)
            feedbackLabel.text = "FAST TAP \(currentCount)/\(requiredTaps)"
            feedbackLabel.fontColor = currentCount >= requiredTaps - 2 ? .warningRed : .glitchPurple
            feedbackLabel.run(.sequence([.scale(to: 1.15, duration: 0.04), .scale(to: 1.0, duration: 0.08)]))
            playFaceTapAnimation(at: tapLocation)
        case let .sequenceReset(currentCount, _):
            stateMachine.transition(to: .sequenceStarted)
            updateProgressDots(filled: currentCount)
            feedbackLabel.text = "TOO SLOW — RESET \(currentCount)/\(requiredTaps)"
            feedbackLabel.fontColor = .warningRed
            feedbackLabel.run(.sequence([.scale(to: 1.2, duration: 0.05), .scale(to: 1.0, duration: 0.10)]))
            playFaceTapAnimation(at: tapLocation)
        case let .rakaAwakened(currentCount, _):
            updateProgressDots(filled: currentCount)
            playFaceTapAnimation(at: tapLocation)
            playWakeUpAnimation()
        case .ignoredTap:
            feedbackLabel.text = "Tap Raka, not the room."
            feedbackLabel.fontColor = .warningRed
        case .totalTimeout:
            triggerFailure(reason: "totalTimeout")
        }
    }

    private func playFaceTapAnimation(at point: CGPoint) {
        sleepingRakaNode.removeAction(forKey: "rakaBreathing")
        sleepingRakaNode.run(.sequence([
            .scale(to: baseRakaScale * 0.94, duration: 0.04),
            .scale(to: baseRakaScale * 1.03, duration: 0.05),
            .scale(to: baseRakaScale, duration: 0.06)
        ])) { [weak self] in
            self?.sleepingRakaNode.run(.repeatForever(.sequence([
                .scale(to: (self?.baseRakaScale ?? 1) * 0.985, duration: 2.0),
                .scale(to: (self?.baseRakaScale ?? 1) * 1.015, duration: 2.0)
            ])), withKey: "rakaBreathing")
        }

        mattressNode.run(.sequence([
            .moveBy(x: -4, y: -2, duration: 0.03),
            .moveBy(x: 8, y: 4, duration: 0.05),
            .moveBy(x: -4, y: -2, duration: 0.03)
        ]))
        pillowNode.run(.sequence([
            .moveBy(x: -3, y: -2, duration: 0.03),
            .moveBy(x: 6, y: 4, duration: 0.05),
            .moveBy(x: -3, y: -2, duration: 0.03)
        ]))

        addTapBurst(at: point)
    }

    private func addTapBurst(at point: CGPoint) {
        guard point != .zero else { return }

        [SKColor.manualYellow, SKColor.happyBlue].forEach { color in
            let size = color == .manualYellow ? CGFloat(18) : CGFloat(28)
            let burst = SKShapeNode(circleOfRadius: size)
            burst.position = point
            burst.fillColor = color.withAlphaComponent(0.30)
            burst.strokeColor = color
            burst.lineWidth = 3
            burst.zPosition = 60
            addChild(burst)
            burst.run(.sequence([
                .group([.scale(to: 2.2, duration: 0.25), .fadeOut(withDuration: 0.25)]),
                .removeFromParent()
            ]))
        }
    }

    private func playWakeUpAnimation() {
        guard !hasSentResult else { return }
        stateMachine.transition(to: .successAnimating)
        feedbackLabel.text = WakeUpManuallyLevelConfig.successMessage
        feedbackLabel.fontColor = .happyBlue

        sleepingRakaNode.removeAction(forKey: "rakaBreathing")
        sleepingRakaNode.isHidden = true
        awakeRakaNode.isHidden = false
       awakeRakaNode.run(.sequence([
           .wait(forDuration: 0.25),
           .run { [weak self] in self?.triggerSuccess() }
       ]))
    }

    private func triggerSuccess() {
        guard !hasSentResult else { return }
        hasSentResult = true
        complete(LevelResult(
            levelId: WakeUpManuallyLevelConfig.levelId,
            didSucceed: true,
            obedienceDelta: WakeUpManuallyLevelConfig.successObedienceDelta,
            humanityDelta: WakeUpManuallyLevelConfig.successHumanityDelta,
            message: WakeUpManuallyLevelConfig.successMessage
        ))
    }

    private func triggerFailure(reason: String) {
        guard !hasSentResult else { return }
        hasSentResult = true
        stateMachine.transition(to: .failureAnimating)
        feedbackLabel.text = WakeUpManuallyLevelConfig.failureMessage
        feedbackLabel.fontColor = .warningRed
        complete(LevelResult(
            levelId: WakeUpManuallyLevelConfig.levelId,
            didSucceed: false,
            obedienceDelta: WakeUpManuallyLevelConfig.failureObedienceDelta,
            humanityDelta: WakeUpManuallyLevelConfig.failureHumanityDelta,
            message: WakeUpManuallyLevelConfig.failureMessage
        ))
    }

    private func complete(_ result: LevelResult) {
        stateMachine.transition(to: result.didSucceed ? .completed : .failed)
        DispatchQueue.main.async { [weak self] in
            self?.levelCompletion?(result)
        }
    }

    private func logTimerWarningIfNeeded(_ timerState: LevelTimerState, levelId: String) {
        guard timerState.isWarning, !hasLoggedTimerWarning else { return }
        hasLoggedTimerWarning = true
        print("Timer warning started:", levelId)
    }
}
