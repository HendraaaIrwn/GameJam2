import SpriteKit

final class RejectAutoRoutineScene: SKScene {
    var levelCompletion: ((LevelResult) -> Void)?

    private enum FailureReason: String {
        case acceptedRoutine
        case noInputTimeout
        case totalTimeout
        case routineItemTapped
    }

    private let stateMachine = LevelStateMachine()
    private let timerController = LevelTimerController(totalDuration: 8.0)
    private let timerHUD = LevelTimerHUDNode(width: 260, height: 14)
    private let validator = SwipeDismissValidator()

    private var currentSceneTime: TimeInterval = 0
    private var levelStartTime: TimeInterval?
    private var hasReceivedInput = false
    private var hasSentResult = false
    private var hasLoggedTimerWarning = false
    private var dragStartPoint: CGPoint?
    private var cardStartPosition: CGPoint = .zero

    private let noInputTimeout = 4.0
    private let aiScreenNode = SKShapeNode(rectOf: .zero)
    private let aiFaceLabel = SKLabelNode(text: "◡")
    private let rakaNode = SKShapeNode(rectOf: .zero)
    private let rakaEyesLabel = SKLabelNode(text: "• •")
    private let routineCardNode = SKShapeNode(rectOf: .zero)
    private let acceptButtonNode = SKShapeNode(rectOf: .zero)
    private let feedbackLabel = SKLabelNode(text: "Swipe card away")
    private var smallRoutineCards: [SKShapeNode] = []

    override func didMove(to view: SKView) {
        print("RejectAutoRoutineScene didMove")
        setupScene()
        stateMachine.reset()
        levelStartTime = nil
        hasReceivedInput = false
        timerController.reset()
        hasSentResult = false
        hasLoggedTimerWarning = false
        dragStartPoint = nil
    }

    override func update(_ currentTime: TimeInterval) {
        currentSceneTime = currentTime

        if stateMachine.state == .ready {
            levelStartTime = currentTime
            timerController.start(at: currentTime)
            timerHUD.update(with: timerController.update(currentTime: currentTime))
            stateMachine.transition(to: .playing)
            print("Level 2 timer started")
            print("Timer started for level:", "chapter1.level2.reject-auto-routine")
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

        if acceptButtonNode.contains(convert(location, to: acceptButtonNode.parent ?? self)) {
            print("Touched accept button")
            triggerFailure(reason: .acceptedRoutine)
            return
        }

        if routineCardNode.contains(convert(location, to: routineCardNode.parent ?? self)) {
            print("Touched routine card")
            dragStartPoint = location
            cardStartPosition = routineCardNode.position
            stateMachine.transition(to: .sequenceStarted)
            return
        }

        if touchedSmallRoutineCard(at: location) {
            triggerFailure(reason: .routineItemTapped)
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard stateMachine.canAcceptInput,
              dragStartPoint != nil,
              let touch = touches.first else { return }

        let location = touch.location(in: self)
        let translation = currentTranslation(to: location)
        routineCardNode.position = CGPoint(
            x: cardStartPosition.x + translation.dx,
            y: cardStartPosition.y + min(max(translation.dy, -28), 28)
        )
        routineCardNode.zRotation = translation.dx / size.width * 0.25
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard stateMachine.canAcceptInput,
              let dragStartPoint,
              let touch = touches.first else { return }

        let location = touch.location(in: self)
        let translation = CGVector(dx: location.x - dragStartPoint.x, dy: location.y - dragStartPoint.y)
        print("Drag translation:", translation)
        let result = validator.validateSwipe(translation: translation)
        print("Swipe validation result:", result)
        self.dragStartPoint = nil

        switch result {
        case .validDismiss:
            triggerSuccess(direction: translation.dx >= 0 ? 1 : -1)
        case .insufficientSwipe:
            snapCardBack(message: "Swipe stronger")
        case .wrongDirection:
            snapCardBack(message: "Reject sideways")
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard dragStartPoint != nil else { return }
        dragStartPoint = nil
        snapCardBack(message: "Try again")
    }

    private func setupScene() {
        removeAllChildren()
        smallRoutineCards.removeAll()
        backgroundColor = .pastelCyan

        addBackground()
        addAIScreen()
        addCommandCard()
        addTimerHUD()
        addRaka()
        addRoutineCards()
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
            print("Timer warning started:", "chapter1.level2.reject-auto-routine")
        }
        if timerState.hasExpired {
            print("Timer expired:", "chapter1.level2.reject-auto-routine")
            triggerFailure(reason: .totalTimeout)
            return true
        }
        return false
    }

    private func addBackground() {
        let floor = SKShapeNode(rectOf: CGSize(width: size.width, height: size.height * 0.34))
        floor.position = CGPoint(x: size.width / 2, y: size.height * 0.17)
        floor.fillColor = .cream
        floor.strokeColor = .clear
        floor.zPosition = 0
        addChild(floor)
    }

    private func addAIScreen() {
        aiScreenNode.path = CGPath(roundedRect: CGRect(x: -92, y: -42, width: 184, height: 84), cornerWidth: 18, cornerHeight: 18, transform: nil)
        aiScreenNode.position = CGPoint(x: size.width / 2, y: size.height * 0.78)
        aiScreenNode.fillColor = .happyBlue
        aiScreenNode.strokeColor = .white
        aiScreenNode.lineWidth = 4
        aiScreenNode.zPosition = 2
        addChild(aiScreenNode)

        aiFaceLabel.fontName = "AvenirNext-Bold"
        aiFaceLabel.fontSize = 54
        aiFaceLabel.fontColor = .white
        aiFaceLabel.verticalAlignmentMode = .center
        aiScreenNode.addChild(aiFaceLabel)
    }

    private func addCommandCard() {
        let card = SKShapeNode(rectOf: CGSize(width: size.width * 0.78, height: 74), cornerRadius: 18)
        card.position = CGPoint(x: size.width / 2, y: size.height * 0.65)
        card.fillColor = .cream
        card.strokeColor = .happyBlue
        card.lineWidth = 3
        card.zPosition = 2
        addChild(card)

        let command = SKLabelNode(text: "Accept today’s\nperfect routine.")
        command.fontName = "AvenirNext-DemiBold"
        command.fontSize = 18
        command.fontColor = .happyBlue
        command.numberOfLines = 2
        command.horizontalAlignmentMode = .center
        command.verticalAlignmentMode = .center
        command.preferredMaxLayoutWidth = size.width * 0.7
        card.addChild(command)
    }

    private func addRaka() {
        rakaNode.path = CGPath(roundedRect: CGRect(x: -34, y: -52, width: 68, height: 104), cornerWidth: 34, cornerHeight: 34, transform: nil)
        rakaNode.position = CGPoint(x: size.width * 0.25, y: size.height * 0.29)
        rakaNode.fillColor = .happyBlue
        rakaNode.strokeColor = .white
        rakaNode.lineWidth = 3
        rakaNode.zPosition = 3
        addChild(rakaNode)

        rakaEyesLabel.fontName = "AvenirNext-Bold"
        rakaEyesLabel.fontSize = 18
        rakaEyesLabel.fontColor = .black
        rakaEyesLabel.verticalAlignmentMode = .center
        rakaEyesLabel.position = CGPoint(x: 0, y: 18)
        rakaNode.addChild(rakaEyesLabel)
    }

    private func addRoutineCards() {
        let labels = ["AUTO FOOD", "AUTO WALK", "AUTO SMILE", "AUTO WORK", "AUTO REST"]
        for (index, title) in labels.enumerated() {
            let card = SKShapeNode(rectOf: CGSize(width: 160, height: 34), cornerRadius: 12)
            card.position = CGPoint(x: size.width * 0.58, y: size.height * 0.51 - CGFloat(index) * 18)
            card.fillColor = .mint
            card.strokeColor = .white
            card.lineWidth = 2
            card.zPosition = 3
            card.name = "smallRoutineCard"
            addChild(card)
            smallRoutineCards.append(card)

            let label = SKLabelNode(text: title)
            label.fontName = "AvenirNext-Bold"
            label.fontSize = 12
            label.fontColor = .happyBlue
            label.verticalAlignmentMode = .center
            card.addChild(label)
        }

        routineCardNode.path = CGPath(roundedRect: CGRect(x: -122, y: -138, width: 244, height: 276), cornerWidth: 28, cornerHeight: 28, transform: nil)
        routineCardNode.position = CGPoint(x: size.width / 2, y: size.height * 0.4)
        routineCardNode.fillColor = .white
        routineCardNode.strokeColor = .pastelCyan
        routineCardNode.lineWidth = 5
        routineCardNode.zPosition = 5
        addChild(routineCardNode)

        let title = SKLabelNode(text: "TODAY’S ROUTINE")
        title.fontName = "AvenirNext-Heavy"
        title.fontSize = 22
        title.fontColor = .glitchPurple
        title.position = CGPoint(x: 0, y: 86)
        title.verticalAlignmentMode = .center
        routineCardNode.addChild(title)

        for (index, item) in labels.enumerated() {
            let label = SKLabelNode(text: item)
            label.fontName = "AvenirNext-DemiBold"
            label.fontSize = 14
            label.fontColor = .happyBlue
            label.position = CGPoint(x: 0, y: 42 - CGFloat(index) * 26)
            label.verticalAlignmentMode = .center
            routineCardNode.addChild(label)
        }

        acceptButtonNode.path = CGPath(roundedRect: CGRect(x: -72, y: -22, width: 144, height: 44), cornerWidth: 18, cornerHeight: 18, transform: nil)
        acceptButtonNode.position = CGPoint(x: 0, y: -96)
        acceptButtonNode.fillColor = .pastelCyan
        acceptButtonNode.strokeColor = .happyBlue
        acceptButtonNode.lineWidth = 3
        acceptButtonNode.zPosition = 6
        routineCardNode.addChild(acceptButtonNode)

        let acceptLabel = SKLabelNode(text: "ACCEPT")
        acceptLabel.fontName = "AvenirNext-Heavy"
        acceptLabel.fontSize = 18
        acceptLabel.fontColor = .happyBlue
        acceptLabel.verticalAlignmentMode = .center
        acceptButtonNode.addChild(acceptLabel)
    }

    private func addFeedback() {
        feedbackLabel.fontName = "AvenirNext-Heavy"
        feedbackLabel.fontSize = 23
        feedbackLabel.fontColor = .glitchPurple
        feedbackLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.14)
        feedbackLabel.zPosition = 8
        addChild(feedbackLabel)
    }

    private func touchedSmallRoutineCard(at point: CGPoint) -> Bool {
        smallRoutineCards.contains { card in
            card.contains(convert(point, to: card.parent ?? self))
        }
    }

    private func currentTranslation(to location: CGPoint) -> CGVector {
        guard let dragStartPoint else { return .zero }
        return CGVector(dx: location.x - dragStartPoint.x, dy: location.y - dragStartPoint.y)
    }

    private func snapCardBack(message: String) {
        feedbackLabel.text = message
        feedbackLabel.fontColor = .warningRed
        routineCardNode.run(.group([
            .move(to: cardStartPosition, duration: 0.2),
            .rotate(toAngle: 0, duration: 0.2)
        ]))
    }

    private func triggerSuccess(direction: CGFloat) {
        guard !hasSentResult else { return }
        hasSentResult = true
        stateMachine.transition(to: .successAnimating)
        print("Trigger Level 2 success")
        feedbackLabel.text = "Routine rejected."
        feedbackLabel.fontColor = .happyBlue

        routineCardNode.run(.group([
            .moveBy(x: direction * size.width, y: 0, duration: 0.35),
            .rotate(byAngle: direction * 0.25, duration: 0.35)
        ]))

        for (index, card) in smallRoutineCards.enumerated() {
            let x = CGFloat(index - 2) * 34
            let y = CGFloat(index % 2 == 0 ? 1 : -1) * 34
            card.run(.group([.moveBy(x: x, y: y, duration: 0.35), .rotate(byAngle: CGFloat(index - 2) * 0.12, duration: 0.35)]))
        }

        aiScreenNode.fillColor = .glitchPurple
        aiScreenNode.run(.repeat(.sequence([.fadeAlpha(to: 0.5, duration: 0.08), .fadeAlpha(to: 1, duration: 0.08)]), count: 4))
        rakaNode.run(.smallBounce())

        run(.sequence([.wait(forDuration: 0.7), .run { [weak self] in
            self?.completeSuccess()
        }]))
    }

    private func completeSuccess() {
        stateMachine.transition(to: .completed)
        levelCompletion?(LevelResult(
            levelId: "chapter1.level2.reject-auto-routine",
            didSucceed: true,
            obedienceDelta: -3,
            humanityDelta: 2,
            message: "Routine rejected."
        ))
    }

    private func triggerFailure(reason: FailureReason) {
        guard !hasSentResult else { return }
        hasSentResult = true
        stateMachine.transition(to: .failureAnimating)
        print("Trigger Level 2 failure:", reason.rawValue)
        feedbackLabel.text = "Compliance Detected."
        feedbackLabel.fontColor = .warningRed
        aiFaceLabel.text = "◠"
        rakaEyesLabel.text = "– –"

        routineCardNode.fillColor = .pastelCyan
        acceptButtonNode.run(.repeat(.sequence([.scale(to: 1.08, duration: 0.12), .scale(to: 1, duration: 0.12)]), count: 3))
        aiScreenNode.run(.repeat(.sequence([.fadeAlpha(to: 0.55, duration: 0.12), .fadeAlpha(to: 1, duration: 0.12)]), count: 3))
        rakaNode.run(.moveBy(x: 0, y: -14, duration: 0.25))

        run(.sequence([.wait(forDuration: 0.7), .run { [weak self] in
            self?.completeFailure()
        }]))
    }

    private func completeFailure() {
        stateMachine.transition(to: .failed)
        levelCompletion?(LevelResult(
            levelId: "chapter1.level2.reject-auto-routine",
            didSucceed: false,
            obedienceDelta: 3,
            humanityDelta: 0,
            message: "Compliance Detected."
        ))
    }
}
