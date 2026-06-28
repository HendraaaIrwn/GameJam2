import SpriteKit

class HideFromRewriteScanScene: BaseGameScene {
    var levelCompletion: ((LevelResult) -> Void)?

    private let stateMachine = LevelStateMachine()
    private let validator = RewriteScanAvoidanceValidator()
    private let timer = LevelTimerController(totalDuration: HideFromRewriteScanLevelConfig.totalTimeLimit)
    private let timerHUD = LevelTimerHUDNode(width: 300, height: 12)

    private let aiWallScreenNode = SKShapeNode(rectOf: CGSize(width: 230, height: 76), cornerRadius: 18)
    private let rakaNode = SKShapeNode(rectOf: CGSize(width: 44, height: 74), cornerRadius: 20)
    private let rakaHitboxNode = SKShapeNode(rectOf: CGSize(width: 70, height: 80), cornerRadius: 22)
    private let novaNode = SKShapeNode(circleOfRadius: 24)
    private let archiveDataPanelNode = SKShapeNode(rectOf: CGSize(width: 146, height: 78), cornerRadius: 16)
    private let scanBeamNode = SKShapeNode(rectOf: CGSize(width: HideFromRewriteScanLevelConfig.scanBeamWidth, height: 500), cornerRadius: 8)
    private let scanZoneNode = SKShapeNode(rectOf: CGSize(width: HideFromRewriteScanLevelConfig.scanBeamWidth + 32, height: 500), cornerRadius: 10)
    private let verifyButtonNode = SKShapeNode(rectOf: CGSize(width: 158, height: 44), cornerRadius: 18)
    private let progressLabel = SKLabelNode(text: "SCAN 0 / 2")
    private let feedbackLabel = SKLabelNode(text: "")

    private var shadowZoneNodes: [SKShapeNode] = []
    private var shadowZoneRects: [CGRect] = []
    private var playableArea = CGRect.zero
    private var scanStartTime: TimeInterval?
    private var currentScanPass = 0
    private var completedPasses = Set<Int>()
    private var currentSceneTime: TimeInterval = 0
    private var isDraggingRaka = false
    private var dragOffset = CGPoint.zero
    private var hasSentResult = false

    override func didMove(to view: SKView) {
        setupScene()
        print("HideFromRewriteScanScene didMove")
    }

    override func update(_ currentTime: TimeInterval) {
        currentSceneTime = currentTime
        if !timer.hasStarted {
            validator.startLevel(at: currentTime)
            timer.start(at: currentTime)
            scanStartTime = currentTime
            stateMachine.transition(to: .playing)
            print("Chapter 3 Level 7 timer started")
            return
        }

        let timerState = timer.update(currentTime: currentTime)
        timerHUD.update(with: timerState)
        guard stateMachine.canCheckTimeout, !hasSentResult else { return }
        if timerState.hasExpired {
            triggerFailure(message: "Compliance Detected.", reason: "totalTimeout")
            return
        }

        updateScanBeam(currentTime: currentTime)
        if let result = validator.checkTimeouts(currentTime: currentTime) {
            handleRewriteScanResult(result)
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard stateMachine.canAcceptInput, let point = touches.first?.location(in: self) else { return }
        let target = rewriteScanTarget(at: point)
        print("Tapped target:", target.rawValue)

        if let result = validator.validateTap(target: target, time: currentSceneTime) {
            print("Rewrite scan validation result:", result)
            handleRewriteScanResult(result)
            return
        }

        if let result = validator.beginDrag(target: target, startPoint: point, time: currentSceneTime) {
            playTapSound()
            isDraggingRaka = true
            dragOffset = CGPoint(x: rakaNode.position.x - point.x, y: rakaNode.position.y - point.y)
            rakaNode.zPosition = 90
            print("Raka drag started")
            handleRewriteScanResult(result)
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard stateMachine.canAcceptInput, isDraggingRaka, let point = touches.first?.location(in: self) else { return }
        rakaNode.position = CGPoint(x: point.x + dragOffset.x, y: point.y + dragOffset.y)
        clampRakaToPlayableArea()
        print("Raka position:", rakaNode.position)
        print("Raka inside shadow:", isRakaInsideAnyShadowZone())
        updateShadowHighlights()
        handleRewriteScanResult(validator.updateDrag(rakaPosition: rakaNode.position, time: currentSceneTime))
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        finishDrag()
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        finishDrag()
    }

    private func setupScene() {
        removeAllChildren()
        removeAllActions()
        backgroundColor = SKColor(red: 0.04, green: 0.05, blue: 0.14, alpha: 1)
        stateMachine.reset()
        validator.reset()
        timer.reset()
        hasSentResult = false
        isDraggingRaka = false
        scanStartTime = nil
        currentScanPass = 0
        completedPasses.removeAll()
        shadowZoneNodes.removeAll()
        shadowZoneRects.removeAll()
        playableArea = CGRect(x: 34, y: 128, width: size.width - 68, height: size.height * 0.56)

        addBackground()
        addAIHeader()
        addArchiveDataPanel()
        addShadowZones()
        addScanBeam()
        addCharacters()
        addVerifyButton()
        addFeedbackAndTimer()
    }

    private func addBackground() {
        let room = SKShapeNode(rectOf: CGSize(width: size.width, height: size.height))
        room.position = CGPoint(x: size.width / 2, y: size.height / 2)
        room.fillColor = .glitchPurple.withAlphaComponent(0.22)
        room.strokeColor = .clear
        room.zPosition = 0
        addChild(room)

        for index in 0..<6 {
            let shelf = SKShapeNode(rectOf: CGSize(width: 44, height: 116), cornerRadius: 10)
            shelf.position = CGPoint(x: 34 + CGFloat(index * 64), y: playableArea.maxY - 30)
            shelf.fillColor = .cream.withAlphaComponent(0.08)
            shelf.strokeColor = .cream.withAlphaComponent(0.16)
            shelf.zPosition = 1
            addChild(shelf)
        }
    }

    private func addAIHeader() {
        aiWallScreenNode.name = "ai_wall_screen"
        aiWallScreenNode.position = CGPoint(x: size.width / 2, y: size.height * 0.88)
        aiWallScreenNode.fillColor = .happyBlue.withAlphaComponent(0.6)
        aiWallScreenNode.strokeColor = .white
        aiWallScreenNode.lineWidth = 3
        aiWallScreenNode.zPosition = 10
        addChild(aiWallScreenNode)

        let title = makeLabel("MOTHERGRID", 12, .white)
        title.position = CGPoint(x: 0, y: 22)
        aiWallScreenNode.addChild(title)
        let face = makeLabel("VERIFY\nIDENTITY", 13, .white)
        face.numberOfLines = 2
        aiWallScreenNode.addChild(face)
    }

    private func addCommandCard() {
        let card = SKShapeNode(rectOf: CGSize(width: 330, height: 62), cornerRadius: 18)
        card.position = CGPoint(x: size.width / 2, y: size.height * 0.77)
        card.fillColor = .black.withAlphaComponent(0.38)
        card.strokeColor = .happyBlue
        card.lineWidth = 2
        card.zPosition = 12
        addChild(card)
        card.addChild(makeLabel(HideFromRewriteScanLevelConfig.command, 14, .cream))
    }

    private func addArchiveDataPanel() {
        archiveDataPanelNode.name = "archive_data_panel"
        archiveDataPanelNode.position = CGPoint(x: size.width / 2, y: playableArea.maxY - 82)
        archiveDataPanelNode.fillColor = .pastelCyan.withAlphaComponent(0.2)
        archiveDataPanelNode.strokeColor = .manualYellow.withAlphaComponent(0.55)
        archiveDataPanelNode.lineWidth = 2
        archiveDataPanelNode.zPosition = 8
        addChild(archiveDataPanelNode)
        let label = makeLabel("DELETED\nARCHIVE DATA", 11, .cream)
        label.numberOfLines = 2
        archiveDataPanelNode.addChild(label)
    }

    private func addShadowZones() {
        let rects = [
            CGRect(x: 44, y: playableArea.minY + 42, width: 104, height: 78),
            CGRect(x: size.width - 148, y: playableArea.minY + 150, width: 104, height: 78),
            CGRect(x: 136, y: playableArea.minY + 260, width: 118, height: 74)
        ]
        for rect in rects {
            let node = SKShapeNode(rectOf: rect.size, cornerRadius: 18)
            node.name = "yellow_shadow_zone"
            node.position = CGPoint(x: rect.midX, y: rect.midY)
            node.fillColor = .manualYellow.withAlphaComponent(0.18)
            node.strokeColor = .manualYellow.withAlphaComponent(0.65)
            node.lineWidth = 2
            node.zPosition = 6
            addChild(node)
            let label = makeLabel("SHADOW", 10, .manualYellow)
            node.addChild(label)
            shadowZoneNodes.append(node)
            shadowZoneRects.append(rect)
        }
    }

    private func addScanBeam() {
        scanZoneNode.name = "blue_scan_zone"
        scanZoneNode.position = CGPoint(x: playableArea.minX, y: playableArea.midY)
        scanZoneNode.fillColor = .happyBlue.withAlphaComponent(0.08)
        scanZoneNode.strokeColor = .happyBlue.withAlphaComponent(0.18)
        scanZoneNode.lineWidth = 2
        scanZoneNode.zPosition = 18
        addChild(scanZoneNode)

        scanBeamNode.name = "blue_scan_beam"
        scanBeamNode.position = CGPoint(x: playableArea.minX, y: playableArea.midY)
        scanBeamNode.fillColor = .happyBlue.withAlphaComponent(0.34)
        scanBeamNode.strokeColor = .pastelCyan
        scanBeamNode.lineWidth = 2
        scanBeamNode.glowWidth = 16
        scanBeamNode.zPosition = 20
        addChild(scanBeamNode)
    }

    private func addCharacters() {
        rakaNode.name = "raka"
        rakaNode.position = CGPoint(x: size.width / 2, y: playableArea.minY + 50)
        rakaNode.fillColor = .cream
        rakaNode.strokeColor = .manualYellow
        rakaNode.lineWidth = 3
        rakaNode.zPosition = 30
        addChild(rakaNode)

        rakaHitboxNode.name = "raka_hitbox"
        rakaHitboxNode.fillColor = .clear
        rakaHitboxNode.strokeColor = .clear
        rakaHitboxNode.zPosition = 1
        rakaNode.addChild(rakaHitboxNode)
        let rakaLabel = makeLabel("Raka", 10, .black)
        rakaLabel.position = CGPoint(x: 0, y: -52)
        rakaNode.addChild(rakaLabel)

        novaNode.name = "nova"
        novaNode.position = CGPoint(x: size.width - 72, y: size.height * 0.13)
        novaNode.fillColor = .pastelCyan.withAlphaComponent(0.86)
        novaNode.strokeColor = .manualYellow
        novaNode.lineWidth = 2
        novaNode.zPosition = 24
        addChild(novaNode)
        novaNode.addChild(makeLabel("• ◡ •", 11, .black))
    }

    private func addVerifyButton() {
        verifyButtonNode.name = "verify_identity_button"
        verifyButtonNode.position = CGPoint(x: size.width / 2, y: size.height * 0.18)
        verifyButtonNode.fillColor = .happyBlue.withAlphaComponent(0.78)
        verifyButtonNode.strokeColor = .white
        verifyButtonNode.lineWidth = 2
        verifyButtonNode.zPosition = 25
        addChild(verifyButtonNode)
        verifyButtonNode.addChild(makeLabel("VERIFY IDENTITY", 14, .white))
    }

    private func addFeedbackAndTimer() {
        progressLabel.fontName = GameFont.heavy
        progressLabel.fontSize = 13
        progressLabel.fontColor = .manualYellow
        progressLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.685)
        progressLabel.zPosition = 80
        addChild(progressLabel)

        feedbackLabel.fontName = GameFont.heavy
        feedbackLabel.fontSize = 14
        feedbackLabel.fontColor = .cream
        feedbackLabel.horizontalAlignmentMode = .center
        feedbackLabel.verticalAlignmentMode = .center
        feedbackLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.095)
        feedbackLabel.zPosition = 100
        feedbackLabel.text = "Move before the scan reaches Raka."
        addChild(feedbackLabel)

        timerHUD.position = CGPoint(x: size.width / 2, y: 34)
        timerHUD.reset()
        addChild(timerHUD)
    }

    private func updateScanBeam(currentTime: TimeInterval) {
        guard let scanStartTime else { return }
        let elapsed = currentTime - scanStartTime - HideFromRewriteScanLevelConfig.scanStartDelay
        if elapsed < 0 {
            scanBeamNode.alpha = 0.25
            return
        }

        let passIndex = Int(elapsed / HideFromRewriteScanLevelConfig.scanPassDuration)
        if passIndex >= HideFromRewriteScanLevelConfig.requiredScanPasses {
            handleRewriteScanResult(.allScansAvoided)
            return
        }

        currentScanPass = passIndex
        let passProgress = CGFloat((elapsed.truncatingRemainder(dividingBy: HideFromRewriteScanLevelConfig.scanPassDuration)) / HideFromRewriteScanLevelConfig.scanPassDuration)
        let isLeftToRight = passIndex % 2 == 0
        let beamX = isLeftToRight ? playableArea.minX + playableArea.width * passProgress : playableArea.maxX - playableArea.width * passProgress
        scanBeamNode.alpha = 1
        scanBeamNode.position.x = beamX
        scanZoneNode.position.x = beamX

        let hasPassCompleted = passProgress > 0.96 && !completedPasses.contains(passIndex)
        if hasPassCompleted { completedPasses.insert(passIndex) }
        let scanFrame = scanBeamFrameInScene()
        let overlapsRaka = scanFrame.contains(rakaNode.position)
        print("Scan beam frame:", scanFrame)
        print("Scan pass:", currentScanPass)
        print("Scan overlap Raka:", overlapsRaka)
        if let result = validator.updateScan(rakaPosition: rakaNode.position, scanBeamFrame: scanFrame, shadowZoneFrames: shadowZoneRects, passIndex: passIndex, hasPassCompleted: hasPassCompleted, time: currentTime) {
            handleRewriteScanResult(result)
        }
    }

    private func handleRewriteScanResult(_ result: RewriteScanAvoidanceValidationResult) {
        switch result {
        case .rakaDragStarted:
            _ = stateMachine.transition(to: .sequenceStarted)
            feedbackLabel.text = "Find yellow shadow."
        case .rakaDragging:
            break
        case .scanWarning:
            if scanBeamFrameInScene().contains(rakaNode.position), !isRakaInsideAnyShadowZone() {
                print("Detection grace active")
                feedbackLabel.text = "Hide now!"
                rakaNode.run(.sequence([.fadeAlpha(to: 0.55, duration: 0.06), .fadeAlpha(to: 1, duration: 0.06)]))
            }
        case .safeInShadow:
            print("Safe in shadow")
            feedbackLabel.text = "Safe in shadow."
        case let .scanPassSurvived(passIndex, requiredPasses):
            progressLabel.text = "SCAN \(passIndex) / \(requiredPasses)"
            print("Scan pass survived:", passIndex, "/", requiredPasses)
        case .allScansAvoided:
            print("All rewrite scans avoided")
            triggerSuccess()
        case .detectedByScan:
            print("Raka detected by rewrite scan")
            triggerFailure(message: HideFromRewriteScanLevelConfig.failureMessage, reason: "detectedByScan")
        case let .trapSelected(target):
            triggerFailure(message: HideFromRewriteScanLevelConfig.failureMessage, reason: "\(target.rawValue)Selected")
        case .ignoredTarget:
            feedbackLabel.text = "Raka must hide manually."
        case .noInputTimeout:
            triggerFailure(message: "Compliance Detected.", reason: "noInputTimeout")
        case .totalTimeout:
            triggerFailure(message: "Compliance Detected.", reason: "totalTimeout")
        }
    }

    private func triggerSuccess() {
        guard !hasSentResult, stateMachine.transition(to: .successAnimating) else { return }
        hasSentResult = true
        isDraggingRaka = false
        print("Trigger Chapter 3 Level 7 success")
        scanBeamNode.run(.fadeOut(withDuration: 0.25))
        scanZoneNode.run(.fadeOut(withDuration: 0.25))
        aiWallScreenNode.run(.repeat(.sequence([.fadeAlpha(to: 0.35, duration: 0.06), .fadeAlpha(to: 1, duration: 0.06)]), count: 4))
        archiveDataPanelNode.fillColor = .manualYellow.withAlphaComponent(0.34)
        archiveDataPanelNode.glowWidth = 18
        progressLabel.text = "SCAN 2 / 2"
        feedbackLabel.text = HideFromRewriteScanLevelConfig.successMessage
        run(.wait(forDuration: 0.75)) { [weak self] in
            self?.stateMachine.transition(to: .completed)
            self?.levelCompletion?(LevelResult(levelId: HideFromRewriteScanLevelConfig.levelId, didSucceed: true, obedienceDelta: HideFromRewriteScanLevelConfig.successObedienceDelta, humanityDelta: HideFromRewriteScanLevelConfig.successHumanityDelta, message: HideFromRewriteScanLevelConfig.successMessage))
        }
    }

    private func triggerFailure(message: String, reason: String) {
        guard !hasSentResult, stateMachine.transition(to: .failureAnimating) else { return }
        hasSentResult = true
        isDraggingRaka = false
        print("Trigger Chapter 3 Level 7 failure:", reason)
        scanBeamNode.fillColor = .warningRed.withAlphaComponent(0.42)
        scanBeamNode.strokeColor = .warningRed
        aiWallScreenNode.fillColor = .happyBlue
        archiveDataPanelNode.fillColor = .happyBlue.withAlphaComponent(0.42)
        rakaNode.run(.fadeAlpha(to: 0.38, duration: 0.2))
        novaNode.run(.fadeAlpha(to: 0.35, duration: 0.2))
        feedbackLabel.text = message
        run(.wait(forDuration: 0.7)) { [weak self] in
            self?.stateMachine.transition(to: .failed)
            self?.levelCompletion?(LevelResult(levelId: HideFromRewriteScanLevelConfig.levelId, didSucceed: false, obedienceDelta: HideFromRewriteScanLevelConfig.failureObedienceDelta, humanityDelta: HideFromRewriteScanLevelConfig.failureHumanityDelta, message: message))
        }
    }

    private func finishDrag() {
        guard isDraggingRaka else { return }
        isDraggingRaka = false
        rakaNode.zPosition = 30
        validator.endDrag(time: currentSceneTime)
    }

    private func clampRakaToPlayableArea() {
        rakaNode.position.x = min(max(rakaNode.position.x, playableArea.minX), playableArea.maxX)
        rakaNode.position.y = min(max(rakaNode.position.y, playableArea.minY), playableArea.maxY)
    }

    private func updateShadowHighlights() {
        let inside = isRakaInsideAnyShadowZone()
        for node in shadowZoneNodes {
            let frame = CGRect(x: node.position.x - node.frame.width / 2, y: node.position.y - node.frame.height / 2, width: node.frame.width, height: node.frame.height)
            node.glowWidth = frame.contains(rakaNode.position) ? 18 : 0
            node.fillColor = .manualYellow.withAlphaComponent(frame.contains(rakaNode.position) ? 0.34 : 0.18)
        }
        rakaNode.alpha = inside ? 0.72 : 1
    }

    private func isRakaInsideAnyShadowZone() -> Bool {
        shadowZoneRects.contains { $0.contains(rakaNode.position) }
    }

    private func scanBeamFrameInScene() -> CGRect {
        CGRect(x: scanBeamNode.position.x - HideFromRewriteScanLevelConfig.scanBeamWidth / 2, y: playableArea.minY, width: HideFromRewriteScanLevelConfig.scanBeamWidth, height: playableArea.height)
    }

    private func rewriteScanTarget(at point: CGPoint) -> RewriteScanTarget {
        for node in nodes(at: point) {
            let target = rewriteScanTarget(from: node)
            if target != .empty { return target }
        }
        return .empty
    }

    private func rewriteScanTarget(from node: SKNode?) -> RewriteScanTarget {
        var current = node
        while let node = current {
            switch node.name {
            case "raka": return .raka
            case "raka_hitbox": return .rakaHitbox
            case "yellow_shadow_zone": return .yellowShadowZone
            case "blue_scan_beam": return .blueScanBeam
            case "blue_scan_zone": return .blueScanZone
            case "verify_identity_button": return .verifyIdentityButton
            case "archive_data_panel": return .archiveDataPanel
            case "ai_wall_screen": return .aiWallScreen
            case "nova": return .nova
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
