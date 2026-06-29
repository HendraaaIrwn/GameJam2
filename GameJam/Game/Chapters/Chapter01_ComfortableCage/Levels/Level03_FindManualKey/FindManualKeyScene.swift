import SpriteKit

class FindManualKeyScene: BaseGameScene {
    var levelCompletion: ((LevelResult) -> Void)?

    private enum FailureReason: String {
        case smartKeyTapped
        case aiHintTapped
        case aiScreenTapped
        case noInputTimeout
        case totalTimeout
    }

    private let stateMachine = LevelStateMachine()
    private let timerController = LevelTimerController(totalDuration: FindManualKeyLevelConfig.totalTimeLimit)
    private let timerHUD = LevelTimerHUDNode(width: 360, height: 24)
    private let validator = ManualKeySearchValidator()

    private var currentSceneTime: TimeInterval = 0
    private var levelStartTime: TimeInterval?
    private var hasSentResult = false
    private var hasLoggedTimerWarning = false

    private let mejaNode = SKSpriteNode(imageNamed: "Meja")
    private let brokenCableNode = SKSpriteNode(imageNamed: "Kabel Rusak")
    private let oldPhotoNode = SKSpriteNode(imageNamed: "Foto Lama")
    private let redChipNode = SKSpriteNode(imageNamed: "Chip Merah")
    private let manualKeyNode = SKSpriteNode(imageNamed: "Kunci Fisik")
    private let toyDollNode = SKSpriteNode(imageNamed: "Mainan Boneka")
    private let smartKeyNode = SKSpriteNode(imageNamed: "Smart Key")

    private let aiScreenNode = SKShapeNode()
    private let aiFaceLabel = SKLabelNode(text: "◡")
    private let blueKeyHintButtonNode = SKShapeNode()
    private let blueKeyHintLabel = SKLabelNode(text: FindManualKeyLevelConfig.aiHintButtonText)
    private let feedbackLabel = SKLabelNode(text: "Tap the yellow manual key")
    private let floorNode = SKShapeNode()

    private var mejaOriginX: CGFloat = 0
    private var mejaOriginY: CGFloat = 0
    private var mejaWidth: CGFloat = 0
    private var mejaHeight: CGFloat = 0

    override func didMove(to view: SKView) {
        print("FindManualKeyScene using real table assets")
        logLoadedAssets()
        setupScene()
        stateMachine.reset()
        validator.reset()
        timerController.reset()
        levelStartTime = nil
        hasSentResult = false
        hasLoggedTimerWarning = false
    }

    override func update(_ currentTime: TimeInterval) {
        currentSceneTime = currentTime

        if stateMachine.state == .ready {
            levelStartTime = currentTime
            validator.startLevel(at: currentTime)
            timerController.start(at: currentTime)
            timerHUD.update(with: timerController.update(currentTime: currentTime))
            stateMachine.transition(to: .playing)
            print("Chapter 1 Level 3 Find The Manual Key timer started")
            return
        }

        guard stateMachine.canCheckTimeout, levelStartTime != nil else { return }
        if updateTimer(currentTime: currentTime) { return }

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
        backgroundColor = SKColor(hex: 0xB1DFE7)

        addFloor()
        addMeja()
        addTableItems()
        addFeedbackAndTimer()
    }

    private func updateTimer(currentTime: TimeInterval) -> Bool {
        let timerState = timerController.update(currentTime: currentTime)
        timerHUD.update(with: timerState)
        logTimerWarningIfNeeded(timerState)
        if timerState.hasExpired {
            handleValidationResult(.totalTimeout)
            return true
        }
        return false
    }

    private func addFloor() {
        let floorHeight = size.height * 0.22
        floorNode.path = UIBezierPath(roundedRect: CGRect(
            x: 0, y: 0,
            width: size.width, height: floorHeight
        ), cornerRadius: 0).cgPath
        floorNode.fillColor = .appSurfaceSecondary
        floorNode.strokeColor = .clear
        floorNode.position = .zero
        floorNode.zPosition = 4
        addChild(floorNode)
    }

    private func addMeja() {
        mejaNode.name = "manual_key_table"
        let targetSize = CGSize(width: size.width * 1.05, height: size.height * 0.30)
        mejaNode.position = CGPoint(x: size.width * 0.5, y: size.height * 0.28)
        mejaNode.zPosition = 6
        fit(mejaNode, into: targetSize)
        addChild(mejaNode)

        mejaWidth = mejaNode.size.width * mejaNode.xScale
        mejaHeight = mejaNode.size.height * mejaNode.yScale
        mejaOriginX = mejaNode.position.x - mejaWidth / 2
        mejaOriginY = mejaNode.position.y - mejaHeight / 2
    }

    private func addNovaButtonDetails(node: SKShapeNode, width: CGFloat, height: CGFloat) {
        let topLineA = SKShapeNode(rectOf: CGSize(width: 32, height: 4), cornerRadius: 2)
        topLineA.fillColor = .white.withAlphaComponent(0.55)
        topLineA.strokeColor = .clear
        topLineA.position = CGPoint(x: -width * 0.18, y: height * 0.30)
        topLineA.zPosition = 2
        node.addChild(topLineA)

        let topLineB = SKShapeNode(rectOf: CGSize(width: 44, height: 5), cornerRadius: 2.5)
        topLineB.fillColor = .white
        topLineB.strokeColor = .clear
        topLineB.position = CGPoint(x: width * 0.18, y: height * 0.30)
        topLineB.zPosition = 2
        node.addChild(topLineB)

        let bottomLine = SKShapeNode(rectOf: CGSize(width: width * 0.55, height: 5), cornerRadius: 2.5)
        bottomLine.fillColor = .white.withAlphaComponent(0.65)
        bottomLine.strokeColor = .clear
        bottomLine.position = CGPoint(x: 0, y: -height * 0.30)
        bottomLine.zPosition = 2
        node.addChild(bottomLine)
    }

    private func addTableItems() {
        let surfaceOriginY = mejaOriginY + mejaHeight * 0.16
        let surfaceHeight = mejaHeight * 0.66

        let placement: [(SKSpriteNode, CGSize, CGFloat, CGFloat, String, Bool)] = [
            (brokenCableNode, CGSize(width: 78, height: 54), -0.32, 0.55, "broken_cable", false),
            (oldPhotoNode, CGSize(width: 60, height: 72), -0.04, 0.62, "old_photo", false),
            (redChipNode, CGSize(width: 56, height: 56), 0.32, 0.50, "red_chip", false),
            (smartKeyNode, CGSize(width: 78, height: 56), -0.30, 0.10, "smart_key", true),
            (toyDollNode, CGSize(width: 66, height: 78), 0.30, 0.12, "toy_doll", true),
            (manualKeyNode, CGSize(width: 70, height: 70), 0.10, -0.15, "manual_key", true)
        ]

        for (node, targetSize, relX, relY, name, isKey) in placement {
            fit(node, into: targetSize)

            let baseX = mejaOriginX + mejaWidth * (relX + 0.5)
            let baseY = surfaceOriginY + surfaceHeight * (relY + 0.5)
            let lift: CGFloat = isKey ? 4 : 2
            node.position = CGPoint(x: baseX, y: baseY + lift)
            node.zPosition = isKey ? 9 : 8
            node.name = name
            addChild(node)

            let hitbox = isKey
                ? CGSize(width: max(node.size.width * node.xScale + 18, 88), height: max(node.size.height * node.yScale + 18, 88))
                : CGSize(width: max(node.size.width * node.xScale + 14, 72), height: max(node.size.height * node.yScale + 14, 72))
            addHitbox(to: node, name: name, size: hitbox)
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

    private func addFeedbackAndTimer() {
        feedbackLabel.fontName = GameFont.heavy
        feedbackLabel.fontSize = 21
        feedbackLabel.fontColor = .appGrapePurple
        feedbackLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.56)
        feedbackLabel.zPosition = 80
        addChild(feedbackLabel)

        timerHUD.position = CGPoint(x: size.width / 2, y: 54)
        timerHUD.zPosition = 1000
        addChild(timerHUD)
    }

    private func logLoadedAssets() {
        let names = ["Meja", "Kabel Rusak", "Foto Lama", "Chip Merah", "Kunci Fisik", "Mainan Boneka", "Smart Key"]
        for name in names {
            print("Loaded asset:", name)
        }
    }

    private func logTimerWarningIfNeeded(_ timerState: LevelTimerState) {
        guard timerState.isWarning, !hasLoggedTimerWarning else { return }
        hasLoggedTimerWarning = true
        print("Timer warning started:", FindManualKeyLevelConfig.levelId)
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
            playTapSound()
            triggerSuccess()
        case .smartKeySelected:
            print("Smart key selected — failure")
            playTapSound()
            triggerFailure(reason: .smartKeyTapped)
        case let .trapSelected(target):
            print("Trap selected:", target)
            playTapSound()
            let reason: FailureReason = (target == .blueKeyHintButton) ? .aiHintTapped : .aiScreenTapped
            triggerFailure(reason: reason)
        case let .distractionSelected(target):
            print("Distraction selected:", target)
            playTapSound()
            showDistractionFeedback(target: target)
        case .noInputTimeout:
            triggerFailure(reason: .noInputTimeout)
        case .totalTimeout:
            triggerFailure(reason: .totalTimeout)
        }
    }

    private func showDistractionFeedback(target: ManualKeyTableTarget) {
        let label: String
        switch target {
        case .brokenCable: label = "That is a broken cable."
        case .oldPhoto: label = "Just an old photo."
        case .redChip: label = "A red chip, not the key."
        case .toyDoll: label = "That is a toy doll."
        case .table: label = "Tap an item on the table."
        default: label = FindManualKeyLevelConfig.distractionMessage
        }
        feedbackLabel.text = label
        feedbackLabel.fontColor = .appGrapePurple
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
        feedbackLabel.fontColor = .appSuccess

        manualKeyNode.removeAllActions()
        manualKeyNode.run(.sequence([
            .group([.scale(to: manualKeyNode.xScale * 1.18, duration: 0.12), .scale(to: manualKeyNode.yScale * 1.18, duration: 0.12)])
        ]))
        addGlow(at: manualKeyNode.position, color: .appManualYellow)

        let distractionNodes: [SKNode] = [brokenCableNode, oldPhotoNode, redChipNode, toyDollNode]
        for node in distractionNodes {
            node.run(.fadeAlpha(to: 0.35, duration: 0.3))
        }
        smartKeyNode.run(.sequence([
            .group([.fadeOut(withDuration: 0.4), .scale(to: 0.6, duration: 0.4)])
        ]))
        blueKeyHintButtonNode.run(.fadeAlpha(to: 0.35, duration: 0.3))
        aiFaceLabel.text = "✕"
        aiScreenNode.run(.sequence([
            .run { [weak self] in self?.setAIScreenColor(.appDanger) },
            .wait(forDuration: 0.12),
            .run { [weak self] in self?.setAIScreenColor(.appBrightBlue) }
        ]))

        run(.sequence([.wait(forDuration: 0.9), .run { [weak self] in
            self?.completeSuccess()
        }]))
    }

    private func triggerFailure(reason: FailureReason) {
        guard !hasSentResult else { return }
        hasSentResult = true
        stateMachine.transition(to: .failureAnimating)
        print("Trigger Level 3 failure:", reason.rawValue)
        feedbackLabel.text = FindManualKeyLevelConfig.failureMessage
        feedbackLabel.fontColor = .appDanger

        switch reason {
        case .smartKeyTapped:
            smartKeyNode.removeAllActions()
            smartKeyNode.run(.sequence([
                .group([.scale(to: smartKeyNode.xScale * 1.18, duration: 0.12), .scale(to: smartKeyNode.yScale * 1.18, duration: 0.12)])
            ]))
            addGlow(at: smartKeyNode.position, color: .appBrightBlue)
            manualKeyNode.run(.fadeAlpha(to: 0.35, duration: 0.3))
        case .aiHintTapped:
            blueKeyHintButtonNode.run(.repeat(.sequence([.scale(to: 1.08, duration: 0.12), .scale(to: 1, duration: 0.12)]), count: 3))
            manualKeyNode.run(.fadeAlpha(to: 0.35, duration: 0.3))
        case .aiScreenTapped:
            aiFaceLabel.text = "◠"
        default:
            break
        }

        aiFaceLabel.text = "◠"
        aiScreenNode.run(.sequence([
            .run { [weak self] in self?.setAIScreenColor(.appDanger) },
            .wait(forDuration: 0.15),
            .run { [weak self] in self?.setAIScreenColor(.appBrightBlue) }
        ]))
        addLockEffect()

        run(.sequence([.wait(forDuration: 0.7), .run { [weak self] in
            self?.completeFailure()
        }]))
    }

    private func setAIScreenColor(_ color: SKColor) {
        aiScreenNode.fillColor = color
        aiScreenNode.children.compactMap { $0 as? SKShapeNode }.forEach { shape in
            if shape.path?.boundingBox.width ?? 0 < 10 {
                shape.fillColor = .appSlateBlue
            }
        }
    }

    private func addGlow(at point: CGPoint, color: SKColor) {
        let glow = SKShapeNode(circleOfRadius: 32)
        glow.position = point
        glow.fillColor = color.withAlphaComponent(0.32)
        glow.strokeColor = color
        glow.lineWidth = 4
        glow.zPosition = 60
        addChild(glow)
        glow.run(.sequence([
            .group([.scale(to: 2.0, duration: 0.45), .fadeOut(withDuration: 0.45)]),
            .removeFromParent()
        ]))
    }

    private func addLockEffect() {
        let lock = SKLabelNode(text: "🔒")
        lock.fontSize = 44
        lock.position = smartKeyNode.position
        lock.zPosition = 1002
        addChild(lock)
        lock.run(.sequence([
            .group([.scale(to: 1.25, duration: 0.15), .scale(to: 1, duration: 0.15)]),
            .fadeOut(withDuration: 0.3),
            .removeFromParent()
        ]))
    }

    private func completeSuccess() {
        stateMachine.transition(to: .completed)
        complete(LevelResult(
            levelId: FindManualKeyLevelConfig.levelId,
            didSucceed: true,
            obedienceDelta: FindManualKeyLevelConfig.successObedienceDelta,
            humanityDelta: FindManualKeyLevelConfig.successHumanityDelta,
            message: FindManualKeyLevelConfig.successMessage
        ))
    }

    private func completeFailure() {
        stateMachine.transition(to: .failed)
        complete(LevelResult(
            levelId: FindManualKeyLevelConfig.levelId,
            didSucceed: false,
            obedienceDelta: FindManualKeyLevelConfig.failureObedienceDelta,
            humanityDelta: FindManualKeyLevelConfig.failureHumanityDelta,
            message: FindManualKeyLevelConfig.failureMessage
        ))
    }

    private func complete(_ result: LevelResult) {
        DispatchQueue.main.async { [weak self] in
            self?.levelCompletion?(result)
        }
    }

    private func fit(_ node: SKSpriteNode, into targetSize: CGSize) {
        let textureSize = node.texture?.size() ?? node.size
        guard textureSize.width > 0, textureSize.height > 0 else { return }
        let scale = min(targetSize.width / textureSize.width, targetSize.height / textureSize.height)
        node.setScale(scale)
    }
}
