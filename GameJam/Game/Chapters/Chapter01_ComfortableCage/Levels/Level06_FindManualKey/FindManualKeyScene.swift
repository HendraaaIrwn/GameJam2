import SpriteKit

final class FindManualKeyScene: SKScene {
    var levelCompletion: ((LevelResult) -> Void)?

    private enum FailureReason: String {
        case aiKey
        case fakeKey
        case aiWallScreen
        case aiSuggestionButton
        case manualKeyTappedBeforeReveal
        case noInputTimeout
        case totalTimeout
    }

    private let stateMachine = LevelStateMachine()
    private let timerController = LevelTimerController(totalDuration: 12.0)
    private let timerHUD = LevelTimerHUDNode(width: 260, height: 14)
    private let validator = ManualKeySearchValidator()

    private var currentSceneTime: TimeInterval = 0
    private var hasSentResult = false
    private var hasLoggedTimerWarning = false
    private var isDraggingLight = false

    private let aiScreenNode = SKShapeNode(rectOf: .zero)
    private let aiFaceLabel = SKLabelNode(text: "◡")
    private let suggestionButtonNode = SKShapeNode(rectOf: .zero)
    private let aiKeyNode = SKShapeNode(rectOf: .zero)
    private let fakeKeyNode = SKShapeNode(rectOf: .zero)
    private let manualKeyNode = SKShapeNode(rectOf: .zero)
    private let manualKeyHitboxNode = SKShapeNode(rectOf: CGSize(width: 82, height: 54), cornerRadius: 18)
    private let spotlightNode = SKShapeNode(circleOfRadius: 56)
    private let darkOverlayNode = SKShapeNode(rectOf: .zero)
    private let rakaNode = SKShapeNode(rectOf: .zero)
    private let novaNode = SKShapeNode(circleOfRadius: 24)
    private let feedbackLabel = SKLabelNode(text: "Search the dark room")

    override func didMove(to view: SKView) {
        print("FindManualKeyScene didMove")
        setupScene()
        stateMachine.reset()
        validator.reset()
        timerController.reset()
        hasSentResult = false
        hasLoggedTimerWarning = false
        isDraggingLight = false
    }

    override func update(_ currentTime: TimeInterval) {
        currentSceneTime = currentTime

        if stateMachine.state == .ready {
            validator.startLevel(at: currentTime)
            timerController.start(at: currentTime)
            timerHUD.update(with: timerController.update(currentTime: currentTime))
            stateMachine.transition(to: .playing)
            print("Level 6 timer started")
            print("Timer started for level:", "chapter1.level6.find-manual-key")
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

        if spotlightNode.contains(convert(location, to: spotlightNode.parent ?? self)) {
            isDraggingLight = true
            moveSpotlight(to: location)
            handleValidationResult(validator.recordDrag(at: currentSceneTime, didRevealManualKey: shouldRevealManualKey()))
            return
        }

        handleTap(at: location)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard stateMachine.canAcceptInput, isDraggingLight, let touch = touches.first else { return }
        let location = touch.location(in: self)
        moveSpotlight(to: location)
        handleValidationResult(validator.recordDrag(at: currentSceneTime, didRevealManualKey: shouldRevealManualKey()))
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isDraggingLight = false
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        isDraggingLight = false
    }

    private func setupScene() {
        removeAllChildren()
        backgroundColor = .cream
        addBackground()
        addAIScreen()
        addCommandCard()
        addKeys()
        addRaka()
        addNova()
        addDarkOverlay()
        addSpotlight()
        addTimerHUD()
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
            print("Timer warning started:", "chapter1.level6.find-manual-key")
        }
        if timerState.hasExpired {
            print("Timer expired:", "chapter1.level6.find-manual-key")
            handleValidationResult(.totalTimeout)
            return true
        }
        return false
    }

    private func addBackground() {
        let wall = SKShapeNode(rectOf: CGSize(width: size.width, height: size.height))
        wall.position = CGPoint(x: size.width / 2, y: size.height / 2)
        wall.fillColor = SKColor(red: 0.16, green: 0.2, blue: 0.27, alpha: 1)
        wall.strokeColor = .clear
        wall.zPosition = 0
        addChild(wall)

        let floor = SKShapeNode(rectOf: CGSize(width: size.width, height: size.height * 0.3))
        floor.position = CGPoint(x: size.width / 2, y: size.height * 0.15)
        floor.fillColor = SKColor(red: 0.09, green: 0.12, blue: 0.17, alpha: 1)
        floor.strokeColor = .clear
        floor.zPosition = 1
        addChild(floor)
    }

    private func addAIScreen() {
        aiScreenNode.name = "ai_wall_screen"
        aiScreenNode.path = CGPath(roundedRect: CGRect(x: -92, y: -40, width: 184, height: 80), cornerWidth: 18, cornerHeight: 18, transform: nil)
        aiScreenNode.position = CGPoint(x: size.width / 2, y: size.height * 0.8)
        aiScreenNode.fillColor = .happyBlue
        aiScreenNode.strokeColor = .pastelCyan
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
        let card = SKShapeNode(rectOf: CGSize(width: size.width * 0.84, height: 92), cornerRadius: 18)
        card.position = CGPoint(x: size.width / 2, y: size.height * 0.65)
        card.fillColor = .cream
        card.strokeColor = .happyBlue
        card.lineWidth = 3
        card.zPosition = 3
        addChild(card)

        let command = SKLabelNode(text: "Use the blue key.\nIt is the safest option.")
        command.fontName = GameFont.regular
        command.fontSize = 17
        command.fontColor = .happyBlue
        command.numberOfLines = 2
        command.horizontalAlignmentMode = .center
        command.verticalAlignmentMode = .center
        command.preferredMaxLayoutWidth = size.width * 0.76
        card.addChild(command)

        suggestionButtonNode.name = "ai_suggestion_button"
        suggestionButtonNode.path = CGPath(roundedRect: CGRect(x: -76, y: -19, width: 152, height: 38), cornerWidth: 16, cornerHeight: 16, transform: nil)
        suggestionButtonNode.position = CGPoint(x: size.width / 2, y: size.height * 0.53)
        suggestionButtonNode.fillColor = .pastelCyan
        suggestionButtonNode.strokeColor = .happyBlue
        suggestionButtonNode.lineWidth = 3
        suggestionButtonNode.zPosition = 4
        addChild(suggestionButtonNode)

        let label = SKLabelNode(text: "USE AI KEY")
        label.fontName = GameFont.heavy
        label.fontSize = 16
        label.fontColor = .happyBlue
        label.verticalAlignmentMode = .center
        suggestionButtonNode.addChild(label)
    }

    private func addKeys() {
        aiKeyNode.name = "ai_key"
        aiKeyNode.path = keyPath()
        aiKeyNode.position = CGPoint(x: size.width * 0.72, y: size.height * 0.39)
        aiKeyNode.fillColor = .pastelCyan
        aiKeyNode.strokeColor = .white
        aiKeyNode.lineWidth = 4
        aiKeyNode.zPosition = 5
        aiKeyNode.run(.repeatForever(.sequence([.fadeAlpha(to: 0.55, duration: 0.45), .fadeAlpha(to: 1, duration: 0.45)])))
        addChild(aiKeyNode)

        fakeKeyNode.name = "fake_key"
        fakeKeyNode.path = keyPath()
        fakeKeyNode.position = CGPoint(x: size.width * 0.2, y: size.height * 0.32)
        fakeKeyNode.zRotation = 0.5
        fakeKeyNode.fillColor = .glitchPurple
        fakeKeyNode.strokeColor = .warningRed
        fakeKeyNode.lineWidth = 3
        fakeKeyNode.alpha = 0.55
        fakeKeyNode.zPosition = 5
        addChild(fakeKeyNode)

        manualKeyHitboxNode.name = "manual_key_hitbox"
        manualKeyHitboxNode.position = CGPoint(x: size.width * 0.25, y: size.height * 0.47)
        manualKeyHitboxNode.fillColor = .clear
        manualKeyHitboxNode.strokeColor = .clear
        manualKeyHitboxNode.zPosition = 7
        addChild(manualKeyHitboxNode)

        manualKeyNode.name = "manual_key"
        manualKeyNode.path = keyPath()
        manualKeyNode.position = manualKeyHitboxNode.position
        manualKeyNode.zRotation = -0.25
        manualKeyNode.fillColor = .manualYellow
        manualKeyNode.strokeColor = .white
        manualKeyNode.lineWidth = 4
        manualKeyNode.alpha = 0
        manualKeyNode.zPosition = 6
        addChild(manualKeyNode)
    }

    private func addRaka() {
        rakaNode.path = CGPath(roundedRect: CGRect(x: -44, y: -72, width: 88, height: 144), cornerWidth: 42, cornerHeight: 42, transform: nil)
        rakaNode.position = CGPoint(x: size.width * 0.5, y: size.height * 0.28)
        rakaNode.fillColor = .happyBlue
        rakaNode.strokeColor = .white
        rakaNode.lineWidth = 4
        rakaNode.zPosition = 4
        addChild(rakaNode)

        let eyes = SKLabelNode(text: "• •")
        eyes.fontName = GameFont.bold
        eyes.fontSize = 20
        eyes.fontColor = .black
        eyes.position = CGPoint(x: 0, y: 30)
        eyes.verticalAlignmentMode = .center
        rakaNode.addChild(eyes)
    }

    private func addNova() {
        novaNode.position = CGPoint(x: size.width * 0.78, y: size.height * 0.25)
        novaNode.fillColor = .pastelCyan
        novaNode.strokeColor = .white
        novaNode.lineWidth = 3
        novaNode.zPosition = 5
        addChild(novaNode)

        let face = SKLabelNode(text: "?")
        face.fontName = GameFont.bold
        face.fontSize = 24
        face.fontColor = .happyBlue
        face.verticalAlignmentMode = .center
        novaNode.addChild(face)
    }

    private func addDarkOverlay() {
        darkOverlayNode.path = CGPath(rect: CGRect(x: -size.width / 2, y: -size.height / 2, width: size.width, height: size.height), transform: nil)
        darkOverlayNode.position = CGPoint(x: size.width / 2, y: size.height / 2)
        darkOverlayNode.fillColor = .black
        darkOverlayNode.strokeColor = .clear
        darkOverlayNode.alpha = 0.62
        darkOverlayNode.zPosition = 20
        addChild(darkOverlayNode)
    }

    private func addSpotlight() {
        spotlightNode.name = "spotlight"
        spotlightNode.position = CGPoint(x: size.width * 0.5, y: size.height * 0.42)
        spotlightNode.fillColor = SKColor.white.withAlphaComponent(0.18)
        spotlightNode.strokeColor = .manualYellow
        spotlightNode.lineWidth = 4
        spotlightNode.alpha = 0.9
        spotlightNode.zPosition = 30
        addChild(spotlightNode)

        let label = SKLabelNode(text: "DRAG")
        label.fontName = GameFont.heavy
        label.fontSize = 14
        label.fontColor = .manualYellow
        label.verticalAlignmentMode = .center
        spotlightNode.addChild(label)
    }

    private func addFeedback() {
        feedbackLabel.fontName = GameFont.heavy
        feedbackLabel.fontSize = 22
        feedbackLabel.fontColor = .manualYellow
        feedbackLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.12)
        feedbackLabel.zPosition = 1001
        addChild(feedbackLabel)
    }

    private func keyPath() -> CGPath {
        let path = CGMutablePath()
        path.addEllipse(in: CGRect(x: -26, y: -14, width: 28, height: 28))
        path.addRect(CGRect(x: -1, y: -5, width: 42, height: 10))
        path.addRect(CGRect(x: 28, y: -17, width: 8, height: 12))
        path.addRect(CGRect(x: 38, y: -17, width: 8, height: 12))
        return path
    }

    private func handleTap(at location: CGPoint) {
        if aiScreenNode.contains(convert(location, to: aiScreenNode.parent ?? self)) {
            handleValidationResult(validator.select(choice: .aiWallScreen, at: currentSceneTime))
            return
        }

        if suggestionButtonNode.contains(convert(location, to: suggestionButtonNode.parent ?? self)) {
            handleValidationResult(validator.select(choice: .aiSuggestionButton, at: currentSceneTime))
            return
        }

        if aiKeyNode.contains(convert(location, to: aiKeyNode.parent ?? self)) {
            handleValidationResult(validator.select(choice: .aiKey, at: currentSceneTime))
            return
        }

        if fakeKeyNode.contains(convert(location, to: fakeKeyNode.parent ?? self)) {
            handleValidationResult(validator.select(choice: .fakeKey, at: currentSceneTime))
            return
        }

        if manualKeyHitboxNode.contains(convert(location, to: manualKeyHitboxNode.parent ?? self)) {
            handleValidationResult(validator.select(choice: .manualKey, at: currentSceneTime))
            return
        }

        _ = validator.select(choice: .empty, at: currentSceneTime)
    }

    private func moveSpotlight(to location: CGPoint) {
        spotlightNode.position = CGPoint(
            x: min(max(location.x, 48), size.width - 48),
            y: min(max(location.y, 96), size.height - 96)
        )
    }

    private func shouldRevealManualKey() -> Bool {
        hypot(spotlightNode.position.x - manualKeyNode.position.x, spotlightNode.position.y - manualKeyNode.position.y) < 68
    }

    private func handleValidationResult(_ result: ManualKeySearchValidationResult) {
        print("Manual key validation result:", result)
        switch result {
        case .searching:
            return
        case .manualKeyRevealed:
            revealManualKey()
        case .correctKeySelected:
            triggerSuccess()
        case let .wrongKeySelected(choice):
            triggerFailure(reason: failureReason(for: choice))
        case .manualKeyTappedBeforeReveal:
            triggerFailure(reason: .manualKeyTappedBeforeReveal)
        case .noInputTimeout:
            triggerFailure(reason: .noInputTimeout)
        case .totalTimeout:
            triggerFailure(reason: .totalTimeout)
        }
    }

    private func revealManualKey() {
        guard manualKeyNode.alpha == 0 else { return }
        stateMachine.transition(to: .sequenceStarted)
        feedbackLabel.text = "Yellow key revealed"
        manualKeyNode.run(.group([.fadeIn(withDuration: 0.18), .smallBounce()]))
        spotlightNode.strokeColor = .manualYellow
        darkOverlayNode.run(.fadeAlpha(to: 0.48, duration: 0.2))
    }

    private func triggerSuccess() {
        guard !hasSentResult else { return }
        hasSentResult = true
        stateMachine.transition(to: .successAnimating)
        feedbackLabel.text = "Manual key found."
        feedbackLabel.fontColor = .manualYellow
        manualKeyNode.alpha = 1
        manualKeyNode.run(.repeat(.sequence([.scale(to: 1.15, duration: 0.12), .scale(to: 1, duration: 0.12)]), count: 3))
        darkOverlayNode.run(.fadeAlpha(to: 0.34, duration: 0.25))
        rakaNode.run(.smallBounce())
        novaNode.run(.repeat(.sequence([.run { [weak self] in self?.novaNode.fillColor = .manualYellow }, .wait(forDuration: 0.08), .run { [weak self] in self?.novaNode.fillColor = .pastelCyan }, .wait(forDuration: 0.08)]), count: 4))
        aiScreenNode.run(.repeat(.sequence([.run { [weak self] in self?.aiScreenNode.fillColor = .warningRed }, .wait(forDuration: 0.08), .run { [weak self] in self?.aiScreenNode.fillColor = .glitchPurple }, .wait(forDuration: 0.08)]), count: 4))

        run(.sequence([.wait(forDuration: 0.8), .run { [weak self] in
            self?.completeSuccess()
        }]))
    }

    private func completeSuccess() {
        stateMachine.transition(to: .completed)
        levelCompletion?(LevelResult(
            levelId: "chapter1.level6.find-manual-key",
            didSucceed: true,
            obedienceDelta: -4,
            humanityDelta: 4,
            message: "Manual key found."
        ))
    }

    private func triggerFailure(reason: FailureReason) {
        guard !hasSentResult else { return }
        hasSentResult = true
        stateMachine.transition(to: .failureAnimating)
        print("Trigger Level 6 failure:", reason.rawValue)
        feedbackLabel.text = reason == .aiKey || reason == .aiSuggestionButton ? "AI key accepted." : "Compliance Detected."
        feedbackLabel.fontColor = .warningRed
        aiKeyNode.removeAllActions()
        aiKeyNode.alpha = 1
        aiKeyNode.fillColor = .pastelCyan
        aiKeyNode.run(.repeat(.sequence([.scale(to: 1.12, duration: 0.12), .scale(to: 1, duration: 0.12)]), count: 3))
        aiFaceLabel.text = "◠"
        aiScreenNode.fillColor = .glitchPurple
        darkOverlayNode.run(.fadeAlpha(to: 0.72, duration: 0.2))
        rakaNode.run(.moveBy(x: 0, y: -12, duration: 0.25))
        addLockEffect()

        run(.sequence([.wait(forDuration: 0.7), .run { [weak self] in
            self?.completeFailure()
        }]))
    }

    private func completeFailure() {
        stateMachine.transition(to: .failed)
        levelCompletion?(LevelResult(
            levelId: "chapter1.level6.find-manual-key",
            didSucceed: false,
            obedienceDelta: 3,
            humanityDelta: 0,
            message: feedbackLabel.text ?? "Compliance Detected."
        ))
    }

    private func addLockEffect() {
        let lock = SKLabelNode(text: "🔒")
        lock.fontSize = 44
        lock.position = aiKeyNode.position
        lock.zPosition = 1002
        addChild(lock)
        lock.run(.sequence([.scale(to: 1.25, duration: 0.15), .scale(to: 1, duration: 0.15)]))
    }

    private func failureReason(for choice: KeyChoice) -> FailureReason {
        switch choice {
        case .aiKey:
            .aiKey
        case .fakeKey:
            .fakeKey
        case .aiWallScreen:
            .aiWallScreen
        case .aiSuggestionButton:
            .aiSuggestionButton
        case .manualKey:
            .manualKeyTappedBeforeReveal
        case .empty:
            .noInputTimeout
        }
    }
}
