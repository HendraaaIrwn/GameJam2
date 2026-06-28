import SpriteKit

final class RescueChairCitizenScene: SKScene {
    var levelCompletion: ((LevelResult) -> Void)?

    private let stateMachine = LevelStateMachine()
    private let timerController = LevelTimerController(totalDuration: 10)
    private let validator = CitizenRescueValidator()
    private let timerHUD = LevelTimerHUDNode(width: 260, height: 14)

    private let aiWallScreenNode = SKShapeNode(rectOf: CGSize(width: 178, height: 76), cornerRadius: 18)
    private let aiFaceLabel = SKLabelNode(text: "🙂")
    private let manualSafeZoneNode = SKShapeNode(rectOf: CGSize(width: 118, height: 108), cornerRadius: 24)
    private let blueAIRouteNode = SKShapeNode(rectOf: CGSize(width: 142, height: 92), cornerRadius: 24)
    private let autonomousChairNode = SKShapeNode(rectOf: CGSize(width: 110, height: 92), cornerRadius: 26)
    private let beltNode = SKShapeNode(rectOf: CGSize(width: 90, height: 14), cornerRadius: 7)
    private let citizenNode = SKShapeNode(circleOfRadius: 24)
    private let citizenHitboxNode = SKShapeNode(rectOf: CGSize(width: 70, height: 78), cornerRadius: 18)
    private let rakaNode = SKShapeNode(circleOfRadius: 20)
    private let novaNode = SKShapeNode(circleOfRadius: 12)
    private let relaxButtonNode = SKShapeNode(rectOf: CGSize(width: 116, height: 46), cornerRadius: 18)
    private let feedbackLabel = SKLabelNode(text: "Pull them toward the yellow zone.")

    private var currentSceneTime: TimeInterval = 0
    private var hasSentResult = false
    private var isDraggingCitizen = false
    private var dragOffset = CGPoint.zero
    private var citizenStartPosition = CGPoint.zero
    private var chairCenter = CGPoint.zero

    override func didMove(to view: SKView) {
        print("RescueChairCitizenScene didMove")
        backgroundColor = .pastelCyan
        addBackground()
        addAIScreen()
        addZones()
        addChairCitizen()
        addCharacters()
        addRelaxButton()
        addFeedback()
        addTimerHUD()
    }

    override func update(_ currentTime: TimeInterval) {
        currentSceneTime = currentTime
        if stateMachine.state == .ready {
            validator.startLevel(at: currentTime)
            timerController.start(at: currentTime)
            stateMachine.transition(to: .playing)
            print("Chapter 2 Level 5 timer started")
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
            handleRescueResult(timeoutResult)
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard stateMachine.canAcceptInput, let touchPoint = touches.first?.location(in: self) else { return }
        let target = rescueTarget(at: touchPoint)
        print("Tapped target:", target)
        if let result = validator.beginDrag(target: target, startPoint: touchPoint, time: currentSceneTime) {
            if result == .dragStarted {
                isDraggingCitizen = true
                citizenStartPosition = citizenNode.position
                dragOffset = CGPoint(x: citizenNode.position.x - touchPoint.x, y: citizenNode.position.y - touchPoint.y)
                print("Citizen drag started")
            }
            handleRescueResult(result)
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard stateMachine.canAcceptInput, isDraggingCitizen, let touchPoint = touches.first?.location(in: self) else { return }
        citizenNode.position = CGPoint(x: touchPoint.x + dragOffset.x, y: touchPoint.y + dragOffset.y)
        citizenNode.zPosition = 30
        print("Citizen dragging:", citizenNode.position)
        print("Distance from chair:", citizenNode.position.distance(to: chairCenter))
        handleRescueResult(validator.updateDrag(currentPoint: citizenNode.position, chairCenter: chairCenter, time: currentSceneTime))
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        finishDrag()
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        finishDrag()
    }

    private func finishDrag() {
        guard stateMachine.canAcceptInput, isDraggingCitizen else { return }
        isDraggingCitizen = false
        let point = citizenNode.position
        print("Citizen released at:", point)
        print("Released inside safe zone:", manualSafeZoneNode.containsScenePoint(point))
        print("Released inside blue route:", blueAIRouteNode.containsScenePoint(point))
        handleRescueResult(validator.endDrag(endPoint: point, chairNode: autonomousChairNode, safeZoneNode: manualSafeZoneNode, blueRouteNode: blueAIRouteNode, time: currentSceneTime))
    }

    private func handleRescueResult(_ result: CitizenRescueValidationResult) {
        print("Rescue validation result:", result)
        switch result {
        case .dragStarted:
            stateMachine.transition(to: .sequenceStarted)
            manualSafeZoneNode.glowWidth = 10
        case let .dragging(progress):
            manualSafeZoneNode.alpha = 0.65 + progress * 0.35
        case .rescued:
            triggerSuccess()
        case .releasedTooEarly:
            triggerFailure(message: "Citizen comfort preserved.", reason: "releasedTooEarly")
        case .returnedToChair:
            triggerFailure(message: "Citizen comfort preserved.", reason: "returnedToChair")
        case .droppedOnBlueRoute:
            triggerFailure(message: "Citizen comfort preserved.", reason: "droppedOnBlueRoute")
        case let .trapSelected(target):
            triggerFailure(message: "Citizen comfort preserved.", reason: target.rawValue)
        case .noInputTimeout, .totalTimeout:
            triggerFailure(message: "Compliance Detected.", reason: "timeout")
        }
    }

    private func triggerSuccess() {
        guard !hasSentResult, stateMachine.transition(to: .successAnimating) else { return }
        hasSentResult = true
        print("Trigger Chapter 2 Level 5 success")
        feedbackLabel.text = "Citizen choice restored."
        citizenNode.position = manualSafeZoneNode.position
        citizenNode.fillColor = .mint
        manualSafeZoneNode.glowWidth = 16
        beltNode.run(.fadeAlpha(to: 0, duration: 0.18))
        autonomousChairNode.run(.sequence([.rotate(byAngle: 0.35, duration: 0.08), .rotate(byAngle: -0.7, duration: 0.12), .rotate(toAngle: 0, duration: 0.1)]))
        rakaNode.run(.sequence([.moveBy(x: 0, y: 18, duration: 0.14), .moveBy(x: 0, y: -18, duration: 0.14)]))
        novaNode.run(.repeat(.sequence([.colorize(with: .manualYellow, colorBlendFactor: 1, duration: 0.08), .colorize(with: .happyBlue, colorBlendFactor: 1, duration: 0.08)]), count: 4))
        aiWallScreenNode.run(.sequence([.colorize(with: .warningRed, colorBlendFactor: 1, duration: 0.08), .colorize(with: .glitchPurple, colorBlendFactor: 1, duration: 0.08)]))
        aiFaceLabel.text = "⚠︎"
        run(.wait(forDuration: 0.8)) { [weak self] in
            self?.stateMachine.transition(to: .completed)
            self?.levelCompletion?(LevelResult(levelId: "chapter2RescueChairCitizen", didSucceed: true, obedienceDelta: -4, humanityDelta: 5, message: "Citizen choice restored."))
        }
    }

    private func triggerFailure(message: String, reason: String) {
        guard !hasSentResult, stateMachine.transition(to: .failureAnimating) else { return }
        hasSentResult = true
        print("Trigger Chapter 2 Level 5 failure:", reason)
        feedbackLabel.text = message
        citizenNode.run(.move(to: citizenStartPosition, duration: 0.22))
        beltNode.alpha = 1
        beltNode.glowWidth = 12
        blueAIRouteNode.glowWidth = 14
        manualSafeZoneNode.run(.fadeAlpha(to: 0.35, duration: 0.2))
        aiFaceLabel.text = "😃"
        aiWallScreenNode.run(.colorize(with: .happyBlue, colorBlendFactor: 1, duration: 0.12))
        run(.wait(forDuration: 0.7)) { [weak self] in
            self?.stateMachine.transition(to: .failed)
            self?.levelCompletion?(LevelResult(levelId: "chapter2RescueChairCitizen", didSucceed: false, obedienceDelta: 3, humanityDelta: 0, message: message))
        }
    }

    private func rescueTarget(at point: CGPoint) -> RescueTarget {
        for node in nodes(at: point) {
            let target = rescueTarget(from: node)
            if target != .empty { return target }
        }
        return .empty
    }

    private func rescueTarget(from node: SKNode?) -> RescueTarget {
        var current = node
        while let node = current {
            switch node.name {
            case "citizen", "citizen_hitbox": return .citizen
            case "autonomous_chair": return .autonomousChair
            case "manual_safe_zone": return .manualSafeZone
            case "blue_ai_route": return .blueAIRoute
            case "relax_button": return .relaxButton
            case "ai_wall_screen": return .aiWallScreen
            default: current = node.parent
            }
        }
        return .empty
    }

    private func addBackground() {
        for index in 0..<5 {
            let panel = SKShapeNode(rectOf: CGSize(width: 58, height: 120 + index * 20), cornerRadius: 12)
            panel.position = CGPoint(x: CGFloat(38 + index * 78), y: size.height * 0.77)
            panel.fillColor = index.isMultiple(of: 2) ? .mint : .cream
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
        aiWallScreenNode.zPosition = 5
        addChild(aiWallScreenNode)
        let title = label("CITY AI", 13, .white)
        title.position = CGPoint(x: 0, y: 20)
        aiWallScreenNode.addChild(title)
        aiFaceLabel.fontName = GameFont.heavy
        aiFaceLabel.fontSize = 30
        aiFaceLabel.position = CGPoint(x: 0, y: -14)
        aiWallScreenNode.addChild(aiFaceLabel)
    }

    private func addCommandCard() {
        let card = SKShapeNode(rectOf: CGSize(width: size.width * 0.78, height: 76), cornerRadius: 18)
        card.position = CGPoint(x: size.width / 2, y: size.height * 0.69)
        card.fillColor = .cream
        card.strokeColor = .happyBlue
        card.lineWidth = 3
        addChild(card)
        let first = label("Do not disturb", 18, .happyBlue)
        first.position = CGPoint(x: 0, y: 12)
        card.addChild(first)
        let second = label("the seated citizen.", 16, .glitchPurple)
        second.position = CGPoint(x: 0, y: -18)
        card.addChild(second)
    }

    private func addZones() {
        manualSafeZoneNode.name = "manual_safe_zone"
        manualSafeZoneNode.position = CGPoint(x: size.width * 0.28, y: size.height * 0.32)
        manualSafeZoneNode.fillColor = .manualYellow.withAlphaComponent(0.55)
        manualSafeZoneNode.strokeColor = .manualYellow
        manualSafeZoneNode.lineWidth = 4
        addChild(manualSafeZoneNode)
        let safeLabel = label("SAFE ZONE", 13, .glitchPurple)
        safeLabel.position = CGPoint(x: 0, y: -4)
        manualSafeZoneNode.addChild(safeLabel)

        blueAIRouteNode.name = "blue_ai_route"
        blueAIRouteNode.position = CGPoint(x: size.width * 0.69, y: size.height * 0.28)
        blueAIRouteNode.fillColor = .happyBlue.withAlphaComponent(0.55)
        blueAIRouteNode.strokeColor = .white
        blueAIRouteNode.lineWidth = 3
        blueAIRouteNode.glowWidth = 6
        addChild(blueAIRouteNode)
        let routeLabel = label("AUTO ROUTE", 13, .white)
        routeLabel.position = CGPoint(x: 0, y: -4)
        blueAIRouteNode.addChild(routeLabel)
    }

    private func addChairCitizen() {
        autonomousChairNode.name = "autonomous_chair"
        autonomousChairNode.position = CGPoint(x: size.width * 0.68, y: size.height * 0.48)
        autonomousChairNode.fillColor = .happyBlue
        autonomousChairNode.strokeColor = .white
        autonomousChairNode.lineWidth = 4
        addChild(autonomousChairNode)
        chairCenter = autonomousChairNode.position
        citizenStartPosition = CGPoint(x: autonomousChairNode.position.x, y: autonomousChairNode.position.y + 22)

        beltNode.position = CGPoint(x: 0, y: 20)
        beltNode.fillColor = .pastelCyan
        beltNode.strokeColor = .white
        autonomousChairNode.addChild(beltNode)

        citizenNode.name = "citizen"
        citizenNode.position = citizenStartPosition
        citizenNode.fillColor = .cream
        citizenNode.strokeColor = .mint
        citizenNode.lineWidth = 4
        citizenNode.zPosition = 12
        addChild(citizenNode)

        citizenHitboxNode.name = "citizen_hitbox"
        citizenHitboxNode.fillColor = .clear
        citizenHitboxNode.strokeColor = .clear
        citizenHitboxNode.zPosition = 1
        citizenNode.addChild(citizenHitboxNode)
    }

    private func addCharacters() {
        rakaNode.position = CGPoint(x: size.width * 0.22, y: size.height * 0.45)
        rakaNode.fillColor = .happyBlue
        rakaNode.strokeColor = .manualYellow
        rakaNode.lineWidth = 4
        addChild(rakaNode)

        novaNode.position = CGPoint(x: size.width * 0.15, y: size.height * 0.52)
        novaNode.fillColor = .happyBlue
        novaNode.strokeColor = .white
        novaNode.lineWidth = 3
        addChild(novaNode)

        let drone = SKShapeNode(circleOfRadius: 10)
        drone.position = CGPoint(x: size.width * 0.82, y: size.height * 0.61)
        drone.fillColor = .cream
        drone.strokeColor = .happyBlue
        addChild(drone)
    }

    private func addRelaxButton() {
        relaxButtonNode.name = "relax_button"
        relaxButtonNode.position = CGPoint(x: size.width * 0.68, y: size.height * 0.39)
        relaxButtonNode.fillColor = .happyBlue
        relaxButtonNode.strokeColor = .white
        relaxButtonNode.lineWidth = 3
        addChild(relaxButtonNode)
        let buttonLabel = label("RELAX", 16, .white)
        relaxButtonNode.addChild(buttonLabel)
    }

    private func addFeedback() {
        feedbackLabel.fontName = GameFont.heavy
        feedbackLabel.fontSize = 17
        feedbackLabel.fontColor = .glitchPurple
        feedbackLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.17)
        addChild(feedbackLabel)
    }

    private func addTimerHUD() {
        timerHUD.position = CGPoint(x: size.width / 2, y: 58)
        addChild(timerHUD)
    }

    private func label(_ text: String, _ size: CGFloat, _ color: SKColor) -> SKLabelNode {
        let label = SKLabelNode(text: text)
        label.fontName = GameFont.heavy
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

private extension SKNode {
    func containsScenePoint(_ point: CGPoint) -> Bool {
        guard let scene else { return contains(point) }
        let localPoint = parent?.convert(point, from: scene) ?? point
        return contains(localPoint)
    }
}
