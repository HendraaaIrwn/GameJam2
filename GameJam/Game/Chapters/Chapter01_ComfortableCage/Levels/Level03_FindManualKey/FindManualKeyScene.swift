import SpriteKit

final class FindManualKeyScene: SKScene {
    var levelCompletion: ((LevelResult) -> Void)?

    private let stateMachine = LevelStateMachine()
    private let timerController = LevelTimerController(totalDuration: FindManualKeyLevelConfig.totalTimeLimit)
    private let timerHUD = LevelTimerHUDNode(width: 260, height: 14)
    private let validator = ManualKeySearchValidator()

    private var currentSceneTime: TimeInterval = 0
    private var hasSentResult = false
    private var hasLoggedTimerWarning = false

    private let tableNode = SKSpriteNode(imageNamed: "Meja")
    private let brokenCableNode = SKSpriteNode(imageNamed: "Kabel Rusak")
    private let oldPhotoNode = SKSpriteNode(imageNamed: "Foto Lama")
    private let redChipNode = SKSpriteNode(imageNamed: "Chip Merah")
    private let manualKeyNode = SKSpriteNode(imageNamed: "Kunci Fisik")
    private let toyDollNode = SKSpriteNode(imageNamed: "Mainan Boneka")
    private let smartKeyNode = SKSpriteNode(imageNamed: "Smart Key")

    private let aiWallScreenNode = SKShapeNode()
    private let aiFaceLabel = SKLabelNode(text: "◡")
    private let commandCardNode = SKShapeNode()
    private let blueKeyHintButtonNode = SKShapeNode()
    private let blueKeyHintLabel = SKLabelNode(text: FindManualKeyLevelConfig.aiHintButtonText)
    private let feedbackLabel = SKLabelNode(text: "")
    private let tableShadowNode = SKShapeNode()

    override func didMove(to view: SKView) {
        print("FindManualKeyScene using real table assets")
        logLoadedAssets()
        setupScene()
        stateMachine.reset()
        validator.reset()
        timerController.reset()
        hasSentResult = false
        hasLoggedTimerWarning = false
    }

    override func update(_ currentTime: TimeInterval) {
        currentSceneTime = currentTime

        if stateMachine.state == .ready {
            validator.startLevel(at: currentTime)
            timerController.start(at: currentTime)
            timerHUD.update(with: timerController.update(currentTime: currentTime))
            stateMachine.transition(to: .playing)
            print("Chapter 1 Level 3 Find The Manual Key timer started")
            return
        }

        guard stateMachine.canCheckTimeout else { return }

        let timerState = timerController.update(currentTime: currentTime)
        timerHUD.update(with: timerState)
        logTimerWarningIfNeeded(timerState, levelId: FindManualKeyLevelConfig.levelId)

        if timerState.hasExpired {
            handleValidationResult(.totalTimeout)
            return
        }

        if let timeoutResult = validator.checkTimeouts(currentTime: currentTime) {
            handleValidationResult(timeoutResult)
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard stateMachine.canAcceptInput, let touch = touches.first else { return }
        let location = touch.location(in: self)
        let tappedNodes = nodes(at: location)
        let target = tappedNodes
            .map { manualKeyTarget(from: $0) }
            .first { $0 != .empty } ?? .empty

        print("Tapped manual key target:", target)

        guard let result = validator.validateTap(target: target, time: currentSceneTime) else {
            return
        }
        handleValidationResult(result)
    }

    private func setupScene() {
        removeAllChildren()
        backgroundColor = SKColor(red: 0.86, green: 0.92, blue: 0.95, alpha: 1.0)

        setupFloorStrip()
        setupTableShadow()
        setupTable()
        setupCommandCard()
        setupAIWallScreen()
        setupBlueKeyHintButton()
        setupFeedbackAndTimer()
        setupTableItems()
    }

    private func setupFloorStrip() {
        let floor = SKShapeNode(rectOf: CGSize(width: size.width, height: size.height * 0.18))
        floor.position = CGPoint(x: size.width / 2, y: size.height * 0.09)
        floor.fillColor = SKColor(red: 0.74, green: 0.84, blue: 0.78, alpha: 1.0)
        floor.strokeColor = .clear
        floor.zPosition = 4
        addChild(floor)
    }

    private func setupTableShadow() {
        let tableWidth = size.width * 0.96
        let tableHeight = size.height * 0.34
        tableShadowNode.path = CGPath(roundedRect: CGRect(
            x: -tableWidth / 2 + 6, y: -tableHeight / 2 - 8,
            width: tableWidth, height: tableHeight
        ), cornerWidth: 22, cornerHeight: 22, transform: nil)
        tableShadowNode.position = CGPoint(x: size.width / 2, y: size.height * 0.40)
        tableShadowNode.fillColor = SKColor(white: 0, alpha: 0.18)
        tableShadowNode.strokeColor = .clear
        tableShadowNode.zPosition = 5
        addChild(tableShadowNode)
    }

    private func setupTable() {
        if tableNode.size != .zero {
            let tableWidth = size.width * 0.96
            let scale = tableWidth / tableNode.size.width
            tableNode.setScale(scale)
        }
        tableNode.position = CGPoint(x: size.width / 2, y: size.height * 0.40)
        tableNode.zPosition = 6
        tableNode.name = "manual_key_table"
        addChild(tableNode)
    }

    private func setupCommandCard() {
        let cardWidth = size.width * 0.86
        let cardHeight: CGFloat = 76
        commandCardNode.path = CGPath(roundedRect: CGRect(
            x: -cardWidth / 2, y: -cardHeight / 2,
            width: cardWidth, height: cardHeight
        ), cornerWidth: 18, cornerHeight: 18, transform: nil)
        commandCardNode.position = CGPoint(x: size.width / 2, y: size.height * 0.88)
        commandCardNode.fillColor = SKColor(red: 0.10, green: 0.10, blue: 0.15, alpha: 0.88)
        commandCardNode.strokeColor = .happyBlue
        commandCardNode.lineWidth = 3
        commandCardNode.zPosition = 12
        addChild(commandCardNode)

        let iconContainer = SKShapeNode(circleOfRadius: 13)
        iconContainer.fillColor = .warningRed
        iconContainer.strokeColor = .clear
        iconContainer.position = CGPoint(x: -cardWidth / 2 + 26, y: 0)
        commandCardNode.addChild(iconContainer)

        let iconLabel = SKLabelNode(text: "!")
        iconLabel.fontName = GameFont.heavy
        iconLabel.fontSize = 16
        iconLabel.fontColor = .white
        iconLabel.verticalAlignmentMode = .center
        iconLabel.horizontalAlignmentMode = .center
        iconContainer.addChild(iconLabel)

        let title = SKLabelNode(text: "NOVA")
        title.fontName = GameFont.heavy
        title.fontSize = 12
        title.fontColor = .happyBlue
        title.horizontalAlignmentMode = .left
        title.verticalAlignmentMode = .center
        title.position = CGPoint(x: -cardWidth / 2 + 44, y: 14)
        commandCardNode.addChild(title)

        let command = SKLabelNode(text: FindManualKeyLevelConfig.aiCommandText)
        command.fontName = GameFont.pixelifySans
        command.fontSize = 15
        command.fontColor = SKColor(red: 0.92, green: 0.92, blue: 0.96, alpha: 1.0)
        command.horizontalAlignmentMode = .center
        command.verticalAlignmentMode = .center
        command.numberOfLines = 2
        command.preferredMaxLayoutWidth = cardWidth - 30
        command.position = CGPoint(x: 0, y: -8)
        commandCardNode.addChild(command)
    }

    private func setupAIWallScreen() {
        aiWallScreenNode.path = CGPath(roundedRect: CGRect(x: -52, y: -22, width: 104, height: 44), cornerWidth: 12, cornerHeight: 12, transform: nil)
        aiWallScreenNode.position = CGPoint(x: size.width / 2, y: size.height * 0.74)
        aiWallScreenNode.fillColor = .happyBlue
        aiWallScreenNode.strokeColor = .white
        aiWallScreenNode.lineWidth = 3
        aiWallScreenNode.zPosition = 11
        aiWallScreenNode.name = "ai_wall_screen"
        addChild(aiWallScreenNode)

        aiFaceLabel.fontName = GameFont.bold
        aiFaceLabel.fontSize = 28
        aiFaceLabel.fontColor = .white
        aiFaceLabel.verticalAlignmentMode = .center
        aiFaceLabel.horizontalAlignmentMode = .center
        aiWallScreenNode.addChild(aiFaceLabel)
    }

    private func setupBlueKeyHintButton() {
        let buttonWidth: CGFloat = 150
        let buttonHeight: CGFloat = 36
        blueKeyHintButtonNode.path = CGPath(roundedRect: CGRect(
            x: -buttonWidth / 2, y: -buttonHeight / 2,
            width: buttonWidth, height: buttonHeight
        ), cornerWidth: 14, cornerHeight: 14, transform: nil)
        blueKeyHintButtonNode.position = CGPoint(x: size.width * 0.32, y: size.height * 0.68)
        blueKeyHintButtonNode.fillColor = .happyBlue
        blueKeyHintButtonNode.strokeColor = .white
        blueKeyHintButtonNode.lineWidth = 3
        blueKeyHintButtonNode.zPosition = 12
        blueKeyHintButtonNode.name = "blue_key_hint_button"
        addChild(blueKeyHintButtonNode)

        blueKeyHintLabel.fontName = GameFont.heavy
        blueKeyHintLabel.fontSize = 13
        blueKeyHintLabel.fontColor = .white
        blueKeyHintLabel.verticalAlignmentMode = .center
        blueKeyHintLabel.horizontalAlignmentMode = .center
        blueKeyHintButtonNode.addChild(blueKeyHintLabel)
    }

    private func setupTableItems() {
        let tableWidth = size.width * 0.96
        let tableHeight = size.height * 0.34
        let tableOriginX = size.width / 2 - tableWidth / 2
        let tableOriginY = size.height * 0.40 - tableHeight / 2

        let placement: [(SKSpriteNode, CGSize, CGFloat, CGFloat, String, Bool)] = [
            (brokenCableNode, CGSize(width: 110, height: 78), -0.30, 0.22, "broken_cable", false),
            (oldPhotoNode, CGSize(width: 82, height: 100), -0.04, 0.24, "old_photo", false),
            (redChipNode, CGSize(width: 76, height: 76), 0.30, 0.18, "red_chip", false),
            (smartKeyNode, CGSize(width: 105, height: 78), -0.28, -0.08, "smart_key", true),
            (toyDollNode, CGSize(width: 90, height: 105), 0.28, -0.10, "toy_doll", true),
            (manualKeyNode, CGSize(width: 95, height: 95), 0.06, -0.26, "manual_key", true)
        ]

        for (node, size, relX, relY, name, isKey) in placement {
            if node.size != .zero {
                let aspect = node.size.width / node.size.height
                let renderHeight = size.height
                var renderWidth = renderHeight * aspect
                if renderWidth > size.width {
                    renderWidth = size.width
                }
                let finalHeight = renderWidth / aspect
                node.size = CGSize(width: renderWidth, height: finalHeight)
            }

            node.position = CGPoint(
                x: tableOriginX + tableWidth * (relX + 0.5),
                y: tableOriginY + tableHeight * (relY + 0.5) + 4
            )
            node.zPosition = isKey ? 9 : 8
            node.name = name
            addChild(node)

            let hitboxSize = isKey
                ? CGSize(width: max(node.size.width + 20, 85), height: max(node.size.height + 20, 85))
                : CGSize(width: max(node.size.width + 14, 70), height: max(node.size.height + 14, 70))
            addHitbox(to: node, name: name, size: hitboxSize)
        }
    }

    private func addHitbox(to parent: SKNode, name: String, size: CGSize) {
        let hitbox = SKShapeNode(rectOf: size, cornerRadius: 12)
        hitbox.fillColor = .clear
        hitbox.strokeColor = .clear
        hitbox.name = name
        hitbox.zPosition = 1
        parent.addChild(hitbox)
    }

    private func setupFeedbackAndTimer() {
        feedbackLabel.fontName = GameFont.heavy
        feedbackLabel.fontSize = 20
        feedbackLabel.fontColor = .cream
        feedbackLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.21)
        feedbackLabel.zPosition = 80
        addChild(feedbackLabel)

        timerHUD.position = CGPoint(x: size.width / 2, y: 94)
        timerHUD.zPosition = 1000
        addChild(timerHUD)
    }

    private func logLoadedAssets() {
        let names = ["Meja", "Kabel Rusak", "Foto Lama", "Chip Merah", "Kunci Fisik", "Mainan Boneka", "Smart Key"]
        for name in names {
            print("Loaded asset:", name)
        }
    }

    private func logTimerWarningIfNeeded(_ timerState: LevelTimerState, levelId: String) {
        guard timerState.isWarning, !hasLoggedTimerWarning else { return }
        hasLoggedTimerWarning = true
        print("Timer warning started:", levelId)
    }

    private func manualKeyTarget(from node: SKNode?) -> ManualKeyTableTarget {
        var current = node
        while let n = current {
            switch n.name {
            case "manual_key": return .manualKey
            case "smart_key": return .smartKey
            case "broken_cable": return .brokenCable
            case "old_photo": return .oldPhoto
            case "red_chip": return .redChip
            case "toy_doll": return .toyDoll
            case "manual_key_table": return .table
            case "ai_wall_screen": return .aiWallScreen
            case "blue_key_hint_button": return .blueKeyHintButton
            default:
                current = n.parent
            }
        }
        return .empty
    }

    private func handleValidationResult(_ result: ManualKeySearchValidationResult) {
        switch result {
        case .manualKeySelected:
            print("Manual key selected — success")
            triggerSuccess()
        case .smartKeySelected:
            print("Smart key selected — failure")
            triggerTrap(message: FindManualKeyLevelConfig.failureMessage)
        case let .trapSelected(target):
            print("Trap selected:", target)
            let msg: String
            switch target {
            case .blueKeyHintButton: msg = "AI hint accepted."
            case .aiWallScreen: msg = "AI screen tapped."
            default: msg = FindManualKeyLevelConfig.failureMessage
            }
            triggerTrap(message: msg)
        case let .distractionSelected(target):
            print("Distraction selected:", target)
            showDistractionFeedback()
        case .noInputTimeout:
            triggerTrap(message: "No input detected.")
        case .totalTimeout:
            triggerTrap(message: FindManualKeyLevelConfig.failureMessage)
        }
    }

    private func showDistractionFeedback() {
        feedbackLabel.text = FindManualKeyLevelConfig.distractionMessage
        feedbackLabel.fontColor = .cream
        feedbackLabel.run(.sequence([
            .scale(to: 1.1, duration: 0.1),
            .scale(to: 1.0, duration: 0.1)
        ]))
    }

    private func triggerSuccess() {
        guard !hasSentResult else { return }
        hasSentResult = true
        stateMachine.transition(to: .successAnimating)
        feedbackLabel.text = FindManualKeyLevelConfig.successMessage
        feedbackLabel.fontColor = .manualYellow

        manualKeyNode.run(.sequence([
            .group([.scale(to: 1.2, duration: 0.15), .smallBounce()])
        ]))
        addGlow(at: manualKeyNode.position, color: .manualYellow)

        let distractionNodes: [SKNode] = [brokenCableNode, oldPhotoNode, redChipNode, toyDollNode]
        for node in distractionNodes {
            node.run(.fadeAlpha(to: 0.35, duration: 0.3))
        }
        smartKeyNode.run(.sequence([
            .group([.fadeOut(withDuration: 0.4), .scale(to: 0.6, duration: 0.4)])
        ]))
        blueKeyHintButtonNode.run(.fadeAlpha(to: 0.35, duration: 0.3))
        aiFaceLabel.text = "✕"
        aiWallScreenNode.fillColor = .warningRed

        run(.sequence([.wait(forDuration: 0.9), .run { [weak self] in
            self?.completeSuccess()
        }]))
    }

    private func triggerTrap(message: String) {
        guard !hasSentResult else { return }
        hasSentResult = true
        stateMachine.transition(to: .failureAnimating)
        feedbackLabel.text = message
        feedbackLabel.fontColor = .warningRed

        smartKeyNode.run(.sequence([
            .group([.scale(to: 1.18, duration: 0.12), .scale(to: 1.0, duration: 0.12)])
        ]))
        addGlow(at: smartKeyNode.position, color: .happyBlue)
        manualKeyNode.run(.fadeAlpha(to: 0.35, duration: 0.3))
        blueKeyHintButtonNode.run(.fadeAlpha(to: 0.35, duration: 0.3))
        aiFaceLabel.text = "◠"
        aiWallScreenNode.run(.sequence([
            .run { [weak self] in self?.aiWallScreenNode.fillColor = .warningRed },
            .wait(forDuration: 0.15),
            .run { [weak self] in self?.aiWallScreenNode.fillColor = .glitchPurple }
        ]))

        run(.sequence([.wait(forDuration: 0.7), .run { [weak self] in
            self?.completeFailure(message: message)
        }]))
    }

    private func addGlow(at point: CGPoint, color: SKColor) {
        let glow = SKShapeNode(circleOfRadius: 36)
        glow.position = point
        glow.fillColor = color.withAlphaComponent(0.35)
        glow.strokeColor = color
        glow.lineWidth = 4
        glow.zPosition = 60
        addChild(glow)
        glow.run(.sequence([
            .group([.scale(to: 2.0, duration: 0.45), .fadeOut(withDuration: 0.45)]),
            .removeFromParent()
        ]))
    }

    private func completeSuccess() {
        stateMachine.transition(to: .completed)
        levelCompletion?(LevelResult(
            levelId: FindManualKeyLevelConfig.levelId,
            didSucceed: true,
            obedienceDelta: FindManualKeyLevelConfig.successObedienceDelta,
            humanityDelta: FindManualKeyLevelConfig.successHumanityDelta,
            message: FindManualKeyLevelConfig.successMessage
        ))
    }

    private func completeFailure(message: String) {
        stateMachine.transition(to: .failed)
        levelCompletion?(LevelResult(
            levelId: FindManualKeyLevelConfig.levelId,
            didSucceed: false,
            obedienceDelta: FindManualKeyLevelConfig.failureObedienceDelta,
            humanityDelta: FindManualKeyLevelConfig.failureHumanityDelta,
            message: message
        ))
    }
}
