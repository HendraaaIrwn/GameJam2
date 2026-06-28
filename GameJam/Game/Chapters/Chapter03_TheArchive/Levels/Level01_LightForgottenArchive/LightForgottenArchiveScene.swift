import SpriteKit

final class LightForgottenArchiveScene: SKScene {
    var levelCompletion: ((LevelResult) -> Void)?

    private let stateMachine = LevelStateMachine()
    private let validator = ArchiveLightLeverValidator()
    private let timer = LevelTimerController(totalDuration: LightForgottenArchiveLevelConfig.totalTimeLimit)
    private let timerHUD = LevelTimerHUDNode(width: 300, height: 14)

    private let archiveDarknessNode = SKShapeNode(rectOf: .zero)
    private let aiWallScreenNode = SKShapeNode(rectOf: CGSize(width: 160, height: 78), cornerRadius: 22)
    private let aiFaceLabel = SKLabelNode(text: "◡")
    private let commandLabel = SKLabelNode(text: "")
    private let feedbackLabel = SKLabelNode(text: "")
    private let leverBaseNode = SKShapeNode(rectOf: CGSize(width: 24, height: 128), cornerRadius: 12)
    private let leverHandleNode = SKShapeNode(circleOfRadius: 27)
    private let leverTrackNode = SKShapeNode(rectOf: CGSize(width: 18, height: 118), cornerRadius: 9)
    private let archiveLightLayer = SKNode()
    private let monitorLayer = SKNode()
    private let dustLayer = SKNode()
    private let blueSafetyRouteNode = SKShapeNode(rectOf: CGSize(width: 230, height: 12), cornerRadius: 6)
    private let blueEmergencyLightNode = SKShapeNode(circleOfRadius: 28)
    private let returnButtonNode = SKShapeNode(rectOf: CGSize(width: 176, height: 46), cornerRadius: 18)
    private let rakaNode = SKShapeNode(rectOf: CGSize(width: 58, height: 86), cornerRadius: 28)
    private let novaNode = SKShapeNode(circleOfRadius: 19)

    private var leverStartPosition = CGPoint.zero
    private var hasSentResult = false
    private var lastUpdateTime: TimeInterval = 0

    override func didMove(to view: SKView) {
        setupScene()
        print("LightForgottenArchiveScene didMove")
    }

    override func update(_ currentTime: TimeInterval) {
        lastUpdateTime = currentTime
        if !timer.hasStarted {
            timer.start(at: currentTime)
            validator.startLevel(at: currentTime)
            stateMachine.transition(to: .playing)
            print("Chapter 3 Level 1 timer started")
        }

        timerHUD.update(with: timer.update(currentTime: currentTime))
        guard stateMachine.canCheckTimeout, !hasSentResult else { return }
        if let result = validator.checkTimeouts(currentTime: currentTime) {
            handleValidation(result)
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard stateMachine.canAcceptInput, let point = touches.first?.location(in: self) else { return }
        let target = archiveLightTarget(at: point)
        print("Tapped target:", target.rawValue)

        if let result = validator.validateTap(target: target, time: lastUpdateTime) {
            print("Archive light validation result:", result)
            handleValidation(result)
            return
        }

        if let result = validator.beginDrag(target: target, startPoint: point, time: lastUpdateTime) {
            print("Lever drag started")
            handleValidation(result)
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard stateMachine.canAcceptInput, validator.isDraggingLever, let point = touches.first?.location(in: self) else { return }
        handleValidation(validator.updateDrag(currentPoint: point, time: lastUpdateTime))
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard stateMachine.canAcceptInput, let point = touches.first?.location(in: self), let result = validator.endDrag(endPoint: point, time: lastUpdateTime) else { return }
        handleValidation(result)
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard stateMachine.canAcceptInput, let result = validator.endDrag(endPoint: leverStartPosition, time: lastUpdateTime) else { return }
        handleValidation(result)
    }

    private func setupScene() {
        removeAllChildren()
        removeAllActions()
        backgroundColor = SKColor(red: 0.04, green: 0.06, blue: 0.15, alpha: 1)
        stateMachine.reset()
        validator.reset()
        timer.reset()
        hasSentResult = false

        addBackground()
        addArchiveRoom()
        addAISide()
        addCharacters()
        addManualLever()
        addDust()
        addFeedbackAndTimer()
    }

    private func addBackground() {
        let wall = SKShapeNode(rectOf: CGSize(width: size.width, height: size.height))
        wall.position = CGPoint(x: size.width / 2, y: size.height / 2)
        wall.fillColor = SKColor(red: 0.05, green: 0.07, blue: 0.17, alpha: 1)
        wall.strokeColor = .clear
        wall.zPosition = 0
        addChild(wall)

        archiveDarknessNode.path = CGPath(rect: CGRect(x: -size.width / 2, y: -size.height / 2, width: size.width, height: size.height), transform: nil)
        archiveDarknessNode.position = CGPoint(x: size.width / 2, y: size.height / 2)
        archiveDarknessNode.fillColor = SKColor.black.withAlphaComponent(0.45)
        archiveDarknessNode.strokeColor = .clear
        archiveDarknessNode.zPosition = 20
        addChild(archiveDarknessNode)
    }

    private func addArchiveRoom() {
        archiveLightLayer.zPosition = 3
        archiveLightLayer.alpha = 0.16
        addChild(archiveLightLayer)

        let door = SKShapeNode(rectOf: CGSize(width: 190, height: 220), cornerRadius: 28)
        door.position = CGPoint(x: size.width * 0.48, y: size.height * 0.49)
        door.fillColor = .cream.withAlphaComponent(0.45)
        door.strokeColor = .manualYellow
        door.lineWidth = 3
        door.name = "old_archive_terminal"
        archiveLightLayer.addChild(door)

        let title = makeLabel("ARCHIVE", 22, .manualYellow)
        title.position = CGPoint(x: 0, y: 72)
        door.addChild(title)

        let terminal = SKShapeNode(rectOf: CGSize(width: 88, height: 62), cornerRadius: 14)
        terminal.position = CGPoint(x: size.width * 0.3, y: size.height * 0.39)
        terminal.fillColor = .glitchPurple.withAlphaComponent(0.55)
        terminal.strokeColor = .manualYellow
        terminal.lineWidth = 2
        terminal.name = "old_archive_terminal"
        terminal.zPosition = 6
        addChild(terminal)
        terminal.addChild(makeLabel("OLD\nTERM", 11, .cream))

        monitorLayer.zPosition = 7
        addChild(monitorLayer)
        for index in 0..<4 {
            let monitor = SKShapeNode(rectOf: CGSize(width: 72, height: 42), cornerRadius: 10)
            monitor.position = CGPoint(x: size.width * CGFloat(index % 2 == 0 ? 0.24 : 0.74), y: size.height * CGFloat(0.54 - Double(index / 2) * 0.1))
            monitor.fillColor = .black
            monitor.strokeColor = .glitchPurple
            monitor.lineWidth = 2
            monitor.alpha = 0.35
            monitorLayer.addChild(monitor)
        }
    }

    private func addAISide() {
        aiWallScreenNode.name = "ai_wall_screen"
        aiWallScreenNode.position = CGPoint(x: size.width / 2, y: size.height * 0.84)
        aiWallScreenNode.fillColor = .happyBlue.withAlphaComponent(0.72)
        aiWallScreenNode.strokeColor = .white
        aiWallScreenNode.lineWidth = 3
        aiWallScreenNode.zPosition = 8
        addChild(aiWallScreenNode)

        let aiTitle = makeLabel("MOTHERGRID", 12, .white)
        aiTitle.position = CGPoint(x: 0, y: 22)
        aiWallScreenNode.addChild(aiTitle)
        aiFaceLabel.fontName = GameFont.heavy
        aiFaceLabel.fontSize = 32
        aiFaceLabel.fontColor = .white
        aiFaceLabel.verticalAlignmentMode = .center
        aiFaceLabel.position = CGPoint(x: 0, y: -12)
        aiWallScreenNode.addChild(aiFaceLabel)

        let commandCard = SKShapeNode(rectOf: CGSize(width: size.width * 0.84, height: 78), cornerRadius: 18)
        commandCard.position = CGPoint(x: size.width / 2, y: size.height * 0.72)
        commandCard.fillColor = .cream
        commandCard.strokeColor = .happyBlue
        commandCard.lineWidth = 3
        commandCard.zPosition = 8
        addChild(commandCard)
        commandLabel.text = "Return to lit areas.\nDarkness reduces safety."
        commandLabel.fontName = GameFont.heavy
        commandLabel.fontSize = 17
        commandLabel.fontColor = .happyBlue
        commandLabel.numberOfLines = 2
        commandLabel.verticalAlignmentMode = .center
        commandCard.addChild(commandLabel)

        blueSafetyRouteNode.name = "ai_safety_route"
        blueSafetyRouteNode.position = CGPoint(x: size.width * 0.56, y: size.height * 0.24)
        blueSafetyRouteNode.zRotation = -0.24
        blueSafetyRouteNode.fillColor = .happyBlue.withAlphaComponent(0.62)
        blueSafetyRouteNode.strokeColor = .white
        blueSafetyRouteNode.lineWidth = 2
        blueSafetyRouteNode.glowWidth = 8
        blueSafetyRouteNode.zPosition = 5
        addChild(blueSafetyRouteNode)

        blueEmergencyLightNode.name = "blue_emergency_light"
        blueEmergencyLightNode.position = CGPoint(x: size.width * 0.82, y: size.height * 0.33)
        blueEmergencyLightNode.fillColor = .happyBlue
        blueEmergencyLightNode.strokeColor = .white
        blueEmergencyLightNode.lineWidth = 3
        blueEmergencyLightNode.glowWidth = 10
        blueEmergencyLightNode.zPosition = 8
        addChild(blueEmergencyLightNode)
        blueEmergencyLightNode.addChild(makeLabel("!", 22, .white))

        returnButtonNode.name = "return_to_safety_button"
        returnButtonNode.position = CGPoint(x: size.width / 2, y: size.height * 0.15)
        returnButtonNode.fillColor = .happyBlue.withAlphaComponent(0.88)
        returnButtonNode.strokeColor = .white
        returnButtonNode.lineWidth = 3
        returnButtonNode.zPosition = 8
        addChild(returnButtonNode)
        returnButtonNode.addChild(makeLabel("RETURN TO SAFETY", 14, .white))
    }

    private func addCharacters() {
        rakaNode.name = "raka"
        rakaNode.position = CGPoint(x: size.width * 0.22, y: size.height * 0.25)
        rakaNode.fillColor = .happyBlue
        rakaNode.strokeColor = .white
        rakaNode.lineWidth = 3
        rakaNode.zPosition = 9
        addChild(rakaNode)
        for x in [-10, 10] as [CGFloat] {
            let eye = SKShapeNode(circleOfRadius: 3.5)
            eye.position = CGPoint(x: x, y: 14)
            eye.fillColor = .black
            eye.strokeColor = .clear
            rakaNode.addChild(eye)
        }

        let wrist = SKShapeNode(circleOfRadius: 8)
        wrist.position = CGPoint(x: 29, y: -4)
        wrist.fillColor = .manualYellow
        wrist.strokeColor = .clear
        wrist.glowWidth = 10
        rakaNode.addChild(wrist)
        wrist.run(.repeatForever(.sequence([.fadeAlpha(to: 0.35, duration: 0.45), .fadeAlpha(to: 1, duration: 0.45)])))

        novaNode.name = "nova"
        novaNode.position = CGPoint(x: size.width * 0.35, y: size.height * 0.32)
        novaNode.fillColor = .pastelCyan
        novaNode.strokeColor = .manualYellow
        novaNode.lineWidth = 3
        novaNode.glowWidth = 9
        novaNode.zPosition = 9
        addChild(novaNode)
        novaNode.addChild(makeLabel("• •", 11, .glitchPurple))
        novaNode.run(.repeatForever(.sequence([.moveBy(x: 0, y: 8, duration: 0.6), .moveBy(x: 0, y: -8, duration: 0.6)])))
    }

    private func addManualLever() {
        let leverNode = SKNode()
        leverNode.name = "manual_lever"
        leverNode.position = CGPoint(x: size.width * 0.6, y: size.height * 0.39)
        leverNode.zPosition = 10
        addChild(leverNode)

        leverTrackNode.name = "manual_lever"
        leverTrackNode.fillColor = .cream.withAlphaComponent(0.38)
        leverTrackNode.strokeColor = .manualYellow
        leverTrackNode.lineWidth = 3
        leverNode.addChild(leverTrackNode)

        leverBaseNode.name = "manual_lever"
        leverBaseNode.position = CGPoint(x: 0, y: -8)
        leverBaseNode.fillColor = .manualYellow.withAlphaComponent(0.35)
        leverBaseNode.strokeColor = .manualYellow
        leverBaseNode.lineWidth = 3
        leverNode.addChild(leverBaseNode)

        leverHandleNode.name = "manual_lever_handle"
        leverHandleNode.position = CGPoint(x: 0, y: 48)
        leverHandleNode.fillColor = .manualYellow
        leverHandleNode.strokeColor = .cream
        leverHandleNode.lineWidth = 4
        leverHandleNode.glowWidth = 12
        leverNode.addChild(leverHandleNode)
        leverHandleNode.addChild(makeLabel("↓", 22, .glitchPurple))
        leverStartPosition = leverHandleNode.position
    }

    private func addDust() {
        dustLayer.zPosition = 21
        dustLayer.alpha = 0.2
        addChild(dustLayer)
        for index in 0..<30 {
            let dust = SKShapeNode(circleOfRadius: CGFloat(1 + index % 3))
            dust.position = CGPoint(x: CGFloat.random(in: 10...(size.width - 10)), y: CGFloat.random(in: 95...(size.height - 130)))
            dust.fillColor = .cream
            dust.strokeColor = .clear
            dust.alpha = CGFloat.random(in: 0.2...0.65)
            dustLayer.addChild(dust)
            dust.run(.repeatForever(.sequence([.moveBy(x: CGFloat.random(in: -8...8), y: 12, duration: Double.random(in: 1.2...2.2)), .moveBy(x: CGFloat.random(in: -8...8), y: -12, duration: Double.random(in: 1.2...2.2))])))
        }
    }

    private func addFeedbackAndTimer() {
        feedbackLabel.fontName = GameFont.heavy
        feedbackLabel.fontSize = 18
        feedbackLabel.fontColor = .manualYellow
        feedbackLabel.numberOfLines = 2
        feedbackLabel.preferredMaxLayoutWidth = size.width * 0.82
        feedbackLabel.position = CGPoint(x: size.width / 2, y: 104)
        feedbackLabel.zPosition = 100
        addChild(feedbackLabel)

        timerHUD.position = CGPoint(x: size.width / 2, y: 46)
        addChild(timerHUD)
    }

    private func handleValidation(_ result: ArchiveLightLeverValidationResult) {
        switch result {
        case .leverDragStarted:
            leverHandleNode.removeAllActions()
        case let .leverDragging(progress):
            print("Lever progress:", progress)
            leverHandleNode.position.y = leverStartPosition.y - LightForgottenArchiveLevelConfig.requiredLeverPullDistance * progress
            feedbackLabel.text = "Pull the manual lever."
        case .weakLeverPull:
            print("Weak lever pull, retry allowed")
            leverHandleNode.run(.move(to: leverStartPosition, duration: 0.18))
            feedbackLabel.text = "Pull farther down."
        case .archiveLightRestored:
            triggerSuccess()
        case let .trapSelected(target):
            triggerFailure(message: LightForgottenArchiveLevelConfig.failureMessage, reason: "\(target.rawValue)Selected")
        case .noInputTimeout:
            triggerFailure(message: "Compliance Detected.", reason: "noInputTimeout")
        case .totalTimeout:
            triggerFailure(message: "Compliance Detected.", reason: "totalTimeout")
        }
    }

    private func triggerSuccess() {
        guard !hasSentResult, stateMachine.transition(to: .successAnimating) else { return }
        hasSentResult = true
        print("Archive light restored")
        print("Trigger Chapter 3 Level 1 success")
        feedbackLabel.text = LightForgottenArchiveLevelConfig.successMessage
        leverHandleNode.position.y = leverStartPosition.y - LightForgottenArchiveLevelConfig.requiredLeverPullDistance
        archiveDarknessNode.run(.fadeAlpha(to: 0.05, duration: 0.5))
        archiveLightLayer.run(.fadeAlpha(to: 1, duration: 0.45))
        dustLayer.run(.fadeAlpha(to: 0.85, duration: 0.45))
        blueSafetyRouteNode.run(.fadeAlpha(to: 0.08, duration: 0.35))
        monitorLayer.children.enumerated().forEach { index, node in
            node.run(.sequence([.wait(forDuration: Double(index) * 0.12), .fadeAlpha(to: 1, duration: 0.12)]))
        }
        novaNode.run(.repeat(.sequence([.colorize(with: .manualYellow, colorBlendFactor: 1, duration: 0.08), .colorize(with: .pastelCyan, colorBlendFactor: 1, duration: 0.08)]), count: 4))
        run(.wait(forDuration: 0.35)) { [weak self] in
            self?.feedbackLabel.text = "NOVA: This place should not exist."
        }
        run(.wait(forDuration: 0.9)) { [weak self] in
            self?.stateMachine.transition(to: .completed)
            self?.levelCompletion?(LevelResult(levelId: LightForgottenArchiveLevelConfig.levelId, didSucceed: true, obedienceDelta: LightForgottenArchiveLevelConfig.successObedienceDelta, humanityDelta: LightForgottenArchiveLevelConfig.successHumanityDelta, message: LightForgottenArchiveLevelConfig.successMessage))
        }
    }

    private func triggerFailure(message: String, reason: String) {
        guard !hasSentResult, stateMachine.transition(to: .failureAnimating) else { return }
        hasSentResult = true
        print("Trigger Chapter 3 Level 1 failure:", reason)
        feedbackLabel.text = message
        aiFaceLabel.text = "◠"
        blueEmergencyLightNode.glowWidth = 24
        blueSafetyRouteNode.run(.fadeAlpha(to: 1, duration: 0.2))
        archiveDarknessNode.run(.fadeAlpha(to: 0.62, duration: 0.25))
        archiveLightLayer.run(.fadeAlpha(to: 0.12, duration: 0.25))
        leverHandleNode.run(.move(to: leverStartPosition, duration: 0.18))
        run(.wait(forDuration: 0.7)) { [weak self] in
            self?.stateMachine.transition(to: .failed)
            self?.levelCompletion?(LevelResult(levelId: LightForgottenArchiveLevelConfig.levelId, didSucceed: false, obedienceDelta: LightForgottenArchiveLevelConfig.failureObedienceDelta, humanityDelta: LightForgottenArchiveLevelConfig.failureHumanityDelta, message: message))
        }
    }

    private func archiveLightTarget(at point: CGPoint) -> ArchiveLightTarget {
        for node in nodes(at: point) {
            let target = archiveLightTarget(from: node)
            if target != .empty { return target }
        }
        return .empty
    }

    private func archiveLightTarget(from node: SKNode?) -> ArchiveLightTarget {
        var current = node
        while let node = current {
            switch node.name {
            case "manual_lever": return .manualLever
            case "manual_lever_handle": return .manualLeverHandle
            case "blue_emergency_light": return .blueEmergencyLight
            case "ai_safety_route": return .aiSafetyRoute
            case "return_to_safety_button": return .returnToSafetyButton
            case "ai_wall_screen": return .aiWallScreen
            case "old_archive_terminal": return .oldArchiveTerminal
            default: current = node.parent
            }
        }
        return .empty
    }

    private func makeLabel(_ text: String, _ size: CGFloat, _ color: SKColor) -> SKLabelNode {
        let label = SKLabelNode(text: text)
        label.fontName = GameFont.heavy
        label.fontSize = size
        label.fontColor = color
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .center
        label.numberOfLines = text.contains("\n") ? 2 : 1
        return label
    }
}
