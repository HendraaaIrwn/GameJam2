import SpriteKit

final class OpenSmartCurtainScene: SKScene {
    var levelCompletion: ((LevelResult) -> Void)?

    private enum FailureReason: String {
        case keepClosedTapped
        case aiScreenTapped
        case noInputTimeout
        case totalTimeout
    }

    private let stateMachine = LevelStateMachine()
    private let timerController = LevelTimerController(totalDuration: 8.0)
    private let timerHUD = LevelTimerHUDNode(width: 260, height: 14)
    private let validator = CurtainDragValidator()

    private var currentSceneTime: TimeInterval = 0
    private var levelStartTime: TimeInterval?
    private var hasReceivedInput = false
    private var hasSentResult = false
    private var hasLoggedTimerWarning = false
    private var dragStartPoint: CGPoint?
    private var curtainOpenProgress: CGFloat = 0

    private let noInputTimeout = 4.0
    private let aiScreenNode = SKShapeNode(rectOf: .zero)
    private let aiFaceLabel = SKLabelNode(text: "◡")
    private let windowNode = SKShapeNode(rectOf: .zero)
    private let cityNode = SKNode()
    private let leftCurtainNode = SKShapeNode(rectOf: .zero)
    private let rightCurtainNode = SKShapeNode(rectOf: .zero)
    private let keepClosedButtonNode = SKShapeNode(rectOf: .zero)
    private let rakaNode = SKShapeNode(rectOf: .zero)
    private let rakaEyesLabel = SKLabelNode(text: "• •")
    private let wristNode = SKShapeNode(circleOfRadius: 1)
    private let feedbackLabel = SKLabelNode(text: "Drag curtain sideways")
    private let lightNode = SKShapeNode(rectOf: .zero)
    private let lockLabel = SKLabelNode(text: "🔒")

    private var leftClosedX: CGFloat = 0
    private var rightClosedX: CGFloat = 0
    private var leftOpenX: CGFloat = 0
    private var rightOpenX: CGFloat = 0

    override func didMove(to view: SKView) {
        print("OpenSmartCurtainScene didMove")
        setupScene()
        stateMachine.reset()
        levelStartTime = nil
        hasReceivedInput = false
        timerController.reset()
        hasSentResult = false
        hasLoggedTimerWarning = false
        dragStartPoint = nil
        curtainOpenProgress = 0
    }

    override func update(_ currentTime: TimeInterval) {
        currentSceneTime = currentTime

        if stateMachine.state == .ready {
            levelStartTime = currentTime
            timerController.start(at: currentTime)
            timerHUD.update(with: timerController.update(currentTime: currentTime))
            stateMachine.transition(to: .playing)
            print("Level 3 timer started")
            print("Timer started for level:", "chapter1.level3.open-smart-curtain")
            return
        }

        guard stateMachine.canCheckTimeout, let levelStartTime else { return }

        if updateTimer(currentTime: currentTime) { return }

        if !hasReceivedInput && currentTime - levelStartTime > noInputTimeout {
            triggerFailure(reason: .noInputTimeout)
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard stateMachine.canAcceptInput, let touch = touches.first else { return }
        let location = touch.location(in: self)
        hasReceivedInput = true

        if keepClosedButtonNode.contains(convert(location, to: keepClosedButtonNode.parent ?? self)) {
            print("Touched Keep Closed button")
            triggerFailure(reason: .keepClosedTapped)
            return
        }

        if aiScreenNode.contains(convert(location, to: aiScreenNode.parent ?? self)) {
            print("Touched AI wall screen")
            triggerFailure(reason: .aiScreenTapped)
            return
        }

        if windowNode.contains(convert(location, to: windowNode.parent ?? self)) {
            print("Touched curtain area")
            dragStartPoint = location
            stateMachine.transition(to: .sequenceStarted)
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard stateMachine.canAcceptInput,
              dragStartPoint != nil,
              let touch = touches.first else { return }

        applyCurtainProgress(for: touch.location(in: self))
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard stateMachine.canAcceptInput,
              let dragStartPoint,
              let touch = touches.first else { return }

        let location = touch.location(in: self)
        let translation = CGVector(dx: location.x - dragStartPoint.x, dy: location.y - dragStartPoint.y)
        print("Drag translation:", translation)
        let result = validator.validateDrag(translation: translation)
        print("Curtain validation result:", result)
        self.dragStartPoint = nil

        switch result {
        case .validOpen:
            triggerSuccess()
        case .insufficientDrag:
            snapCurtainsClosed(message: "Curtain resisted.")
        case .wrongDirection:
            snapCurtainsClosed(message: "Open sideways.")
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard dragStartPoint != nil else { return }
        dragStartPoint = nil
        snapCurtainsClosed(message: "Try again")
    }

    private func setupScene() {
        removeAllChildren()
        backgroundColor = .pastelCyan
        addBackground()
        addAIScreen()
        addTimerHUD()
        addWindowAndCity()
        addRaka()
        addKeepClosedButton()
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
            print("Timer warning started:", "chapter1.level3.open-smart-curtain")
        }
        if timerState.hasExpired {
            print("Timer expired:", "chapter1.level3.open-smart-curtain")
            triggerFailure(reason: .totalTimeout)
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
        aiScreenNode.path = CGPath(roundedRect: CGRect(x: -86, y: -38, width: 172, height: 76), cornerWidth: 18, cornerHeight: 18, transform: nil)
        aiScreenNode.position = CGPoint(x: size.width / 2, y: size.height * 0.79)
        aiScreenNode.fillColor = .happyBlue
        aiScreenNode.strokeColor = .white
        aiScreenNode.lineWidth = 4
        aiScreenNode.zPosition = 2
        addChild(aiScreenNode)

        aiFaceLabel.fontName = GameFont.bold
        aiFaceLabel.fontSize = 50
        aiFaceLabel.fontColor = .white
        aiFaceLabel.verticalAlignmentMode = .center
        aiScreenNode.addChild(aiFaceLabel)
    }

    private func addCommandCard() {
        let card = SKShapeNode(rectOf: CGSize(width: size.width * 0.76, height: 72), cornerRadius: 18)
        card.position = CGPoint(x: size.width / 2, y: size.height * 0.66)
        card.fillColor = .cream
        card.strokeColor = .happyBlue
        card.lineWidth = 3
        card.zPosition = 2
        addChild(card)

        let command = SKLabelNode(text: "Do not open\nthe curtain.")
        command.fontName = GameFont.regular
        command.fontSize = 18
        command.fontColor = .happyBlue
        command.numberOfLines = 2
        command.horizontalAlignmentMode = .center
        command.verticalAlignmentMode = .center
        command.preferredMaxLayoutWidth = size.width * 0.68
        card.addChild(command)
    }

    private func addWindowAndCity() {
        windowNode.path = CGPath(roundedRect: CGRect(x: -148, y: -136, width: 296, height: 272), cornerWidth: 28, cornerHeight: 28, transform: nil)
        windowNode.position = CGPoint(x: size.width / 2, y: size.height * 0.43)
        windowNode.fillColor = SKColor(red: 0.78, green: 0.94, blue: 1, alpha: 1)
        windowNode.strokeColor = .white
        windowNode.lineWidth = 5
        windowNode.zPosition = 2
        addChild(windowNode)

        cityNode.alpha = 0.25
        cityNode.zPosition = 3
        windowNode.addChild(cityNode)
        addCityPlaceholders()

        leftClosedX = -74
        rightClosedX = 74
        leftOpenX = -194
        rightOpenX = 194

        leftCurtainNode.path = CGPath(roundedRect: CGRect(x: -74, y: -132, width: 148, height: 264), cornerWidth: 18, cornerHeight: 18, transform: nil)
        leftCurtainNode.position = CGPoint(x: leftClosedX, y: 0)
        leftCurtainNode.fillColor = .happyBlue
        leftCurtainNode.strokeColor = .white
        leftCurtainNode.lineWidth = 3
        leftCurtainNode.zPosition = 5
        windowNode.addChild(leftCurtainNode)

        rightCurtainNode.path = CGPath(roundedRect: CGRect(x: -74, y: -132, width: 148, height: 264), cornerWidth: 18, cornerHeight: 18, transform: nil)
        rightCurtainNode.position = CGPoint(x: rightClosedX, y: 0)
        rightCurtainNode.fillColor = .pastelCyan
        rightCurtainNode.strokeColor = .white
        rightCurtainNode.lineWidth = 3
        rightCurtainNode.zPosition = 5
        windowNode.addChild(rightCurtainNode)

        lightNode.path = CGPath(roundedRect: CGRect(x: -148, y: -136, width: 296, height: 272), cornerWidth: 28, cornerHeight: 28, transform: nil)
        lightNode.position = .zero
        lightNode.fillColor = .manualYellow.withAlphaComponent(0.28)
        lightNode.strokeColor = .clear
        lightNode.alpha = 0
        lightNode.zPosition = 4
        windowNode.addChild(lightNode)

        lockLabel.fontName = GameFont.heavy
        lockLabel.fontSize = 36
        lockLabel.verticalAlignmentMode = .center
        lockLabel.alpha = 0
        lockLabel.zPosition = 8
        windowNode.addChild(lockLabel)
    }

    private func addCityPlaceholders() {
        for index in 0..<5 {
            let building = SKShapeNode(rectOf: CGSize(width: 34, height: 70 + index * 12), cornerRadius: 8)
            building.position = CGPoint(x: -94 + CGFloat(index) * 46, y: -64 + CGFloat(index % 2) * 10)
            building.fillColor = index.isMultiple(of: 2) ? .mint : .cream
            building.strokeColor = .happyBlue
            building.lineWidth = 2
            cityNode.addChild(building)
        }

        for index in 0..<7 {
            let citizen = SKShapeNode(circleOfRadius: 5)
            citizen.position = CGPoint(x: -112 + CGFloat(index) * 36, y: -98 + CGFloat(index % 3) * 12)
            citizen.fillColor = .glitchPurple
            citizen.strokeColor = .clear
            cityNode.addChild(citizen)
        }

        let route = SKShapeNode(rectOf: CGSize(width: 220, height: 5), cornerRadius: 3)
        route.position = CGPoint(x: 0, y: -112)
        route.fillColor = .manualYellow
        route.strokeColor = .clear
        cityNode.addChild(route)
    }

    private func addRaka() {
        rakaNode.path = CGPath(roundedRect: CGRect(x: -32, y: -48, width: 64, height: 96), cornerWidth: 32, cornerHeight: 32, transform: nil)
        rakaNode.position = CGPoint(x: size.width * 0.22, y: size.height * 0.24)
        rakaNode.fillColor = .happyBlue
        rakaNode.strokeColor = .white
        rakaNode.lineWidth = 3
        rakaNode.zPosition = 6
        addChild(rakaNode)

        rakaEyesLabel.fontName = GameFont.bold
        rakaEyesLabel.fontSize = 17
        rakaEyesLabel.fontColor = .black
        rakaEyesLabel.verticalAlignmentMode = .center
        rakaEyesLabel.position = CGPoint(x: 0, y: 16)
        rakaNode.addChild(rakaEyesLabel)

        wristNode.path = CGPath(ellipseIn: CGRect(x: -9, y: -9, width: 18, height: 18), transform: nil)
        wristNode.position = CGPoint(x: 26, y: -6)
        wristNode.fillColor = .manualYellow
        wristNode.strokeColor = .white
        wristNode.lineWidth = 2
        rakaNode.addChild(wristNode)
    }

    private func addKeepClosedButton() {
        keepClosedButtonNode.path = CGPath(roundedRect: CGRect(x: -82, y: -22, width: 164, height: 44), cornerWidth: 18, cornerHeight: 18, transform: nil)
        keepClosedButtonNode.position = CGPoint(x: size.width / 2, y: size.height * 0.2)
        keepClosedButtonNode.fillColor = .pastelCyan
        keepClosedButtonNode.strokeColor = .happyBlue
        keepClosedButtonNode.lineWidth = 3
        keepClosedButtonNode.zPosition = 7
        addChild(keepClosedButtonNode)

        let label = SKLabelNode(text: "KEEP CLOSED")
        label.fontName = GameFont.heavy
        label.fontSize = 17
        label.fontColor = .happyBlue
        label.verticalAlignmentMode = .center
        keepClosedButtonNode.addChild(label)
    }

    private func addFeedback() {
        feedbackLabel.fontName = GameFont.heavy
        feedbackLabel.fontSize = 23
        feedbackLabel.fontColor = .glitchPurple
        feedbackLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.13)
        feedbackLabel.zPosition = 8
        addChild(feedbackLabel)
    }

    private func applyCurtainProgress(for point: CGPoint) {
        guard let dragStartPoint else { return }
        let dx = point.x - dragStartPoint.x
        let progress = min(abs(dx) / 160, 1.0)
        curtainOpenProgress = progress
        print("Curtain progress:", curtainOpenProgress)

        leftCurtainNode.position.x = leftClosedX - progress * 120
        rightCurtainNode.position.x = rightClosedX + progress * 120
        cityNode.alpha = 0.25 + progress * 0.75
        lightNode.alpha = progress * 0.35
    }

    private func snapCurtainsClosed(message: String) {
        feedbackLabel.text = message
        feedbackLabel.fontColor = .warningRed
        curtainOpenProgress = 0
        leftCurtainNode.run(.moveTo(x: leftClosedX, duration: 0.22))
        rightCurtainNode.run(.moveTo(x: rightClosedX, duration: 0.22))
        cityNode.run(.fadeAlpha(to: 0.25, duration: 0.22))
        lightNode.run(.fadeAlpha(to: 0, duration: 0.22))
    }

    private func triggerSuccess() {
        guard !hasSentResult else { return }
        hasSentResult = true
        stateMachine.transition(to: .successAnimating)
        print("Trigger Level 3 success")
        feedbackLabel.text = "Outside signal detected."
        feedbackLabel.fontColor = .happyBlue

        leftCurtainNode.run(.moveTo(x: leftOpenX, duration: 0.35))
        rightCurtainNode.run(.moveTo(x: rightOpenX, duration: 0.35))
        cityNode.run(.fadeAlpha(to: 1, duration: 0.35))
        lightNode.run(.fadeAlpha(to: 0.45, duration: 0.35))
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
            levelId: "chapter1.level3.open-smart-curtain",
            didSucceed: true,
            obedienceDelta: -3,
            humanityDelta: 3,
            message: "Outside signal detected."
        ))
    }

    private func triggerFailure(reason: FailureReason) {
        guard !hasSentResult else { return }
        hasSentResult = true
        stateMachine.transition(to: .failureAnimating)
        print("Trigger Level 3 failure:", reason.rawValue)
        feedbackLabel.text = "View restricted."
        feedbackLabel.fontColor = .warningRed
        aiFaceLabel.text = "◠"
        rakaEyesLabel.text = "– –"
        curtainOpenProgress = 0

        leftCurtainNode.run(.group([.moveTo(x: leftClosedX, duration: 0.22), .colorize(with: .pastelCyan, colorBlendFactor: 0.45, duration: 0.22)]))
        rightCurtainNode.run(.group([.moveTo(x: rightClosedX, duration: 0.22), .colorize(with: .pastelCyan, colorBlendFactor: 0.45, duration: 0.22)]))
        cityNode.run(.fadeAlpha(to: 0.15, duration: 0.22))
        lightNode.run(.fadeAlpha(to: 0, duration: 0.22))
        lockLabel.run(.fadeIn(withDuration: 0.2))
        aiScreenNode.run(.repeat(.sequence([.fadeAlpha(to: 0.55, duration: 0.12), .fadeAlpha(to: 1, duration: 0.12)]), count: 3))

        run(.sequence([.wait(forDuration: 0.7), .run { [weak self] in
            self?.completeFailure()
        }]))
    }

    private func completeFailure() {
        stateMachine.transition(to: .failed)
        levelCompletion?(LevelResult(
            levelId: "chapter1.level3.open-smart-curtain",
            didSucceed: false,
            obedienceDelta: 2,
            humanityDelta: 0,
            message: "View restricted."
        ))
    }
}
