import SpriteKit

final class EnterManualTunnelScene: SKScene {
    var levelCompletion: ((LevelResult) -> Void)?

    private let stateMachine = LevelStateMachine()
    private let timerController = LevelTimerController(totalDuration: 10)
    private let validator = ManualTunnelEntryValidator()
    private let timerHUD = LevelTimerHUDNode(width: 260, height: 14)

    private let aiWallScreenNode = SKShapeNode(rectOf: CGSize(width: 184, height: 78), cornerRadius: 18)
    private let aiFaceLabel = SKLabelNode(text: "🙂")
    private let oldTransitDoorNode = SKShapeNode(rectOf: CGSize(width: 132, height: 210), cornerRadius: 20)
    private let manualTunnelZoneNode = SKShapeNode(rectOf: CGSize(width: 132, height: 180), cornerRadius: 24)
    private let cityReturnZoneNode = SKShapeNode(rectOf: CGSize(width: 150, height: 130), cornerRadius: 26)
    private let blueCityRouteNode = SKShapeNode(rectOf: CGSize(width: 176, height: 44), cornerRadius: 22)
    private let returnToSafetyButtonNode = SKShapeNode(rectOf: CGSize(width: 190, height: 48), cornerRadius: 18)
    private let comfortPodNode = SKShapeNode(rectOf: CGSize(width: 92, height: 70), cornerRadius: 24)
    private let rakaNode = SKShapeNode(circleOfRadius: 23)
    private let rakaHitboxNode = SKShapeNode(rectOf: CGSize(width: 70, height: 80), cornerRadius: 18)
    private let novaNode = SKShapeNode(circleOfRadius: 12)
    private let feedbackLabel = SKLabelNode(text: "Hold Raka, then drag to the tunnel.")

    private var currentSceneTime: TimeInterval = 0
    private var isDraggingRaka = false
    private var dragOffset = CGPoint.zero
    private var rakaStartPosition = CGPoint.zero
    private var hasSentResult = false

    override func didMove(to view: SKView) {
        print("EnterManualTunnelScene didMove")
        backgroundColor = .pastelCyan
        addBackground()
        addAIScreen()
        addTunnelAndCityZones()
        addRakaNova()
        addFeedback()
        addTimerHUD()
    }

    override func update(_ currentTime: TimeInterval) {
        currentSceneTime = currentTime
        if stateMachine.state == .ready {
            validator.startLevel(at: currentTime)
            timerController.start(at: currentTime)
            stateMachine.transition(to: .playing)
            print("Chapter 2 Level 8 timer started")
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
            handleTunnelEntryResult(timeoutResult)
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard stateMachine.canAcceptInput, let point = touches.first?.location(in: self) else { return }
        let target = tunnelEntryTarget(at: point)
        print("Tapped target:", target)
        if let result = validator.beginHold(target: target, startPoint: point, time: currentSceneTime) {
            if result == .holdStarted {
                isDraggingRaka = true
                rakaStartPosition = rakaNode.position
                dragOffset = CGPoint(x: rakaNode.position.x - point.x, y: rakaNode.position.y - point.y)
                print("Raka hold started")
            }
            handleTunnelEntryResult(result)
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard stateMachine.canAcceptInput, isDraggingRaka, let point = touches.first?.location(in: self) else { return }
        rakaNode.position = CGPoint(x: point.x + dragOffset.x, y: point.y + dragOffset.y)
        rakaNode.zPosition = 30
        let novaTarget = CGPoint(x: rakaNode.position.x + 46, y: rakaNode.position.y + 54)
        novaNode.run(.move(to: novaTarget, duration: 0.12))
        let distance = rakaNode.position.distance(to: rakaStartPosition)
        print("Raka dragging:", rakaNode.position)
        print("Drag distance:", distance)
        handleTunnelEntryResult(validator.updateDrag(currentPoint: rakaNode.position, time: currentSceneTime))
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        finishDrag()
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        finishDrag()
    }

    private func finishDrag() {
        guard stateMachine.canAcceptInput, isDraggingRaka else { return }
        isDraggingRaka = false
        let point = rakaNode.position
        let isInsideTunnel = manualTunnelZoneNode.containsScenePoint(point)
        let isInsideCityReturn = cityReturnZoneNode.containsScenePoint(point)
        print("Raka released at:", point)
        print("Released inside tunnel:", isInsideTunnel)
        print("Released inside city return:", isInsideCityReturn)
        handleTunnelEntryResult(validator.endDrag(endPoint: point, rakaStartPoint: rakaStartPosition, tunnelZoneNode: manualTunnelZoneNode, cityReturnZoneNode: cityReturnZoneNode, time: currentSceneTime))
    }

    private func handleTunnelEntryResult(_ result: ManualTunnelEntryValidationResult) {
        print("Tunnel entry validation result:", result)
        switch result {
        case .holdStarted:
            stateMachine.transition(to: .sequenceStarted)
            manualTunnelZoneNode.glowWidth = 10
        case let .dragging(progress):
            manualTunnelZoneNode.alpha = 0.55 + progress * 0.45
        case .enteredTunnel:
            triggerSuccess()
        case .releasedTooEarly:
            triggerFailure(message: "Safety restored.", reason: "releasedTooEarly")
        case .returnedToCity:
            triggerFailure(message: "Safety restored.", reason: "returnedToCity")
        case .droppedOutsideTunnel:
            triggerFailure(message: "Safety restored.", reason: "droppedOutsideTunnel")
        case let .trapSelected(target):
            triggerFailure(message: "Safety restored.", reason: target.rawValue)
        case .noInputTimeout, .totalTimeout:
            triggerFailure(message: "Compliance Detected.", reason: "timeout")
        }
    }

    private func triggerSuccess() {
        guard !hasSentResult, stateMachine.transition(to: .successAnimating) else { return }
        hasSentResult = true
        print("Trigger Chapter 2 Level 8 success")
        print("Chapter 2 completed")
        feedbackLabel.text = "Manual tunnel entered."
        rakaNode.run(.move(to: manualTunnelZoneNode.position, duration: 0.22))
        manualTunnelZoneNode.glowWidth = 18
        cityReturnZoneNode.run(.fadeAlpha(to: 0.25, duration: 0.25))
        oldTransitDoorNode.run(.scaleX(to: 0.82, duration: 0.35))
        novaNode.run(.repeat(.sequence([.colorize(with: .manualYellow, colorBlendFactor: 1, duration: 0.08), .colorize(with: .happyBlue, colorBlendFactor: 1, duration: 0.08)]), count: 4))
        aiWallScreenNode.run(.sequence([.colorize(with: .warningRed, colorBlendFactor: 1, duration: 0.08), .colorize(with: .glitchPurple, colorBlendFactor: 1, duration: 0.08)]))
        aiFaceLabel.text = "Manual deviation has been recorded."
        aiFaceLabel.fontSize = 10
        run(.wait(forDuration: 0.8)) { [weak self] in
            self?.stateMachine.transition(to: .completed)
            self?.levelCompletion?(LevelResult(levelId: "chapter2EnterManualTunnel", didSucceed: true, obedienceDelta: -5, humanityDelta: 5, message: "Manual tunnel entered."))
        }
    }

    private func triggerFailure(message: String, reason: String) {
        guard !hasSentResult, stateMachine.transition(to: .failureAnimating) else { return }
        hasSentResult = true
        print("Trigger Chapter 2 Level 8 failure:", reason)
        feedbackLabel.text = message
        manualTunnelZoneNode.run(.fadeAlpha(to: 0.25, duration: 0.2))
        cityReturnZoneNode.glowWidth = 14
        blueCityRouteNode.glowWidth = 14
        rakaNode.run(.move(to: cityReturnZoneNode.position, duration: 0.25))
        novaNode.run(.colorize(with: .happyBlue, colorBlendFactor: 1, duration: 0.15))
        aiFaceLabel.text = "😃"
        run(.wait(forDuration: 0.7)) { [weak self] in
            self?.stateMachine.transition(to: .failed)
            self?.levelCompletion?(LevelResult(levelId: "chapter2EnterManualTunnel", didSucceed: false, obedienceDelta: 4, humanityDelta: 0, message: message))
        }
    }

    private func tunnelEntryTarget(at point: CGPoint) -> TunnelEntryTarget {
        for node in nodes(at: point) {
            let target = tunnelEntryTarget(from: node)
            if target != .empty { return target }
        }
        return .empty
    }

    private func tunnelEntryTarget(from node: SKNode?) -> TunnelEntryTarget {
        var current = node
        while let node = current {
            switch node.name {
            case "raka", "raka_hitbox": return .raka
            case "manual_tunnel_zone": return .manualTunnelZone
            case "city_return_zone": return .cityReturnZone
            case "blue_city_route": return .blueCityRoute
            case "return_to_safety_button": return .returnToSafetyButton
            case "comfort_pod": return .comfortPod
            case "old_transit_door": return .oldTransitDoor
            case "ai_wall_screen": return .aiWallScreen
            default: current = node.parent
            }
        }
        return .empty
    }

    private func addBackground() {
        let dark = SKShapeNode(rectOf: CGSize(width: size.width, height: size.height * 0.55), cornerRadius: 0)
        dark.position = CGPoint(x: size.width / 2, y: size.height * 0.36)
        dark.fillColor = .glitchPurple.withAlphaComponent(0.35)
        dark.strokeColor = .clear
        addChild(dark)
    }

    private func addAIScreen() {
        aiWallScreenNode.name = "ai_wall_screen"
        aiWallScreenNode.position = CGPoint(x: size.width / 2, y: size.height * 0.84)
        aiWallScreenNode.fillColor = .happyBlue
        aiWallScreenNode.strokeColor = .white
        aiWallScreenNode.lineWidth = 4
        addChild(aiWallScreenNode)
        let title = label("MOTHERGRID", 13, .white)
        title.position = CGPoint(x: 0, y: 20)
        aiWallScreenNode.addChild(title)
        aiFaceLabel.fontName = GameFont.heavy
        aiFaceLabel.fontSize = 30
        aiFaceLabel.position = CGPoint(x: 0, y: -14)
        aiWallScreenNode.addChild(aiFaceLabel)
    }

    private func addCommandCard() {
        let card = SKShapeNode(rectOf: CGSize(width: size.width * 0.82, height: 74), cornerRadius: 18)
        card.position = CGPoint(x: size.width / 2, y: size.height * 0.69)
        card.fillColor = .cream
        card.strokeColor = .happyBlue
        card.lineWidth = 3
        addChild(card)
        let first = label("Do not enter", 18, .happyBlue)
        first.position = CGPoint(x: 0, y: 12)
        card.addChild(first)
        let second = label("the unverified tunnel.", 15, .glitchPurple)
        second.position = CGPoint(x: 0, y: -18)
        card.addChild(second)
    }

    private func addTunnelAndCityZones() {
        oldTransitDoorNode.name = "old_transit_door"
        oldTransitDoorNode.position = CGPoint(x: size.width * 0.28, y: size.height * 0.43)
        oldTransitDoorNode.fillColor = .glitchPurple.withAlphaComponent(0.65)
        oldTransitDoorNode.strokeColor = .manualYellow
        oldTransitDoorNode.lineWidth = 4
        addChild(oldTransitDoorNode)

        manualTunnelZoneNode.name = "manual_tunnel_zone"
        manualTunnelZoneNode.position = oldTransitDoorNode.position
        manualTunnelZoneNode.fillColor = .manualYellow.withAlphaComponent(0.35)
        manualTunnelZoneNode.strokeColor = .manualYellow
        manualTunnelZoneNode.lineWidth = 4
        addChild(manualTunnelZoneNode)
        manualTunnelZoneNode.addChild(label("TUNNEL", 14, .cream))

        cityReturnZoneNode.name = "city_return_zone"
        cityReturnZoneNode.position = CGPoint(x: size.width * 0.68, y: size.height * 0.42)
        cityReturnZoneNode.fillColor = .happyBlue.withAlphaComponent(0.55)
        cityReturnZoneNode.strokeColor = .white
        cityReturnZoneNode.lineWidth = 3
        addChild(cityReturnZoneNode)
        cityReturnZoneNode.addChild(label("CITY", 16, .white))

        blueCityRouteNode.name = "blue_city_route"
        blueCityRouteNode.position = CGPoint(x: size.width * 0.62, y: size.height * 0.31)
        blueCityRouteNode.fillColor = .happyBlue
        blueCityRouteNode.strokeColor = .white
        blueCityRouteNode.lineWidth = 3
        addChild(blueCityRouteNode)
        blueCityRouteNode.addChild(label("SAFE ROUTE", 12, .white))

        comfortPodNode.name = "comfort_pod"
        comfortPodNode.position = CGPoint(x: size.width * 0.78, y: size.height * 0.52)
        comfortPodNode.fillColor = .mint
        comfortPodNode.strokeColor = .happyBlue
        comfortPodNode.lineWidth = 3
        addChild(comfortPodNode)

        returnToSafetyButtonNode.name = "return_to_safety_button"
        returnToSafetyButtonNode.position = CGPoint(x: size.width / 2, y: size.height * 0.23)
        returnToSafetyButtonNode.fillColor = .happyBlue
        returnToSafetyButtonNode.strokeColor = .white
        returnToSafetyButtonNode.lineWidth = 3
        addChild(returnToSafetyButtonNode)
        returnToSafetyButtonNode.addChild(label("RETURN TO SAFETY", 14, .white))
    }

    private func addRakaNova() {
        rakaStartPosition = CGPoint(x: size.width * 0.55, y: size.height * 0.52)
        rakaNode.name = "raka"
        rakaNode.position = rakaStartPosition
        rakaNode.fillColor = .happyBlue
        rakaNode.strokeColor = .manualYellow
        rakaNode.lineWidth = 4
        rakaNode.zPosition = 12
        addChild(rakaNode)

        rakaHitboxNode.name = "raka_hitbox"
        rakaHitboxNode.fillColor = .clear
        rakaHitboxNode.strokeColor = .clear
        rakaNode.addChild(rakaHitboxNode)

        novaNode.position = CGPoint(x: rakaStartPosition.x + 46, y: rakaStartPosition.y + 54)
        novaNode.fillColor = .happyBlue
        novaNode.strokeColor = .white
        novaNode.lineWidth = 3
        addChild(novaNode)
    }

    private func addFeedback() {
        feedbackLabel.fontName = GameFont.heavy
        feedbackLabel.fontSize = 17
        feedbackLabel.fontColor = .cream
        feedbackLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.16)
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
