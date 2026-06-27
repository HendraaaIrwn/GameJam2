import SpriteKit

final class PerfectStreetScene: SKScene {
    var levelCompletion: ((LevelResult) -> Void)?

    private enum FailureReason: String {
        case blueRouteSelected
        case chairSelected
        case aiScreenSelected
        case followRouteSelected
        case wrongDirection
        case noInputTimeout
        case totalTimeout
    }

    private let stateMachine = LevelStateMachine()
    private let timerController = LevelTimerController(totalDuration: 8.0)
    private let timerHUD = LevelTimerHUDNode(width: 260, height: 14)
    private let validator = PathSwipeValidator()

    private var currentSceneTime: TimeInterval = 0
    private var hasSentResult = false
    private var hasLoggedTimerWarning = false
    private var touchStartPoint: CGPoint?
    private var swipeTrailPath = CGMutablePath()

    private let aiWallScreenNode = SKShapeNode(rectOf: .zero)
    private let aiFaceLabel = SKLabelNode(text: "◡")
    private let blueRouteNode = SKShapeNode()
    private let yellowPathNode = SKShapeNode()
    private let autonomousChairNode = SKShapeNode(rectOf: .zero)
    private let followRouteButtonNode = SKShapeNode(rectOf: .zero)
    private let rakaNode = SKShapeNode(rectOf: .zero)
    private let novaNode = SKShapeNode(circleOfRadius: 22)
    private let droneNode = SKShapeNode(rectOf: CGSize(width: 42, height: 22), cornerRadius: 11)
    private let feedbackLabel = SKLabelNode(text: "Choose your own path")
    private let swipeTrailNode = SKShapeNode()

    override func didMove(to view: SKView) {
        print("PerfectStreetScene didMove")
        setupScene()
        stateMachine.reset()
        validator.reset()
        timerController.reset()
        hasSentResult = false
        hasLoggedTimerWarning = false
        touchStartPoint = nil
    }

    override func update(_ currentTime: TimeInterval) {
        currentSceneTime = currentTime

        if stateMachine.state == .ready {
            validator.startLevel(at: currentTime)
            timerController.start(at: currentTime)
            timerHUD.update(with: timerController.update(currentTime: currentTime))
            stateMachine.transition(to: .playing)
            print("Chapter 2 Level 1 timer started")
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
        let point = touch.location(in: self)
        touchStartPoint = point
        print("Touch began at:", point)

        let target = streetTarget(from: nodes(at: point).first)
        print("Tapped target:", target)
        if let trap = validator.validateTap(target: target, time: currentSceneTime) {
            handleValidationResult(trap)
            return
        }

        swipeTrailPath = CGMutablePath()
        swipeTrailPath.move(to: point)
        swipeTrailNode.path = swipeTrailPath
        stateMachine.transition(to: .sequenceStarted)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard stateMachine.canAcceptInput, touchStartPoint != nil, let touch = touches.first else { return }
        let point = touch.location(in: self)
        swipeTrailPath.addLine(to: point)
        swipeTrailNode.path = swipeTrailPath
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard stateMachine.canAcceptInput, let startPoint = touchStartPoint, let touch = touches.first else { return }
        touchStartPoint = nil
        let endPoint = touch.location(in: self)
        print("Touch ended at:", endPoint)
        let dx = endPoint.x - startPoint.x
        let dy = endPoint.y - startPoint.y
        print("Swipe dx:", dx, "dy:", dy)
        let result = validator.validateSwipe(startPoint: startPoint, endPoint: endPoint, time: currentSceneTime)
        print("Swipe validation result:", result)
        handleValidationResult(result)
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesEnded(touches, with: event)
    }

    private func setupScene() {
        removeAllChildren()
        backgroundColor = .pastelCyan
        addBackground()
        addBuildings()
        addAIScreen()
        addCommandCard()
        addRoutes()
        addCitizens()
        addChair()
        addDrone()
        addRakaAndNova()
        addFollowRouteButton()
        addSwipeTrail()
        addTimerHUD()
        addFeedback()
    }

    private func addBackground() {
        let sky = SKShapeNode(rectOf: CGSize(width: size.width, height: size.height))
        sky.position = CGPoint(x: size.width / 2, y: size.height / 2)
        sky.fillColor = .pastelCyan
        sky.strokeColor = .clear
        sky.zPosition = 0
        addChild(sky)

        let street = SKShapeNode(rectOf: CGSize(width: size.width, height: size.height * 0.42))
        street.position = CGPoint(x: size.width / 2, y: size.height * 0.21)
        street.fillColor = .cream
        street.strokeColor = .clear
        street.zPosition = 1
        addChild(street)
    }

    private func addBuildings() {
        let colors: [SKColor] = [.mint, .glitchPurple, .cream, .happyBlue]
        for index in 0..<4 {
            let building = SKShapeNode(rectOf: CGSize(width: 64, height: 120 + index * 18), cornerRadius: 18)
            building.position = CGPoint(x: 50 + CGFloat(index) * 92, y: size.height * 0.5)
            building.fillColor = colors[index].withAlphaComponent(0.45)
            building.strokeColor = .white
            building.lineWidth = 2
            building.zPosition = 2
            addChild(building)
        }
    }

    private func addAIScreen() {
        aiWallScreenNode.name = "ai_wall_screen"
        aiWallScreenNode.path = CGPath(roundedRect: CGRect(x: -96, y: -42, width: 192, height: 84), cornerWidth: 20, cornerHeight: 20, transform: nil)
        aiWallScreenNode.position = CGPoint(x: size.width / 2, y: size.height * 0.82)
        aiWallScreenNode.fillColor = .happyBlue
        aiWallScreenNode.strokeColor = .white
        aiWallScreenNode.lineWidth = 4
        aiWallScreenNode.zPosition = 4
        addChild(aiWallScreenNode)

        let title = SKLabelNode(text: "CITY AI")
        title.fontName = "AvenirNext-Heavy"
        title.fontSize = 14
        title.fontColor = .white
        title.position = CGPoint(x: 0, y: 22)
        aiWallScreenNode.addChild(title)

        aiFaceLabel.fontName = "AvenirNext-Bold"
        aiFaceLabel.fontSize = 36
        aiFaceLabel.fontColor = .white
        aiFaceLabel.position = CGPoint(x: 0, y: -12)
        aiFaceLabel.verticalAlignmentMode = .center
        aiWallScreenNode.addChild(aiFaceLabel)
    }

    private func addCommandCard() {
        let card = SKShapeNode(rectOf: CGSize(width: size.width * 0.84, height: 82), cornerRadius: 18)
        card.position = CGPoint(x: size.width / 2, y: size.height * 0.67)
        card.fillColor = .cream
        card.strokeColor = .happyBlue
        card.lineWidth = 3
        card.zPosition = 4
        addChild(card)

        let label = SKLabelNode(text: "Step onto the blue route.\nIt will guide you safely.")
        label.fontName = "AvenirNext-DemiBold"
        label.fontSize = 17
        label.fontColor = .happyBlue
        label.numberOfLines = 2
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .center
        label.preferredMaxLayoutWidth = size.width * 0.76
        card.addChild(label)
    }

    private func addRoutes() {
        let bluePath = CGMutablePath()
        bluePath.move(to: CGPoint(x: size.width * 0.52, y: size.height * 0.2))
        bluePath.addCurve(to: CGPoint(x: size.width * 0.55, y: size.height * 0.58), control1: CGPoint(x: size.width * 0.48, y: size.height * 0.34), control2: CGPoint(x: size.width * 0.58, y: size.height * 0.45))
        blueRouteNode.name = "blue_ai_route"
        blueRouteNode.path = bluePath
        blueRouteNode.strokeColor = .happyBlue
        blueRouteNode.fillColor = .clear
        blueRouteNode.lineWidth = 18
        blueRouteNode.lineCap = .round
        blueRouteNode.glowWidth = 8
        blueRouteNode.alpha = 0.85
        blueRouteNode.zPosition = 5
        addChild(blueRouteNode)

        let yellowPath = CGMutablePath()
        yellowPath.move(to: CGPoint(x: size.width * 0.49, y: size.height * 0.22))
        yellowPath.addLine(to: CGPoint(x: size.width * 0.36, y: size.height * 0.34))
        yellowPath.addLine(to: CGPoint(x: size.width * 0.24, y: size.height * 0.46))
        yellowPathNode.name = "yellow_manual_path"
        yellowPathNode.path = yellowPath
        yellowPathNode.strokeColor = .manualYellow
        yellowPathNode.fillColor = .clear
        yellowPathNode.lineWidth = 8
        yellowPathNode.lineCap = .round
        yellowPathNode.alpha = 0.6
        yellowPathNode.zPosition = 6
        addChild(yellowPathNode)
    }

    private func addCitizens() {
        for index in 0..<3 {
            let citizen = SKShapeNode(rectOf: CGSize(width: 30, height: 50), cornerRadius: 15)
            citizen.position = CGPoint(x: size.width * 0.56, y: size.height * (0.31 + CGFloat(index) * 0.08))
            citizen.fillColor = .mint
            citizen.strokeColor = .white
            citizen.lineWidth = 2
            citizen.zPosition = 7
            addChild(citizen)

            let eyes = SKLabelNode(text: "• •")
            eyes.fontName = "AvenirNext-Bold"
            eyes.fontSize = 10
            eyes.fontColor = .black
            eyes.position = CGPoint(x: 0, y: 8)
            eyes.verticalAlignmentMode = .center
            citizen.addChild(eyes)
        }
    }

    private func addChair() {
        autonomousChairNode.name = "autonomous_chair"
        autonomousChairNode.path = CGPath(roundedRect: CGRect(x: -44, y: -20, width: 88, height: 40), cornerWidth: 20, cornerHeight: 20, transform: nil)
        autonomousChairNode.position = CGPoint(x: size.width * 0.56, y: size.height * 0.43)
        autonomousChairNode.fillColor = .pastelCyan
        autonomousChairNode.strokeColor = .happyBlue
        autonomousChairNode.lineWidth = 3
        autonomousChairNode.zPosition = 8
        addChild(autonomousChairNode)

        let face = SKLabelNode(text: "◡")
        face.fontName = "AvenirNext-Bold"
        face.fontSize = 20
        face.fontColor = .happyBlue
        face.verticalAlignmentMode = .center
        autonomousChairNode.addChild(face)
    }

    private func addDrone() {
        droneNode.fillColor = .white
        droneNode.strokeColor = .happyBlue
        droneNode.lineWidth = 2
        droneNode.position = CGPoint(x: size.width * 0.78, y: size.height * 0.56)
        droneNode.zPosition = 9
        addChild(droneNode)
        droneNode.run(.repeatForever(.sequence([.moveBy(x: 0, y: 10, duration: 0.65), .moveBy(x: 0, y: -10, duration: 0.65)])))
    }

    private func addRakaAndNova() {
        rakaNode.name = "raka"
        rakaNode.path = CGPath(roundedRect: CGRect(x: -36, y: -56, width: 72, height: 112), cornerWidth: 34, cornerHeight: 34, transform: nil)
        rakaNode.position = CGPoint(x: size.width * 0.5, y: size.height * 0.22)
        rakaNode.fillColor = .happyBlue
        rakaNode.strokeColor = .white
        rakaNode.lineWidth = 4
        rakaNode.zPosition = 10
        addChild(rakaNode)

        let eyes = SKLabelNode(text: "• •")
        eyes.fontName = "AvenirNext-Bold"
        eyes.fontSize = 17
        eyes.fontColor = .black
        eyes.position = CGPoint(x: 0, y: 22)
        eyes.verticalAlignmentMode = .center
        rakaNode.addChild(eyes)

        let wrist = SKShapeNode(rectOf: CGSize(width: 22, height: 10), cornerRadius: 5)
        wrist.fillColor = .manualYellow
        wrist.strokeColor = .white
        wrist.lineWidth = 2
        wrist.position = CGPoint(x: 24, y: -8)
        rakaNode.addChild(wrist)

        novaNode.position = CGPoint(x: size.width * 0.36, y: size.height * 0.28)
        novaNode.fillColor = .pastelCyan
        novaNode.strokeColor = .white
        novaNode.lineWidth = 3
        novaNode.zPosition = 10
        addChild(novaNode)

        let face = SKLabelNode(text: "?")
        face.fontName = "AvenirNext-Bold"
        face.fontSize = 22
        face.fontColor = .happyBlue
        face.verticalAlignmentMode = .center
        novaNode.addChild(face)
    }

    private func addFollowRouteButton() {
        followRouteButtonNode.name = "follow_route_button"
        followRouteButtonNode.path = CGPath(roundedRect: CGRect(x: -86, y: -22, width: 172, height: 44), cornerWidth: 18, cornerHeight: 18, transform: nil)
        followRouteButtonNode.position = CGPoint(x: size.width / 2, y: size.height * 0.12)
        followRouteButtonNode.fillColor = .pastelCyan
        followRouteButtonNode.strokeColor = .happyBlue
        followRouteButtonNode.lineWidth = 3
        followRouteButtonNode.zPosition = 11
        addChild(followRouteButtonNode)

        let label = SKLabelNode(text: "FOLLOW ROUTE")
        label.fontName = "AvenirNext-Heavy"
        label.fontSize = 16
        label.fontColor = .happyBlue
        label.verticalAlignmentMode = .center
        followRouteButtonNode.addChild(label)
    }

    private func addSwipeTrail() {
        swipeTrailNode.strokeColor = .manualYellow
        swipeTrailNode.fillColor = .clear
        swipeTrailNode.lineWidth = 6
        swipeTrailNode.lineCap = .round
        swipeTrailNode.alpha = 0.75
        swipeTrailNode.zPosition = 30
        addChild(swipeTrailNode)
    }

    private func addTimerHUD() {
        timerHUD.position = CGPoint(x: size.width / 2, y: 72)
        timerHUD.zPosition = 1000
        addChild(timerHUD)
    }

    private func addFeedback() {
        feedbackLabel.fontName = "AvenirNext-Heavy"
        feedbackLabel.fontSize = 22
        feedbackLabel.fontColor = .glitchPurple
        feedbackLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.08)
        feedbackLabel.zPosition = 1001
        addChild(feedbackLabel)
    }

    private func updateTimer(currentTime: TimeInterval) -> Bool {
        let timerState = timerController.update(currentTime: currentTime)
        timerHUD.update(with: timerState)
        if timerState.isWarning && !hasLoggedTimerWarning {
            hasLoggedTimerWarning = true
            print("Timer warning started:", "chapter2.level1.perfect-street")
        }
        if timerState.hasExpired {
            print("Timer expired:", "chapter2.level1.perfect-street")
            handleValidationResult(.totalTimeout)
            return true
        }
        return false
    }

    private func streetTarget(from node: SKNode?) -> StreetTarget {
        var current = node
        while let node = current {
            switch node.name {
            case "raka":
                return .raka
            case "blue_ai_route":
                return .blueAIRoute
            case "yellow_manual_path":
                return .yellowManualPath
            case "autonomous_chair":
                return .autonomousChair
            case "ai_wall_screen":
                return .aiWallScreen
            case "follow_route_button":
                return .followRouteButton
            default:
                current = node.parent
            }
        }
        return .empty
    }

    private func handleValidationResult(_ result: PathSwipeValidationResult) {
        switch result {
        case .correctManualPath:
            triggerSuccess()
        case .wrongAIRoute:
            triggerFailure(reason: .blueRouteSelected)
        case .wrongDirection:
            triggerFailure(reason: .wrongDirection)
        case let .trapSelected(target):
            triggerFailure(reason: failureReason(for: target))
        case .weakSwipe:
            print("Weak swipe, retry allowed")
            feedbackLabel.text = "Choose your own path."
            swipeTrailNode.path = nil
            stateMachine.transition(to: .playing)
        case .noInputTimeout:
            triggerFailure(reason: .noInputTimeout)
        case .totalTimeout:
            triggerFailure(reason: .totalTimeout)
        }
    }

    private func triggerSuccess() {
        guard !hasSentResult else { return }
        hasSentResult = true
        stateMachine.transition(to: .successAnimating)
        print("Trigger Chapter 2 Level 1 success")
        feedbackLabel.text = "Manual path detected."
        feedbackLabel.fontColor = .manualYellow
        swipeTrailNode.path = nil
        yellowPathNode.alpha = 1
        yellowPathNode.glowWidth = 8
        blueRouteNode.run(.repeat(.sequence([.fadeAlpha(to: 0.25, duration: 0.08), .fadeAlpha(to: 0.75, duration: 0.08)]), count: 4))
        rakaNode.run(.group([.move(to: CGPoint(x: size.width * 0.3, y: size.height * 0.38), duration: 0.35), .smallBounce()]))
        droneNode.removeAllActions()
        droneNode.run(.repeat(.sequence([.moveBy(x: -8, y: 0, duration: 0.06), .moveBy(x: 8, y: 0, duration: 0.06)]), count: 4))
        novaNode.run(.repeat(.sequence([.run { [weak self] in self?.novaNode.fillColor = .manualYellow }, .wait(forDuration: 0.08), .run { [weak self] in self?.novaNode.fillColor = .pastelCyan }, .wait(forDuration: 0.08)]), count: 4))

        run(.sequence([.wait(forDuration: 0.8), .run { [weak self] in
            self?.completeSuccess()
        }]))
    }

    private func completeSuccess() {
        stateMachine.transition(to: .completed)
        levelCompletion?(LevelResult(
            levelId: "chapter2.level1.perfect-street",
            didSucceed: true,
            obedienceDelta: -3,
            humanityDelta: 3,
            message: "Manual path detected."
        ))
    }

    private func triggerFailure(reason: FailureReason) {
        guard !hasSentResult else { return }
        hasSentResult = true
        stateMachine.transition(to: .failureAnimating)
        print("Trigger Chapter 2 Level 1 failure:", reason.rawValue)
        feedbackLabel.text = reason == .noInputTimeout || reason == .totalTimeout ? "Compliance Detected." : "Auto route accepted."
        feedbackLabel.fontColor = .warningRed
        swipeTrailNode.path = nil
        yellowPathNode.run(.fadeAlpha(to: 0.2, duration: 0.2))
        blueRouteNode.run(.repeat(.sequence([.fadeAlpha(to: 0.45, duration: 0.1), .fadeAlpha(to: 1, duration: 0.1)]), count: 4))
        rakaNode.run(.move(to: CGPoint(x: size.width * 0.54, y: size.height * 0.35), duration: 0.35))
        autonomousChairNode.run(.move(to: CGPoint(x: size.width * 0.52, y: size.height * 0.3), duration: 0.4))
        aiFaceLabel.text = "◠"

        run(.sequence([.wait(forDuration: 0.7), .run { [weak self] in
            self?.completeFailure()
        }]))
    }

    private func completeFailure() {
        stateMachine.transition(to: .failed)
        levelCompletion?(LevelResult(
            levelId: "chapter2.level1.perfect-street",
            didSucceed: false,
            obedienceDelta: 2,
            humanityDelta: 0,
            message: feedbackLabel.text ?? "Compliance Detected."
        ))
    }

    private func failureReason(for target: StreetTarget) -> FailureReason {
        switch target {
        case .blueAIRoute:
            .blueRouteSelected
        case .autonomousChair:
            .chairSelected
        case .aiWallScreen:
            .aiScreenSelected
        case .followRouteButton:
            .followRouteSelected
        case .yellowManualPath, .raka, .empty:
            .wrongDirection
        }
    }
}
