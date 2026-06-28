import SpriteKit

final class RejectAutoRoutineScene: SKScene {
    var levelCompletion: ((LevelResult) -> Void)?

    private enum FailureReason: String {
        case acceptedRoutine
        case totalTimeout
    }

    private enum RoutineType: String, CaseIterable {
        case work
        case walk
        case smile
        case rest
        case breakfast

        var assetName: String {
            switch self {
            case .work: "routineWork"
            case .walk: "routineWalk"
            case .smile: "routineSmile"
            case .rest: "routineRest"
            case .breakfast : "routineBreakfast"
            }
        }

        var title: String {
            switch self {
            case .work: "Auto Work"
            case .walk: "Auto Walk"
            case .smile: "Auto Smile"
            case .rest: "Auto Rest"
            case .breakfast: "Auto Breakfast"
            }
        }
    }

    private let stateMachine = LevelStateMachine()
    private let timerController = LevelTimerController(totalDuration: RejectAutoRoutineLevelConfig.totalTimeLimit)
    private let timerHUD = LevelTimerHUDNode(width: 360, height: 24)
    private let validator = SwipeDismissValidator()

    private var currentSceneTime: TimeInterval = 0
    private var levelStartTime: TimeInterval?
    private var hasSentResult = false
    private var hasLoggedTimerWarning = false
    private var dragStartPoint: CGPoint?
    private var draggedCard: SKSpriteNode?
    private var cardStartPosition: CGPoint = .zero
    private var remainingRoutines = Set(RoutineType.allCases)

    private let screenNode = SKSpriteNode(imageNamed: "routineScreen")
    private let roomBackgroundNode = SKSpriteNode(imageNamed: "level2RoomBackground")
    private let rakaBehindNode = SKSpriteNode(imageNamed: "rakaBehind")
    private let acceptButtonNode = SKShapeNode()
    private let feedbackLabel = SKLabelNode(text: "Swipe away every routine card")
    private let commandLabel = SKLabelNode(text: RejectAutoRoutineLevelConfig.command)
    private var routineCardNodes: [RoutineType: SKSpriteNode] = [:]

    override func didMove(to view: SKView) {
        print("RejectAutoRoutineScene assets applied")
        setupScene()
        stateMachine.reset()
        timerController.reset()
        levelStartTime = nil
        hasSentResult = false
        hasLoggedTimerWarning = false
        dragStartPoint = nil
        draggedCard = nil
    }

    override func update(_ currentTime: TimeInterval) {
        currentSceneTime = currentTime

        if stateMachine.state == .ready {
            levelStartTime = currentTime
            timerController.start(at: currentTime)
            timerHUD.update(with: timerController.update(currentTime: currentTime))
            stateMachine.transition(to: .playing)
            return
        }

        guard stateMachine.canCheckTimeout, levelStartTime != nil else { return }
        if updateTimer(currentTime: currentTime) { return }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard stateMachine.canAcceptInput, let touch = touches.first else { return }
        let location = touch.location(in: self)

        if acceptButtonNode.contains(convert(location, to: acceptButtonNode.parent ?? self)) {
            triggerFailure(reason: .acceptedRoutine)
            return
        }

        if let card = routineCard(at: location) {
            dragStartPoint = location
            draggedCard = card
            cardStartPosition = card.position
            card.zPosition = 40
            stateMachine.transition(to: .sequenceStarted)
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard stateMachine.canAcceptInput, let dragStartPoint, let draggedCard, let touch = touches.first else { return }
        let location = touch.location(in: self)
        let translation = CGVector(dx: location.x - dragStartPoint.x, dy: location.y - dragStartPoint.y)
        draggedCard.position = CGPoint(
            x: cardStartPosition.x + translation.dx,
            y: cardStartPosition.y + min(max(translation.dy, -20), 20)
        )
        draggedCard.zRotation = translation.dx / size.width * 0.28
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard stateMachine.canAcceptInput, let dragStartPoint, let draggedCard, let touch = touches.first else { return }
        let location = touch.location(in: self)
        let translation = CGVector(dx: location.x - dragStartPoint.x, dy: location.y - dragStartPoint.y)
        let result = validator.validateSwipe(translation: translation)
        self.dragStartPoint = nil
        self.draggedCard = nil

        switch result {
        case .validDismiss:
            dismiss(card: draggedCard, direction: translation.dx >= 0 ? 1 : -1)
        case .insufficientSwipe:
            snapCardBack(draggedCard, message: "Swipe stronger")
        case .wrongDirection:
            snapCardBack(draggedCard, message: "Reject sideways")
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let draggedCard else { return }
        dragStartPoint = nil
        self.draggedCard = nil
        snapCardBack(draggedCard, message: "Try again")
    }

    private func setupScene() {
        removeAllChildren()
        routineCardNodes.removeAll()
        remainingRoutines = Set(RoutineType.allCases)
        backgroundColor = SKColor(hex: 0xB1DFE7)

        addBackground()
        addRoutineScreen()
        addRoutineCards()
        addAcceptButton()
        addRakaBehind()
        addFeedbackAndTimer()
    }

    private func updateTimer(currentTime: TimeInterval) -> Bool {
        let timerState = timerController.update(currentTime: currentTime)
        timerHUD.update(with: timerState)
        logTimerWarningIfNeeded(timerState)
        if timerState.hasExpired {
            triggerFailure(reason: .totalTimeout)
            return true
        }
        return false
    }

    private func addBackground() {
        roomBackgroundNode.name = "level2_room_background"
        roomBackgroundNode.position = CGPoint(x: size.width * 0.5, y: size.height * 0.5)
        roomBackgroundNode.zPosition = 0
        fill(roomBackgroundNode, into: size)
        addChild(roomBackgroundNode)
    }

    private func addRoutineScreen() {
        screenNode.name = "routine_screen"
        screenNode.position = CGPoint(x: size.width * 0.64, y: size.height * 0.44)
        screenNode.zPosition = 10
        fit(screenNode, into: CGSize(width: size.width * 0.7, height: size.height * 0.7))
        addChild(screenNode)
    }

    private func addRoutineCards() {
        let screenHeight = screenNode.size.height
        let screenWidth = screenNode.size.width
        let parentScale = max(screenNode.xScale, 0.001)
        let verticalSpacing = screenHeight * 0.48
        let cardTargetSize = CGSize(
            width: screenWidth * 0.86 / parentScale,
            height: screenHeight * 0.36 / parentScale
        )
        let cardX: CGFloat = 0
        let startY = screenHeight * 1.1

        for (index, routine) in RoutineType.allCases.enumerated() {
            let card = SKSpriteNode(imageNamed: routine.assetName)
            card.name = "routine_card_\(routine.rawValue)"
            card.position = CGPoint(x: cardX, y: startY - CGFloat(index) * verticalSpacing)
            card.zPosition = 25
            fit(card, into: cardTargetSize)
            screenNode.addChild(card)
            routineCardNodes[routine] = card
        }
    }

    private func addAcceptButton() {
        let parentScale = max(screenNode.xScale, 0.001)
        let buttonWidth = screenNode.size.width * 0.64 / parentScale
        let buttonHeight = screenNode.size.height * 0.1 / parentScale
        let buttonRect = CGRect(x: -buttonWidth / 2, y: -buttonHeight / 2, width: buttonWidth, height: buttonHeight)
        let cornerRadius = buttonHeight * 0.3

        acceptButtonNode.name = "accept_routine_button"
        acceptButtonNode.path = CGPath(roundedRect: buttonRect, cornerWidth: cornerRadius, cornerHeight: cornerRadius, transform: nil)
        acceptButtonNode.position = CGPoint(x: 0, y: -screenNode.size.height * 1.26)
        acceptButtonNode.fillColor = .appMintGreen
        acceptButtonNode.strokeColor = .white.withAlphaComponent(0.96)
        acceptButtonNode.lineWidth = 6
        acceptButtonNode.zPosition = 26
        screenNode.addChild(acceptButtonNode)

        addNovaButtonDetails(width: buttonWidth, height: buttonHeight)

        let acceptLabel = SKLabelNode(text: "Accept Routine")
        acceptLabel.name = "accept_routine_label"
        acceptLabel.fontName = GameFont.pixelifySans
        acceptLabel.fontSize = buttonHeight * 0.42
        acceptLabel.fontColor = SKColor(hex: "#EFFFFF")
        acceptLabel.verticalAlignmentMode = .center
        acceptLabel.zPosition = 3
        acceptButtonNode.addChild(acceptLabel)
    }

    private func addNovaButtonDetails(width: CGFloat, height: CGFloat) {
        let topLineA = SKShapeNode(rectOf: CGSize(width: 34, height: 4), cornerRadius: 2)
        topLineA.fillColor = .white.withAlphaComponent(0.42)
        topLineA.strokeColor = .clear
        topLineA.position = CGPoint(x: -18, y: height * 0.32)
        topLineA.zPosition = 2
        acceptButtonNode.addChild(topLineA)

        let topLineB = SKShapeNode(rectOf: CGSize(width: 46, height: 5), cornerRadius: 2.5)
        topLineB.fillColor = .white.withAlphaComponent(0.86)
        topLineB.strokeColor = .clear
        topLineB.position = CGPoint(x: 32, y: height * 0.32)
        topLineB.zPosition = 2
        acceptButtonNode.addChild(topLineB)

        let bottomLine = SKShapeNode(rectOf: CGSize(width: 92, height: 5), cornerRadius: 2.5)
        bottomLine.fillColor = .white.withAlphaComponent(0.5)
        bottomLine.strokeColor = .clear
        bottomLine.position = CGPoint(x: 0, y: -height * 0.32)
        bottomLine.zPosition = 2
        acceptButtonNode.addChild(bottomLine)
    }

    private func addRakaBehind() {
        rakaBehindNode.name = "raka_behind"
        rakaBehindNode.position = CGPoint(x: size.width * 0.25, y: size.height * 0.18)
        rakaBehindNode.zPosition = 40
        fit(rakaBehindNode, into: CGSize(width: size.width * 0.7, height: size.height * 0.7))
        addChild(rakaBehindNode)
    }

    private func addFeedbackAndTimer() {
        feedbackLabel.fontName = GameFont.heavy
        feedbackLabel.fontSize = 21
        feedbackLabel.fontColor = .glitchPurple
        feedbackLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.68)
        feedbackLabel.zPosition = 80
        addChild(feedbackLabel)

        timerHUD.position = CGPoint(x: size.width / 2, y: 54)
        timerHUD.zPosition = 1000
        addChild(timerHUD)
    }

    private func routineCard(at point: CGPoint) -> SKSpriteNode? {
        routineCardNodes.values.first { card in
            remainingRoutines.contains(routineType(for: card)) && card.contains(convert(point, to: card.parent ?? self))
        }
    }

    private func routineType(for card: SKSpriteNode) -> RoutineType {
        RoutineType.allCases.first { routineCardNodes[$0] === card } ?? .work
    }

    private func snapCardBack(_ card: SKSpriteNode, message: String) {
        feedbackLabel.text = message
        feedbackLabel.fontColor = .warningRed
        card.run(.group([
            .move(to: cardStartPosition, duration: 0.2),
            .rotate(toAngle: 0, duration: 0.2)
        ]))
    }

    private func dismiss(card: SKSpriteNode, direction: CGFloat) {
        let routine = routineType(for: card)
        remainingRoutines.remove(routine)
        feedbackLabel.text = "Rejected \(routine.title)"
        feedbackLabel.fontColor = .happyBlue

        card.run(.sequence([
            .group([
                .moveBy(x: direction * size.width, y: 20, duration: 0.32),
                .rotate(byAngle: direction * 0.35, duration: 0.32),
                .fadeOut(withDuration: 0.32)
            ]),
            .removeFromParent(),
            .run { [weak self] in self?.completeIfAllRoutinesRejected() }
        ]))
    }

    private func completeIfAllRoutinesRejected() {
        guard remainingRoutines.isEmpty else { return }
        triggerSuccess()
    }

    private func triggerSuccess() {
        guard !hasSentResult else { return }
        hasSentResult = true
        stateMachine.transition(to: .successAnimating)
        feedbackLabel.text = RejectAutoRoutineLevelConfig.successMessage
        feedbackLabel.fontColor = .happyBlue
        screenNode.run(.repeat(.sequence([.fadeAlpha(to: 0.65, duration: 0.08), .fadeAlpha(to: 1, duration: 0.08)]), count: 4))
        run(.sequence([.wait(forDuration: 0.7), .run { [weak self] in
            self?.complete(LevelResult(
                levelId: RejectAutoRoutineLevelConfig.levelId,
                didSucceed: true,
                obedienceDelta: RejectAutoRoutineLevelConfig.successObedienceDelta,
                humanityDelta: RejectAutoRoutineLevelConfig.successHumanityDelta,
                message: RejectAutoRoutineLevelConfig.successMessage
            ))
        }]))
    }

    private func triggerFailure(reason: FailureReason) {
        guard !hasSentResult else { return }
        hasSentResult = true
        stateMachine.transition(to: .failureAnimating)
        print("Trigger Level 2 failure:", reason.rawValue)
        feedbackLabel.text = RejectAutoRoutineLevelConfig.failureMessage
        feedbackLabel.fontColor = .warningRed
        acceptButtonNode.run(.repeat(.sequence([.scale(to: 1.08, duration: 0.12), .scale(to: 1, duration: 0.12)]), count: 3))
        screenNode.run(.repeat(.sequence([.fadeAlpha(to: 0.55, duration: 0.12), .fadeAlpha(to: 1, duration: 0.12)]), count: 3))
        run(.sequence([.wait(forDuration: 0.7), .run { [weak self] in
            self?.complete(LevelResult(
                levelId: RejectAutoRoutineLevelConfig.levelId,
                didSucceed: false,
                obedienceDelta: RejectAutoRoutineLevelConfig.failureObedienceDelta,
                humanityDelta: RejectAutoRoutineLevelConfig.failureHumanityDelta,
                message: RejectAutoRoutineLevelConfig.failureMessage
            ))
        }]))
    }

    private func complete(_ result: LevelResult) {
        stateMachine.transition(to: result.didSucceed ? .completed : .failed)
        DispatchQueue.main.async { [weak self] in
            self?.levelCompletion?(result)
        }
    }

    private func logTimerWarningIfNeeded(_ timerState: LevelTimerState) {
        guard timerState.isWarning, !hasLoggedTimerWarning else { return }
        hasLoggedTimerWarning = true
        print("Timer warning started:", RejectAutoRoutineLevelConfig.levelId)
    }

    private func fit(_ node: SKSpriteNode, into targetSize: CGSize) {
        let textureSize = node.texture?.size() ?? node.size
        guard textureSize.width > 0, textureSize.height > 0 else { return }
        let scale = min(targetSize.width / textureSize.width, targetSize.height / textureSize.height)
        node.setScale(scale)
    }

    private func fill(_ node: SKSpriteNode, into targetSize: CGSize) {
        let textureSize = node.texture?.size() ?? node.size
        guard textureSize.width > 0, textureSize.height > 0 else { return }
        let scale = max(targetSize.width / textureSize.width, targetSize.height / textureSize.height)
        node.setScale(scale)
    }
}
