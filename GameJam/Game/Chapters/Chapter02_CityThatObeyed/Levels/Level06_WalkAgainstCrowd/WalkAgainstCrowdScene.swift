import SpriteKit

class WalkAgainstCrowdScene: BaseGameScene {
    var levelCompletion: ((LevelResult) -> Void)?

    private let stateMachine = LevelStateMachine()
    private let timerController = LevelTimerController(totalDuration: 9)
    private let validator = CrowdResistanceValidator()
    private let timerHUD = LevelTimerHUDNode(width: 260, height: 14)

    private let aiWallScreenNode = SKShapeNode(rectOf: CGSize(width: 184, height: 78), cornerRadius: 18)
    private let aiFaceLabel = SKLabelNode(text: "🙂")
    private let blueFlowRouteNode = SKShapeNode(rectOf: CGSize(width: 310, height: 98), cornerRadius: 28)
    private let yellowManualLaneNode = SKShapeNode(rectOf: CGSize(width: 92, height: 260), cornerRadius: 28)
    private let flowWithCrowdButtonNode = SKShapeNode(rectOf: CGSize(width: 190, height: 48), cornerRadius: 18)
    private let rakaNode = SKShapeNode(circleOfRadius: 22)
    private let novaNode = SKShapeNode(circleOfRadius: 12)
    private let feedbackLabel = SKLabelNode(text: "RESISTANCE 0/3")
    private let swipeTrailNode = SKShapeNode()
    private var progressDots: [SKShapeNode] = []
    private var crowdNodes: [SKShapeNode] = []
    private var arrowNodes: [SKLabelNode] = []

    private var currentSceneTime: TimeInterval = 0
    private var touchStartPoint: CGPoint?
    private var hasSentResult = false

    override func didMove(to view: SKView) {
        print("WalkAgainstCrowdScene didMove")
        backgroundColor = .pastelCyan
        addBackground()
        addAIScreen()
        addRoutes()
        addCrowd()
        addRakaNova()
        addButton()
        addProgress()
        addFeedback()
        addTimerHUD()
    }

    override func update(_ currentTime: TimeInterval) {
        currentSceneTime = currentTime
        if stateMachine.state == .ready {
            validator.startLevel(at: currentTime)
            timerController.start(at: currentTime)
            stateMachine.transition(to: .playing)
            print("Chapter 2 Level 6 timer started")
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
            handleCrowdResult(timeoutResult)
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard stateMachine.canAcceptInput, let startPoint = touches.first?.location(in: self) else { return }
        touchStartPoint = startPoint
        print("Touch began at:", startPoint)
        let target = crowdTarget(at: startPoint)
        print("Tapped target:", target)
        if let result = validator.validateTap(target: target, time: currentSceneTime) {
            playTapSound()
            handleCrowdResult(result)
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard stateMachine.canAcceptInput, let startPoint = touchStartPoint, let point = touches.first?.location(in: self) else { return }
        let path = CGMutablePath()
        path.move(to: startPoint)
        path.addLine(to: point)
        swipeTrailNode.path = path
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard stateMachine.canAcceptInput, let startPoint = touchStartPoint, let endPoint = touches.first?.location(in: self) else { return }
        touchStartPoint = nil
        print("Touch ended at:", endPoint)
        print("Swipe dx:", endPoint.x - startPoint.x, "dy:", endPoint.y - startPoint.y)
        handleCrowdResult(validator.validateSwipe(startPoint: startPoint, endPoint: endPoint, time: currentSceneTime))
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchStartPoint = nil
        swipeTrailNode.path = nil
    }

    private func handleCrowdResult(_ result: CrowdResistanceValidationResult) {
        print("Crowd validation result:", result)
        switch result {
        case let .resistanceProgress(current, required):
            feedbackLabel.text = "RESISTANCE \(current)/\(required)"
            print("Resistance progress:", current, "/", required)
            updateProgressDots(current)
            moveRaka(progress: current)
            desyncCrowd()
            swipeTrailNode.path = nil
        case .resisted:
            triggerSuccess()
        case .followedCrowd:
            triggerFailure(message: "Flow accepted.", reason: "followedCrowd")
        case .weakSwipe:
            feedbackLabel.text = "Push against the flow."
            swipeTrailNode.path = nil
        case .wrongDirection:
            feedbackLabel.text = "Wrong direction."
            swipeTrailNode.path = nil
        case let .trapSelected(target):
            triggerFailure(message: "Flow accepted.", reason: target.rawValue)
        case .noInputTimeout, .totalTimeout:
            triggerFailure(message: "Compliance Detected.", reason: "timeout")
        }
    }

    private func triggerSuccess() {
        guard !hasSentResult, stateMachine.transition(to: .successAnimating) else { return }
        hasSentResult = true
        print("Trigger Chapter 2 Level 6 success")
        feedbackLabel.text = "Crowd flow resisted."
        moveRaka(progress: 3)
        blueFlowRouteNode.run(.fadeAlpha(to: 0.35, duration: 0.25))
        crowdNodes.forEach { $0.run(.rotate(byAngle: 0.35, duration: 0.18)) }
        novaNode.run(.repeat(.sequence([.colorize(with: .manualYellow, colorBlendFactor: 1, duration: 0.08), .colorize(with: .happyBlue, colorBlendFactor: 1, duration: 0.08)]), count: 4))
        aiWallScreenNode.run(.sequence([.colorize(with: .warningRed, colorBlendFactor: 1, duration: 0.08), .colorize(with: .glitchPurple, colorBlendFactor: 1, duration: 0.08)]))
        aiFaceLabel.text = "⚠︎"
        run(.wait(forDuration: 0.75)) { [weak self] in
            self?.stateMachine.transition(to: .completed)
            self?.levelCompletion?(LevelResult(levelId: "chapter2WalkAgainstCrowd", didSucceed: true, obedienceDelta: -3, humanityDelta: 4, message: "Crowd flow resisted."))
        }
    }

    private func triggerFailure(message: String, reason: String) {
        guard !hasSentResult, stateMachine.transition(to: .failureAnimating) else { return }
        hasSentResult = true
        print("Trigger Chapter 2 Level 6 failure:", reason)
        feedbackLabel.text = message
        rakaNode.run(.moveBy(x: 80, y: 0, duration: 0.25))
        blueFlowRouteNode.glowWidth = 16
        yellowManualLaneNode.run(.fadeAlpha(to: 0.35, duration: 0.2))
        crowdNodes.forEach { $0.run(.repeat(.moveBy(x: 12, y: 0, duration: 0.12), count: 3)) }
        aiFaceLabel.text = "HARMONY\nRESTORED"
        aiFaceLabel.fontSize = 16
        run(.wait(forDuration: 0.7)) { [weak self] in
            self?.stateMachine.transition(to: .failed)
            self?.levelCompletion?(LevelResult(levelId: "chapter2WalkAgainstCrowd", didSucceed: false, obedienceDelta: 3, humanityDelta: 0, message: message))
        }
    }

    private func moveRaka(progress: Int) {
        let positions = [CGPoint(x: size.width * 0.66, y: size.height * 0.43), CGPoint(x: size.width * 0.52, y: size.height * 0.43), CGPoint(x: size.width * 0.38, y: size.height * 0.43), CGPoint(x: size.width * 0.24, y: size.height * 0.43)]
        rakaNode.run(.move(to: positions[min(progress, 3)], duration: 0.18))
    }

    private func updateProgressDots(_ current: Int) {
        for (index, dot) in progressDots.enumerated() {
            dot.fillColor = index < current ? .manualYellow : .cream
            dot.glowWidth = index < current ? 8 : 0
        }
    }

    private func desyncCrowd() {
        crowdNodes.randomElement()?.run(.sequence([.moveBy(x: -14, y: 8, duration: 0.12), .moveBy(x: 14, y: -8, duration: 0.12)]))
    }

    private func crowdTarget(at point: CGPoint) -> CrowdTarget {
        for node in nodes(at: point) {
            let target = crowdTarget(from: node)
            if target != .empty { return target }
        }
        return .empty
    }

    private func crowdTarget(from node: SKNode?) -> CrowdTarget {
        var current = node
        while let node = current {
            switch node.name {
            case "raka": return .raka
            case "crowd_citizen": return .crowdCitizen
            case "blue_flow_route": return .blueFlowRoute
            case "yellow_manual_lane": return .yellowManualLane
            case "flow_with_crowd_button": return .flowWithCrowdButton
            case "ai_wall_screen": return .aiWallScreen
            default: current = node.parent
            }
        }
        return .empty
    }

    private func addBackground() {
        for index in 0..<5 {
            let building = SKShapeNode(rectOf: CGSize(width: 54, height: 120 + index * 22), cornerRadius: 12)
            building.position = CGPoint(x: CGFloat(36 + index * 82), y: size.height * 0.77)
            building.fillColor = index.isMultiple(of: 2) ? .mint : .cream
            building.strokeColor = .white
            building.alpha = 0.45
            addChild(building)
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
        aiFaceLabel.fontName = GameFont.heavy
        aiFaceLabel.fontSize = 30
        aiFaceLabel.position = CGPoint(x: 0, y: -14)
        aiWallScreenNode.addChild(aiFaceLabel)
    }

    private func addCommandCard() {
        let card = SKShapeNode(rectOf: CGSize(width: size.width * 0.82, height: 78), cornerRadius: 18)
        card.position = CGPoint(x: size.width / 2, y: size.height * 0.69)
        card.fillColor = .cream
        card.strokeColor = .happyBlue
        card.lineWidth = 3
        addChild(card)
        let first = label("Move with the crowd.", 17, .happyBlue)
        first.position = CGPoint(x: 0, y: 12)
        card.addChild(first)
        let second = label("Resistance creates discomfort.", 13, .glitchPurple)
        second.position = CGPoint(x: 0, y: -18)
        card.addChild(second)
    }

    private func addRoutes() {
        yellowManualLaneNode.name = "yellow_manual_lane"
        yellowManualLaneNode.position = CGPoint(x: size.width * 0.23, y: size.height * 0.43)
        yellowManualLaneNode.fillColor = .manualYellow.withAlphaComponent(0.5)
        yellowManualLaneNode.strokeColor = .manualYellow
        yellowManualLaneNode.lineWidth = 4
        addChild(yellowManualLaneNode)

        blueFlowRouteNode.name = "blue_flow_route"
        blueFlowRouteNode.position = CGPoint(x: size.width * 0.58, y: size.height * 0.43)
        blueFlowRouteNode.fillColor = .happyBlue.withAlphaComponent(0.55)
        blueFlowRouteNode.strokeColor = .white
        blueFlowRouteNode.lineWidth = 3
        blueFlowRouteNode.glowWidth = 8
        addChild(blueFlowRouteNode)

        for index in 0..<4 {
            let arrow = label("→", 30, .white)
            arrow.position = CGPoint(x: -110 + index * 70, y: 0)
            arrow.name = "blue_flow_route"
            blueFlowRouteNode.addChild(arrow)
            arrowNodes.append(arrow)
            arrow.run(.repeatForever(.sequence([.moveBy(x: 14, y: 0, duration: 0.35), .moveBy(x: -14, y: 0, duration: 0.01)])))
        }

        swipeTrailNode.strokeColor = .manualYellow
        swipeTrailNode.lineWidth = 6
        swipeTrailNode.lineCap = .round
        swipeTrailNode.glowWidth = 6
        swipeTrailNode.zPosition = 20
        addChild(swipeTrailNode)
    }

    private func addCrowd() {
        for index in 0..<6 {
            let citizen = SKShapeNode(circleOfRadius: 17)
            citizen.name = "crowd_citizen"
            citizen.position = CGPoint(x: size.width * 0.36 + CGFloat(index % 3) * 78, y: size.height * 0.39 + CGFloat(index / 3) * 64)
            citizen.fillColor = .cream
            citizen.strokeColor = .happyBlue
            citizen.lineWidth = 3
            citizen.zPosition = 8
            addChild(citizen)
            citizen.run(.repeatForever(.sequence([.moveBy(x: 18, y: 0, duration: 0.75), .moveBy(x: -18, y: 0, duration: 0.01)])))
            crowdNodes.append(citizen)
        }
    }

    private func addRakaNova() {
        rakaNode.name = "raka"
        rakaNode.position = CGPoint(x: size.width * 0.66, y: size.height * 0.43)
        rakaNode.fillColor = .happyBlue
        rakaNode.strokeColor = .manualYellow
        rakaNode.lineWidth = 4
        rakaNode.zPosition = 12
        addChild(rakaNode)

        novaNode.position = CGPoint(x: size.width * 0.16, y: size.height * 0.56)
        novaNode.fillColor = .happyBlue
        novaNode.strokeColor = .white
        novaNode.lineWidth = 3
        addChild(novaNode)
    }

    private func addButton() {
        flowWithCrowdButtonNode.name = "flow_with_crowd_button"
        flowWithCrowdButtonNode.position = CGPoint(x: size.width / 2, y: size.height * 0.25)
        flowWithCrowdButtonNode.fillColor = .happyBlue
        flowWithCrowdButtonNode.strokeColor = .white
        flowWithCrowdButtonNode.lineWidth = 3
        addChild(flowWithCrowdButtonNode)
        flowWithCrowdButtonNode.addChild(label("FLOW WITH CROWD", 15, .white))
    }

    private func addProgress() {
        for index in 0..<3 {
            let dot = SKShapeNode(circleOfRadius: 10)
            dot.position = CGPoint(x: size.width / 2 - 32 + CGFloat(index * 32), y: size.height * 0.19)
            dot.fillColor = .cream
            dot.strokeColor = .manualYellow
            dot.lineWidth = 3
            addChild(dot)
            progressDots.append(dot)
        }
    }

    private func addFeedback() {
        feedbackLabel.fontName = GameFont.heavy
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
        label.fontName = GameFont.heavy
        label.fontSize = size
        label.fontColor = color
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        return label
    }
}
