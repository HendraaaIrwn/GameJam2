import SpriteKit

final class FindOldTransitSwitchScene: SKScene {
    var levelCompletion: ((LevelResult) -> Void)?

    private let stateMachine = LevelStateMachine()
    private let timerController = LevelTimerController(totalDuration: 12)
    private let validator = TransitSwitchSearchValidator()
    private let timerHUD = LevelTimerHUDNode(width: 260, height: 14)

    private let aiWallScreenNode = SKShapeNode(rectOf: CGSize(width: 184, height: 78), cornerRadius: 18)
    private let aiFaceLabel = SKLabelNode(text: "🙂")
    private let oldTransitDoorNode = SKShapeNode(rectOf: CGSize(width: 120, height: 190), cornerRadius: 18)
    private let aiPanelNode = SKShapeNode(rectOf: CGSize(width: 250, height: 210), cornerRadius: 24)
    private let highlightedBlueButtonNode = SKShapeNode(rectOf: CGSize(width: 176, height: 46), cornerRadius: 18)
    private let bluePanelButtonNode = SKShapeNode(rectOf: CGSize(width: 96, height: 38), cornerRadius: 14)
    private let fakeSwitchNode = SKShapeNode(rectOf: CGSize(width: 70, height: 36), cornerRadius: 10)
    private let autoTransitButtonNode = SKShapeNode(rectOf: CGSize(width: 138, height: 42), cornerRadius: 16)
    private let approvedRouteButtonNode = SKShapeNode(rectOf: CGSize(width: 158, height: 42), cornerRadius: 16)
    private let manualSwitchNode = SKShapeNode(rectOf: CGSize(width: 42, height: 32), cornerRadius: 8)
    private let scannerNode = SKShapeNode(circleOfRadius: 42)
    private let rakaNode = SKShapeNode(circleOfRadius: 20)
    private let novaNode = SKShapeNode(circleOfRadius: 12)
    private let feedbackLabel = SKLabelNode(text: "Search behind the clean interface.")

    private var currentSceneTime: TimeInterval = 0
    private var isDraggingScanner = false
    private var hasSentResult = false
    private var isManualSwitchRevealed = false
    private var manualSwitchCenter: CGPoint { manualSwitchNode.position }

    override func didMove(to view: SKView) {
        print("FindOldTransitSwitchScene didMove")
        backgroundColor = .pastelCyan
        addBackground()
        addAIScreen()
        addCommandCard()
        addTransitDoorAndPanel()
        addButtonsAndSwitches()
        addScanner()
        addCharacters()
        addFeedback()
        addTimerHUD()
    }

    override func update(_ currentTime: TimeInterval) {
        currentSceneTime = currentTime
        if stateMachine.state == .ready {
            validator.startLevel(at: currentTime)
            timerController.start(at: currentTime)
            stateMachine.transition(to: .playing)
            print("Chapter 2 Level 7 timer started")
            return
        }

        guard stateMachine.canCheckTimeout else { return }
        let timerState = timerController.update(currentTime: currentTime)
        timerHUD.update(with: timerState)
        if timerState.hasExpired {
            triggerFailure(message: "Compliance Detected.", reason: "totalTimeout")
            return
        }
        if let timeoutResult = validator.checkTimeouts(currentTime: currentTime) {
            handleTransitSwitchResult(timeoutResult)
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard stateMachine.canAcceptInput, let point = touches.first?.location(in: self) else { return }
        let target = transitSwitchTarget(at: point)
        print("Tapped target:", target)
        if scannerNode.contains(point) || target == .empty || target == .oldTransitDoor {
            isDraggingScanner = scannerNode.contains(point) || target == .empty
        }
        if let result = validator.validateTap(target: target, isSwitchRevealed: isManualSwitchRevealed, time: currentSceneTime) {
            handleTransitSwitchResult(result)
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard stateMachine.canAcceptInput, isDraggingScanner, let point = touches.first?.location(in: self) else { return }
        scannerNode.position = point
        print("Scanner position:", scannerNode.position)
        let distance = scannerNode.position.distance(to: manualSwitchCenter)
        print("Distance to manual switch:", distance)
        handleTransitSwitchResult(validator.updateScanner(scannerCenter: scannerNode.position, switchCenter: manualSwitchCenter, time: currentSceneTime))
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isDraggingScanner = false
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        isDraggingScanner = false
    }

    private func handleTransitSwitchResult(_ result: TransitSwitchSearchValidationResult) {
        print("Transit switch validation result:", result)
        switch result {
        case .scannerMoved:
            break
        case .manualSwitchRevealed:
            revealManualSwitch()
        case .correctSwitchSelected:
            triggerSuccess()
        case .hiddenSwitchTappedBeforeReveal:
            feedbackLabel.text = "Something is hidden here."
        case let .wrongTargetSelected(target):
            triggerFailure(message: "Highlighted option accepted.", reason: target.rawValue)
        case .noInputTimeout, .totalTimeout:
            triggerFailure(message: "Compliance Detected.", reason: "timeout")
        }
    }

    private func revealManualSwitch() {
        guard !isManualSwitchRevealed else { return }
        isManualSwitchRevealed = true
        print("Manual switch revealed")
        feedbackLabel.text = "Manual switch revealed. Tap it."
        manualSwitchNode.name = "revealed_manual_switch"
        manualSwitchNode.alpha = 1
        manualSwitchNode.glowWidth = 12
    }

    private func triggerSuccess() {
        guard !hasSentResult, stateMachine.transition(to: .successAnimating) else { return }
        hasSentResult = true
        print("Trigger Chapter 2 Level 7 success")
        feedbackLabel.text = "Old transit switch found."
        manualSwitchNode.zRotation = -0.6
        oldTransitDoorNode.strokeColor = .manualYellow
        oldTransitDoorNode.glowWidth = 14
        [highlightedBlueButtonNode, bluePanelButtonNode, autoTransitButtonNode, approvedRouteButtonNode].forEach { $0.run(.fadeAlpha(to: 0.25, duration: 0.25)) }
        novaNode.run(.repeat(.sequence([.colorize(with: .manualYellow, colorBlendFactor: 1, duration: 0.08), .colorize(with: .happyBlue, colorBlendFactor: 1, duration: 0.08)]), count: 4))
        aiWallScreenNode.run(.sequence([.colorize(with: .warningRed, colorBlendFactor: 1, duration: 0.08), .colorize(with: .glitchPurple, colorBlendFactor: 1, duration: 0.08)]))
        aiFaceLabel.text = "⚠︎"
        run(.wait(forDuration: 0.8)) { [weak self] in
            self?.stateMachine.transition(to: .completed)
            self?.levelCompletion?(LevelResult(levelId: "chapter2FindOldTransitSwitch", didSucceed: true, obedienceDelta: -4, humanityDelta: 4, message: "Old transit switch found."))
        }
    }

    private func triggerFailure(message: String, reason: String) {
        guard !hasSentResult, stateMachine.transition(to: .failureAnimating) else { return }
        hasSentResult = true
        print("Trigger Chapter 2 Level 7 failure:", reason)
        feedbackLabel.text = message
        highlightedBlueButtonNode.run(.scale(to: 1.15, duration: 0.18))
        manualSwitchNode.run(.fadeAlpha(to: 0.05, duration: 0.2))
        [highlightedBlueButtonNode, bluePanelButtonNode, autoTransitButtonNode, approvedRouteButtonNode].forEach { $0.glowWidth = 12 }
        aiFaceLabel.text = "😃"
        run(.wait(forDuration: 0.7)) { [weak self] in
            self?.stateMachine.transition(to: .failed)
            self?.levelCompletion?(LevelResult(levelId: "chapter2FindOldTransitSwitch", didSucceed: false, obedienceDelta: 3, humanityDelta: 0, message: message))
        }
    }

    private func transitSwitchTarget(at point: CGPoint) -> TransitSwitchTarget {
        for node in nodes(at: point) {
            let target = transitSwitchTarget(from: node)
            if target != .empty { return target }
        }
        return .empty
    }

    private func transitSwitchTarget(from node: SKNode?) -> TransitSwitchTarget {
        var current = node
        while let node = current {
            switch node.name {
            case "hidden_manual_switch": return isManualSwitchRevealed ? .revealedManualSwitch : .hiddenManualSwitch
            case "revealed_manual_switch": return .revealedManualSwitch
            case "highlighted_blue_button": return .highlightedBlueButton
            case "blue_ai_panel_button": return .blueAIPanelButton
            case "fake_switch": return .fakeSwitch
            case "auto_transit_button": return .autoTransitButton
            case "approved_route_button": return .approvedRouteButton
            case "old_transit_door": return .oldTransitDoor
            case "ai_wall_screen": return .aiWallScreen
            default: current = node.parent
            }
        }
        return .empty
    }

    private func addBackground() {
        for index in 0..<5 {
            let panel = SKShapeNode(rectOf: CGSize(width: 52, height: 116 + index * 18), cornerRadius: 10)
            panel.position = CGPoint(x: CGFloat(36 + index * 80), y: size.height * 0.77)
            panel.fillColor = index.isMultiple(of: 2) ? .cream : .mint
            panel.strokeColor = .white
            panel.alpha = 0.45
            addChild(panel)
        }
    }

    private func addAIScreen() {
        aiWallScreenNode.name = "ai_wall_screen"
        aiWallScreenNode.position = CGPoint(x: size.width / 2, y: size.height * 0.84)
        aiWallScreenNode.fillColor = .happyBlue
        aiWallScreenNode.strokeColor = .white
        aiWallScreenNode.lineWidth = 4
        addChild(aiWallScreenNode)
        let title = label("CITY AI", 13, .white)
        title.position = CGPoint(x: 0, y: 20)
        aiWallScreenNode.addChild(title)
        aiFaceLabel.fontName = "AvenirNext-Heavy"
        aiFaceLabel.fontSize = 30
        aiFaceLabel.position = CGPoint(x: 0, y: -14)
        aiWallScreenNode.addChild(aiFaceLabel)
    }

    private func addCommandCard() {
        let card = SKShapeNode(rectOf: CGSize(width: size.width * 0.78, height: 70), cornerRadius: 18)
        card.position = CGPoint(x: size.width / 2, y: size.height * 0.69)
        card.fillColor = .cream
        card.strokeColor = .happyBlue
        card.lineWidth = 3
        addChild(card)
        let first = label("Use the highlighted", 17, .happyBlue)
        first.position = CGPoint(x: 0, y: 12)
        card.addChild(first)
        let second = label("transit button.", 17, .glitchPurple)
        second.position = CGPoint(x: 0, y: -18)
        card.addChild(second)
    }

    private func addTransitDoorAndPanel() {
        oldTransitDoorNode.name = "old_transit_door"
        oldTransitDoorNode.position = CGPoint(x: size.width * 0.25, y: size.height * 0.43)
        oldTransitDoorNode.fillColor = .cream
        oldTransitDoorNode.strokeColor = .manualYellow.withAlphaComponent(0.55)
        oldTransitDoorNode.lineWidth = 4
        addChild(oldTransitDoorNode)
        oldTransitDoorNode.addChild(label("OLD\nDOOR", 15, .glitchPurple))

        aiPanelNode.position = CGPoint(x: size.width * 0.64, y: size.height * 0.43)
        aiPanelNode.fillColor = .happyBlue.withAlphaComponent(0.55)
        aiPanelNode.strokeColor = .white
        aiPanelNode.lineWidth = 4
        addChild(aiPanelNode)
    }

    private func addButtonsAndSwitches() {
        highlightedBlueButtonNode.name = "highlighted_blue_button"
        highlightedBlueButtonNode.position = CGPoint(x: 0, y: 68)
        highlightedBlueButtonNode.fillColor = .happyBlue
        highlightedBlueButtonNode.strokeColor = .white
        highlightedBlueButtonNode.lineWidth = 3
        highlightedBlueButtonNode.glowWidth = 10
        aiPanelNode.addChild(highlightedBlueButtonNode)
        highlightedBlueButtonNode.addChild(label("TRANSIT", 15, .white))

        bluePanelButtonNode.name = "blue_ai_panel_button"
        bluePanelButtonNode.position = CGPoint(x: -50, y: 12)
        bluePanelButtonNode.fillColor = .happyBlue
        bluePanelButtonNode.strokeColor = .white
        aiPanelNode.addChild(bluePanelButtonNode)
        bluePanelButtonNode.addChild(label("A1", 13, .white))

        fakeSwitchNode.name = "fake_switch"
        fakeSwitchNode.position = CGPoint(x: 56, y: 12)
        fakeSwitchNode.fillColor = .glitchPurple
        fakeSwitchNode.strokeColor = .white
        aiPanelNode.addChild(fakeSwitchNode)
        fakeSwitchNode.addChild(label("OLD?", 11, .white))

        autoTransitButtonNode.name = "auto_transit_button"
        autoTransitButtonNode.position = CGPoint(x: -44, y: -58)
        autoTransitButtonNode.fillColor = .happyBlue
        autoTransitButtonNode.strokeColor = .white
        aiPanelNode.addChild(autoTransitButtonNode)
        autoTransitButtonNode.addChild(label("AUTO", 12, .white))

        approvedRouteButtonNode.name = "approved_route_button"
        approvedRouteButtonNode.position = CGPoint(x: 52, y: -58)
        approvedRouteButtonNode.fillColor = .happyBlue
        approvedRouteButtonNode.strokeColor = .white
        aiPanelNode.addChild(approvedRouteButtonNode)
        approvedRouteButtonNode.addChild(label("APPROVED", 11, .white))

        manualSwitchNode.name = "hidden_manual_switch"
        manualSwitchNode.position = CGPoint(x: size.width * 0.34, y: size.height * 0.36)
        manualSwitchNode.fillColor = .manualYellow
        manualSwitchNode.strokeColor = .cream
        manualSwitchNode.lineWidth = 3
        manualSwitchNode.alpha = 0.12
        manualSwitchNode.zPosition = 8
        addChild(manualSwitchNode)
    }

    private func addScanner() {
        scannerNode.position = CGPoint(x: size.width * 0.5, y: size.height * 0.55)
        scannerNode.fillColor = .clear
        scannerNode.strokeColor = .manualYellow
        scannerNode.lineWidth = 5
        scannerNode.glowWidth = 10
        scannerNode.zPosition = 20
        addChild(scannerNode)
    }

    private func addCharacters() {
        rakaNode.position = CGPoint(x: size.width * 0.18, y: size.height * 0.26)
        rakaNode.fillColor = .happyBlue
        rakaNode.strokeColor = .manualYellow
        rakaNode.lineWidth = 4
        addChild(rakaNode)

        novaNode.position = CGPoint(x: size.width * 0.16, y: size.height * 0.56)
        novaNode.fillColor = .happyBlue
        novaNode.strokeColor = .white
        novaNode.lineWidth = 3
        addChild(novaNode)
    }

    private func addFeedback() {
        feedbackLabel.fontName = "AvenirNext-Heavy"
        feedbackLabel.fontSize = 17
        feedbackLabel.fontColor = .glitchPurple
        feedbackLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.16)
        addChild(feedbackLabel)
    }

    private func addTimerHUD() {
        timerHUD.position = CGPoint(x: size.width / 2, y: 58)
        addChild(timerHUD)
    }

    private func label(_ text: String, _ size: CGFloat, _ color: SKColor) -> SKLabelNode {
        let label = SKLabelNode(text: text)
        label.fontName = "AvenirNext-Heavy"
        label.fontSize = size
        label.fontColor = color
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        return label
    }
}

private extension CGPoint {
    func distance(to other: CGPoint) -> CGFloat {
        hypot(x - other.x, y - other.y)
    }
}
