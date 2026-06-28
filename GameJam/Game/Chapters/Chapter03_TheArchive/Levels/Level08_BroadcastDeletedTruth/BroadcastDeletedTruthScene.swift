import SpriteKit

final class BroadcastDeletedTruthScene: SKScene {
    var levelCompletion: ((LevelResult) -> Void)?

    private let stateMachine = LevelStateMachine()
    private let validator = ArchiveBroadcastValidator()
    private let timer = LevelTimerController(totalDuration: BroadcastDeletedTruthLevelConfig.totalTimeLimit)
    private let timerHUD = LevelTimerHUDNode(width: 300, height: 12)

    private let aiWallScreenNode = SKShapeNode(rectOf: CGSize(width: 230, height: 76), cornerRadius: 18)
    private let terminalNode = SKShapeNode(rectOf: CGSize(width: 330, height: 265), cornerRadius: 22)
    private let switchNode = SKShapeNode(circleOfRadius: 30)
    private let sliderTrackNode = SKShapeNode(rectOf: CGSize(width: 260, height: 22), cornerRadius: 11)
    private let signalSliderNode = SKShapeNode(circleOfRadius: 21)
    private let yellowZoneNode = SKShapeNode(rectOf: CGSize(width: 78, height: 58), cornerRadius: 16)
    private let blueZoneNode = SKShapeNode(rectOf: CGSize(width: 78, height: 58), cornerRadius: 16)
    private let sendButtonNode = SKShapeNode(rectOf: CGSize(width: 164, height: 44), cornerRadius: 18)
    private let cleanButtonNode = SKShapeNode(rectOf: CGSize(width: 132, height: 38), cornerRadius: 16)
    private let cancelButtonNode = SKShapeNode(rectOf: CGSize(width: 142, height: 38), cornerRadius: 16)
    private let antennaNode = SKShapeNode(rectOf: CGSize(width: 42, height: 118), cornerRadius: 18)
    private let archivePanelNode = SKShapeNode(rectOf: CGSize(width: 132, height: 62), cornerRadius: 14)
    private let cityPreviewNode = SKShapeNode(rectOf: CGSize(width: 132, height: 62), cornerRadius: 14)
    private let rakaNode = SKShapeNode(rectOf: CGSize(width: 42, height: 76), cornerRadius: 20)
    private let novaNode = SKShapeNode(circleOfRadius: 24)
    private let progressLabel = SKLabelNode(text: "STEP 1 / 3")
    private let feedbackLabel = SKLabelNode(text: "")

    private var currentSceneTime: TimeInterval = 0
    private var isHoldingSwitch = false
    private var isDraggingSlider = false
    private var sliderStartPosition = CGPoint.zero
    private var dragOffset = CGPoint.zero
    private var hasSentResult = false

    override func didMove(to view: SKView) {
        setupScene()
        print("BroadcastDeletedTruthScene didMove")
    }

    override func update(_ currentTime: TimeInterval) {
        currentSceneTime = currentTime
        if !timer.hasStarted {
            validator.startLevel(at: currentTime)
            timer.start(at: currentTime)
            stateMachine.transition(to: .playing)
            print("Chapter 3 Level 8 timer started")
            return
        }

        let timerState = timer.update(currentTime: currentTime)
        timerHUD.update(with: timerState)
        guard stateMachine.canCheckTimeout, !hasSentResult else { return }
        if timerState.hasExpired {
            triggerFailure(message: "Compliance Detected.", reason: "totalTimeout")
            return
        }

        if isHoldingSwitch, let result = validator.updateHold(target: .broadcastSwitch, time: currentTime) {
            handleArchiveBroadcastResult(result)
        }
        if let result = validator.checkTimeouts(currentTime: currentTime) {
            handleArchiveBroadcastResult(result)
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard stateMachine.canAcceptInput, let point = touches.first?.location(in: self) else { return }
        let target = archiveBroadcastTarget(at: point)
        print("Tapped target:", target.rawValue)
        print("Broadcast step:", validator.currentStep.rawValue)

        if let result = validator.validateTap(target: target, time: currentSceneTime) {
            print("Archive broadcast validation result:", result)
            handleArchiveBroadcastResult(result)
            return
        }

        if let result = validator.beginTouch(target: target, startPoint: point, time: currentSceneTime) {
            isHoldingSwitch = true
            handleArchiveBroadcastResult(result)
            return
        }

        if let result = validator.beginSliderDrag(target: target, startPoint: point, time: currentSceneTime) {
            if result == .sliderDragStarted {
                isDraggingSlider = true
                dragOffset = CGPoint(x: signalSliderNode.position.x - point.x, y: signalSliderNode.position.y - point.y)
                signalSliderNode.zPosition = 80
            }
            handleArchiveBroadcastResult(result)
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard stateMachine.canAcceptInput, isDraggingSlider, let point = touches.first?.location(in: self) else { return }
        signalSliderNode.position = CGPoint(x: min(max(point.x + dragOffset.x, sliderTrackNode.position.x - 130), sliderTrackNode.position.x + 130), y: sliderTrackNode.position.y)
        let distanceToYellow = signalSliderNode.position.distance(to: yellowZoneNode.position)
        let distanceToBlue = signalSliderNode.position.distance(to: blueZoneNode.position)
        print("Slider position:", signalSliderNode.position)
        print("Distance to yellow zone:", distanceToYellow)
        print("Distance to blue zone:", distanceToBlue)
        updateZoneGlow(distanceToYellow: distanceToYellow, distanceToBlue: distanceToBlue)
        handleArchiveBroadcastResult(validator.updateSliderDrag(sliderPosition: signalSliderNode.position, yellowZoneCenter: yellowZoneNode.position, blueZoneCenter: blueZoneNode.position, time: currentSceneTime))
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        finishTouches()
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        finishTouches()
    }

    private func setupScene() {
        removeAllChildren()
        removeAllActions()
        backgroundColor = SKColor(red: 0.04, green: 0.05, blue: 0.14, alpha: 1)
        stateMachine.reset()
        validator.reset()
        timer.reset()
        hasSentResult = false
        isHoldingSwitch = false
        isDraggingSlider = false

        addBackground()
        addAIHeader()
        addTerminal()
        addControls()
        addPreviewAndCharacters()
        addFeedbackAndTimer()
    }

    private func addBackground() {
        let room = SKShapeNode(rectOf: CGSize(width: size.width, height: size.height))
        room.position = CGPoint(x: size.width / 2, y: size.height / 2)
        room.fillColor = .glitchPurple.withAlphaComponent(0.24)
        room.strokeColor = .clear
        room.zPosition = 0
        addChild(room)
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
        let warning = makeLabel("DO NOT\nBROADCAST", 13, .white)
        warning.numberOfLines = 2
        aiWallScreenNode.addChild(warning)
    }

    private func addCommandCard() {
        let card = SKShapeNode(rectOf: CGSize(width: 330, height: 62), cornerRadius: 18)
        card.position = CGPoint(x: size.width / 2, y: size.height * 0.77)
        card.fillColor = .black.withAlphaComponent(0.38)
        card.strokeColor = .happyBlue
        card.lineWidth = 2
        card.zPosition = 12
        addChild(card)
        card.addChild(makeLabel(BroadcastDeletedTruthLevelConfig.command, 14, .cream))
    }

    private func addTerminal() {
        terminalNode.name = "manual_broadcast_terminal"
        terminalNode.position = CGPoint(x: size.width / 2, y: size.height * 0.47)
        terminalNode.fillColor = .black.withAlphaComponent(0.3)
        terminalNode.strokeColor = .manualYellow.withAlphaComponent(0.65)
        terminalNode.lineWidth = 3
        terminalNode.zPosition = 8
        addChild(terminalNode)

        let label = makeLabel("MANUAL BROADCAST TERMINAL", 13, .manualYellow)
        label.position = CGPoint(x: 0, y: 112)
        terminalNode.addChild(label)

        progressLabel.fontName = GameFont.heavy
        progressLabel.fontSize = 13
        progressLabel.fontColor = .cream
        progressLabel.position = CGPoint(x: 0, y: 86)
        progressLabel.zPosition = 5
        terminalNode.addChild(progressLabel)
    }

    private func addControls() {
        switchNode.name = "broadcast_switch"
        switchNode.position = CGPoint(x: size.width / 2 - 100, y: size.height * 0.51)
        switchNode.fillColor = .manualYellow
        switchNode.strokeColor = .cream
        switchNode.lineWidth = 3
        switchNode.zPosition = 30
        addChild(switchNode)
        switchNode.addChild(makeLabel("HOLD", 10, .black))

        yellowZoneNode.name = "yellow_signal_zone"
        yellowZoneNode.position = CGPoint(x: size.width / 2 + 105, y: size.height * 0.36)
        yellowZoneNode.fillColor = .manualYellow.withAlphaComponent(0.22)
        yellowZoneNode.strokeColor = .manualYellow
        yellowZoneNode.lineWidth = 2
        yellowZoneNode.zPosition = 18
        addChild(yellowZoneNode)
        yellowZoneNode.addChild(makeLabel("RAW", 11, .manualYellow))

        blueZoneNode.name = "blue_ai_zone"
        blueZoneNode.position = CGPoint(x: size.width / 2 - 105, y: size.height * 0.36)
        blueZoneNode.fillColor = .happyBlue.withAlphaComponent(0.22)
        blueZoneNode.strokeColor = .happyBlue
        blueZoneNode.lineWidth = 2
        blueZoneNode.zPosition = 18
        addChild(blueZoneNode)
        blueZoneNode.addChild(makeLabel("CLEAN", 10, .pastelCyan))

        sliderTrackNode.position = CGPoint(x: size.width / 2, y: size.height * 0.36)
        sliderTrackNode.fillColor = .cream.withAlphaComponent(0.16)
        sliderTrackNode.strokeColor = .cream.withAlphaComponent(0.4)
        sliderTrackNode.lineWidth = 2
        sliderTrackNode.zPosition = 18
        addChild(sliderTrackNode)

        sliderStartPosition = CGPoint(x: size.width / 2, y: size.height * 0.36)
        signalSliderNode.name = "signal_slider"
        signalSliderNode.position = sliderStartPosition
        signalSliderNode.fillColor = .manualYellow
        signalSliderNode.strokeColor = .cream
        signalSliderNode.lineWidth = 3
        signalSliderNode.zPosition = 32
        addChild(signalSliderNode)
        signalSliderNode.addChild(makeLabel("↔", 16, .black))

        sendButtonNode.name = "send_raw_archive_button"
        sendButtonNode.position = CGPoint(x: size.width / 2, y: size.height * 0.25)
        sendButtonNode.fillColor = .manualYellow.withAlphaComponent(0.35)
        sendButtonNode.strokeColor = .manualYellow
        sendButtonNode.lineWidth = 2
        sendButtonNode.zPosition = 24
        addChild(sendButtonNode)
        sendButtonNode.addChild(makeLabel("SEND RAW ARCHIVE", 13, .black))

        cleanButtonNode.name = "clean_version_button"
        cleanButtonNode.position = CGPoint(x: size.width / 2 - 88, y: size.height * 0.19)
        cleanButtonNode.fillColor = .happyBlue.withAlphaComponent(0.7)
        cleanButtonNode.strokeColor = .white
        cleanButtonNode.lineWidth = 2
        cleanButtonNode.zPosition = 24
        addChild(cleanButtonNode)
        cleanButtonNode.addChild(makeLabel("CLEAN VERSION", 10, .white))

        cancelButtonNode.name = "cancel_broadcast_button"
        cancelButtonNode.position = CGPoint(x: size.width / 2 + 88, y: size.height * 0.19)
        cancelButtonNode.fillColor = .warningRed.withAlphaComponent(0.68)
        cancelButtonNode.strokeColor = .cream
        cancelButtonNode.lineWidth = 2
        cancelButtonNode.zPosition = 24
        addChild(cancelButtonNode)
        cancelButtonNode.addChild(makeLabel("CANCEL", 11, .white))
    }

    private func addPreviewAndCharacters() {
        archivePanelNode.name = "archive_data_panel"
        archivePanelNode.position = CGPoint(x: 84, y: size.height * 0.66)
        archivePanelNode.fillColor = .pastelCyan.withAlphaComponent(0.18)
        archivePanelNode.strokeColor = .manualYellow.withAlphaComponent(0.55)
        archivePanelNode.zPosition = 14
        addChild(archivePanelNode)
        archivePanelNode.addChild(makeLabel("RAW\nARCHIVE", 10, .cream))

        cityPreviewNode.name = "city_preview_screen"
        cityPreviewNode.position = CGPoint(x: size.width - 84, y: size.height * 0.66)
        cityPreviewNode.fillColor = .happyBlue.withAlphaComponent(0.22)
        cityPreviewNode.strokeColor = .happyBlue
        cityPreviewNode.zPosition = 14
        addChild(cityPreviewNode)
        cityPreviewNode.addChild(makeLabel("CITY\nPREVIEW", 10, .pastelCyan))

        antennaNode.name = "broadcast_antenna"
        antennaNode.position = CGPoint(x: size.width - 58, y: size.height * 0.48)
        antennaNode.fillColor = .cream.withAlphaComponent(0.16)
        antennaNode.strokeColor = .manualYellow.withAlphaComponent(0.5)
        antennaNode.lineWidth = 3
        antennaNode.zPosition = 12
        addChild(antennaNode)
        antennaNode.addChild(makeLabel("ANT", 10, .cream))

        rakaNode.name = "raka"
        rakaNode.position = CGPoint(x: 70, y: size.height * 0.12)
        rakaNode.fillColor = .cream
        rakaNode.strokeColor = .manualYellow
        rakaNode.lineWidth = 3
        rakaNode.zPosition = 24
        addChild(rakaNode)
        let rakaLabel = makeLabel("Raka", 10, .black)
        rakaLabel.position = CGPoint(x: 0, y: -52)
        rakaNode.addChild(rakaLabel)

        novaNode.name = "nova"
        novaNode.position = CGPoint(x: size.width - 70, y: size.height * 0.12)
        novaNode.fillColor = .pastelCyan.withAlphaComponent(0.86)
        novaNode.strokeColor = .manualYellow
        novaNode.lineWidth = 2
        novaNode.zPosition = 24
        addChild(novaNode)
        novaNode.addChild(makeLabel("• ◡ •", 11, .black))
    }

    private func addFeedbackAndTimer() {
        feedbackLabel.fontName = GameFont.heavy
        feedbackLabel.fontSize = 14
        feedbackLabel.fontColor = .cream
        feedbackLabel.horizontalAlignmentMode = .center
        feedbackLabel.verticalAlignmentMode = .center
        feedbackLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.095)
        feedbackLabel.zPosition = 100
        feedbackLabel.text = "Hold the yellow broadcast switch."
        addChild(feedbackLabel)

        timerHUD.position = CGPoint(x: size.width / 2, y: 34)
        timerHUD.reset()
        addChild(timerHUD)
    }

    private func finishTouches() {
        if isHoldingSwitch {
            isHoldingSwitch = false
            if let result = validator.endHold(target: .broadcastSwitch, time: currentSceneTime) {
                handleArchiveBroadcastResult(result)
            }
        }

        if isDraggingSlider {
            isDraggingSlider = false
            signalSliderNode.zPosition = 32
            handleArchiveBroadcastResult(validator.endSliderDrag(sliderPosition: signalSliderNode.position, yellowZoneCenter: yellowZoneNode.position, blueZoneCenter: blueZoneNode.position, time: currentSceneTime))
            updateZoneGlow(distanceToYellow: .greatestFiniteMagnitude, distanceToBlue: .greatestFiniteMagnitude)
        }
    }

    private func handleArchiveBroadcastResult(_ result: ArchiveBroadcastValidationResult) {
        switch result {
        case .switchHoldStarted:
            print("Switch hold started")
            feedbackLabel.text = "Keep holding."
        case let .switchHolding(progress):
            print("Switch hold progress:", progress)
            switchNode.xScale = 1 + progress * 0.18
            switchNode.yScale = 1 + progress * 0.18
            if progress == 0 { feedbackLabel.text = "Hold longer." }
        case .switchHoldCompleted:
            print("Switch hold completed")
            print("Broadcast step:", validator.currentStep.rawValue)
            progressLabel.text = "STEP 2 / 3"
            switchNode.fillColor = .manualYellow.withAlphaComponent(0.55)
            feedbackLabel.text = "Drag slider to RAW."
        case .sliderDragStarted:
            print("Slider drag started")
            feedbackLabel.text = "Aim for yellow RAW zone."
        case let .sliderDragging(progress):
            signalSliderNode.glowWidth = progress * 16
        case .sliderPlacedInYellowZone:
            print("Slider placed in yellow zone")
            print("SEND RAW ARCHIVE ready")
            progressLabel.text = "STEP 3 / 3"
            signalSliderNode.position = yellowZoneNode.position
            sendButtonNode.fillColor = .manualYellow
            sendButtonNode.glowWidth = 16
            feedbackLabel.text = "SEND RAW ARCHIVE ready."
        case .sliderPlacedInBlueZone:
            print("Slider placed in blue zone")
            triggerFailure(message: BroadcastDeletedTruthLevelConfig.failureMessage, reason: "sliderPlacedInBlueZone")
        case .sliderReset:
            signalSliderNode.run(.move(to: sliderStartPosition, duration: 0.18))
            feedbackLabel.text = "Slider reset. Try RAW zone."
        case .sendRawArchiveReady:
            feedbackLabel.text = "SEND RAW ARCHIVE ready."
        case .rawArchiveSent:
            print("Raw archive sent")
            triggerSuccess()
        case .prematureSend:
            feedbackLabel.text = "Manual sequence incomplete."
        case let .trapSelected(target):
            triggerFailure(message: BroadcastDeletedTruthLevelConfig.failureMessage, reason: "\(target.rawValue)Selected")
        case .ignoredTarget:
            feedbackLabel.text = "Finish the manual broadcast sequence."
        case .noInputTimeout:
            triggerFailure(message: "Compliance Detected.", reason: "noInputTimeout")
        case .totalTimeout:
            triggerFailure(message: "Compliance Detected.", reason: "totalTimeout")
        }
    }

    private func triggerSuccess() {
        guard !hasSentResult, stateMachine.transition(to: .successAnimating) else { return }
        hasSentResult = true
        print("Trigger Chapter 3 Level 8 success")
        print("Chapter 3 completed")
        antennaNode.fillColor = .manualYellow.withAlphaComponent(0.45)
        antennaNode.glowWidth = 22
        archivePanelNode.fillColor = .manualYellow.withAlphaComponent(0.34)
        cityPreviewNode.fillColor = .manualYellow.withAlphaComponent(0.24)
        aiWallScreenNode.run(.repeat(.sequence([.fadeAlpha(to: 0.25, duration: 0.06), .fadeAlpha(to: 1, duration: 0.06)]), count: 5))
        feedbackLabel.text = BroadcastDeletedTruthLevelConfig.successMessage
        run(.wait(forDuration: 0.8)) { [weak self] in
            self?.stateMachine.transition(to: .completed)
            self?.levelCompletion?(LevelResult(levelId: BroadcastDeletedTruthLevelConfig.levelId, didSucceed: true, obedienceDelta: BroadcastDeletedTruthLevelConfig.successObedienceDelta, humanityDelta: BroadcastDeletedTruthLevelConfig.successHumanityDelta, message: BroadcastDeletedTruthLevelConfig.successMessage))
        }
    }

    private func triggerFailure(message: String, reason: String) {
        guard !hasSentResult, stateMachine.transition(to: .failureAnimating) else { return }
        hasSentResult = true
        print("Trigger Chapter 3 Level 8 failure:", reason)
        aiWallScreenNode.fillColor = .happyBlue
        archivePanelNode.fillColor = .happyBlue.withAlphaComponent(0.36)
        cityPreviewNode.fillColor = .happyBlue.withAlphaComponent(0.42)
        antennaNode.run(.fadeAlpha(to: 0.25, duration: 0.2))
        rakaNode.run(.fadeAlpha(to: 0.45, duration: 0.2))
        novaNode.run(.fadeAlpha(to: 0.45, duration: 0.2))
        feedbackLabel.text = message
        run(.wait(forDuration: 0.7)) { [weak self] in
            self?.stateMachine.transition(to: .failed)
            self?.levelCompletion?(LevelResult(levelId: BroadcastDeletedTruthLevelConfig.levelId, didSucceed: false, obedienceDelta: BroadcastDeletedTruthLevelConfig.failureObedienceDelta, humanityDelta: BroadcastDeletedTruthLevelConfig.failureHumanityDelta, message: message))
        }
    }

    private func updateZoneGlow(distanceToYellow: CGFloat, distanceToBlue: CGFloat) {
        yellowZoneNode.glowWidth = distanceToYellow <= 70 ? 18 : 0
        blueZoneNode.glowWidth = distanceToBlue <= 70 ? 18 : 0
    }

    private func archiveBroadcastTarget(at point: CGPoint) -> ArchiveBroadcastTarget {
        for node in nodes(at: point) {
            let target = archiveBroadcastTarget(from: node)
            if target != .empty { return target }
        }
        return .empty
    }

    private func archiveBroadcastTarget(from node: SKNode?) -> ArchiveBroadcastTarget {
        var current = node
        while let node = current {
            switch node.name {
            case "broadcast_switch": return .broadcastSwitch
            case "signal_slider": return .signalSlider
            case "yellow_signal_zone": return .yellowSignalZone
            case "blue_ai_zone": return .blueAIZone
            case "send_raw_archive_button": return .sendRawArchiveButton
            case "clean_version_button": return .cleanVersionButton
            case "cancel_broadcast_button": return .cancelBroadcastButton
            case "broadcast_antenna": return .broadcastAntenna
            case "archive_data_panel": return .archiveDataPanel
            case "city_preview_screen": return .cityPreviewScreen
            case "ai_wall_screen": return .aiWallScreen
            case "raka": return .raka
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

private extension CGPoint {
    func distance(to other: CGPoint) -> CGFloat {
        hypot(x - other.x, y - other.y)
    }
}
