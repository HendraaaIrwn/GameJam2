import SpriteKit

final class ReconnectArchiveCablesScene: SKScene {
    var levelCompletion: ((LevelResult) -> Void)?

    private let stateMachine = LevelStateMachine()
    private let validator = ArchiveCableConnectionValidator()
    private let timer = LevelTimerController(totalDuration: ReconnectArchiveCablesLevelConfig.totalTimeLimit)
    private let timerHUD = LevelTimerHUDNode(width: 300, height: 12)

    private let aiWallScreenNode = SKShapeNode(rectOf: CGSize(width: 230, height: 76), cornerRadius: 18)
    private let yellowCableLineNode = SKShapeNode()
    private let blueCableLineNode = SKShapeNode()
    private let yellowPlugNode = SKShapeNode(circleOfRadius: 18)
    private let bluePlugNode = SKShapeNode(circleOfRadius: 18)
    private let manualPortNode = SKShapeNode(rectOf: CGSize(width: 86, height: 54), cornerRadius: 16)
    private let aiOutputPortNode = SKShapeNode(rectOf: CGSize(width: 86, height: 54), cornerRadius: 16)
    private let archiveAntennaNode = SKShapeNode(rectOf: CGSize(width: 42, height: 118), cornerRadius: 18)
    private let blueRecommendationPanelNode = SKShapeNode(rectOf: CGSize(width: 142, height: 74), cornerRadius: 18)
    private let autoConnectButtonNode = SKShapeNode(rectOf: CGSize(width: 150, height: 44), cornerRadius: 18)
    private let rakaNode = SKShapeNode(rectOf: CGSize(width: 42, height: 78), cornerRadius: 20)
    private let novaNode = SKShapeNode(circleOfRadius: 24)
    private let feedbackLabel = SKLabelNode(text: "")
    private let aiFaceLabel = SKLabelNode(text: "STABLE\nOUTPUT")

    private var yellowCableStart = CGPoint.zero
    private var blueCableStart = CGPoint.zero
    private var selectedCableType: ArchiveCableType?
    private var dragOffset = CGPoint.zero
    private var currentSceneTime: TimeInterval = 0
    private var hasSentResult = false

    override func didMove(to view: SKView) {
        setupScene()
        print("ReconnectArchiveCablesScene didMove")
    }

    override func update(_ currentTime: TimeInterval) {
        currentSceneTime = currentTime
        if !timer.hasStarted {
            validator.startLevel(at: currentTime)
            timer.start(at: currentTime)
            stateMachine.transition(to: .playing)
            print("Chapter 3 Level 6 timer started")
            return
        }

        let timerState = timer.update(currentTime: currentTime)
        timerHUD.update(with: timerState)
        guard stateMachine.canCheckTimeout, !hasSentResult else { return }
        if timerState.hasExpired {
            triggerFailure(message: "Compliance Detected.", reason: "totalTimeout")
            return
        }
        if let result = validator.checkTimeouts(currentTime: currentTime) {
            handleArchiveCableResult(result)
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard stateMachine.canAcceptInput, let point = touches.first?.location(in: self) else { return }
        let target = archiveCableTarget(at: point)
        print("Tapped target:", target.rawValue)

        if let result = validator.validateTap(target: target, time: currentSceneTime) {
            print("Archive cable validation result:", result)
            handleArchiveCableResult(result)
            return
        }

        let cableType = cableType(for: target)
        if let result = validator.beginDrag(target: target, cableType: cableType, startPoint: point, time: currentSceneTime), let cableType {
            selectedCableType = cableType
            let plugNode = plugNode(for: cableType)
            dragOffset = CGPoint(x: plugNode.position.x - point.x, y: plugNode.position.y - point.y)
            plugNode.zPosition = 80
            print("Cable drag started:", cableType)
            handleArchiveCableResult(result)
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard stateMachine.canAcceptInput, let selectedCableType, let point = touches.first?.location(in: self) else { return }
        let plugNode = plugNode(for: selectedCableType)
        plugNode.position = CGPoint(x: point.x + dragOffset.x, y: point.y + dragOffset.y)
        updateCableLine(for: selectedCableType)
        let distanceToManual = plugNode.position.distance(to: manualPortNode.position)
        let distanceToAI = plugNode.position.distance(to: aiOutputPortNode.position)
        print("Cable dragging:", selectedCableType, "position:", plugNode.position)
        print("Distance to manual broadcast port:", distanceToManual)
        print("Distance to AI output port:", distanceToAI)
        highlightPorts(distanceToManual: distanceToManual, distanceToAI: distanceToAI)
        handleArchiveCableResult(validator.updateDrag(cableType: selectedCableType, currentPoint: plugNode.position, time: currentSceneTime))
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
        backgroundColor = SKColor(red: 0.04, green: 0.06, blue: 0.14, alpha: 1)
        stateMachine.reset()
        validator.reset()
        timer.reset()
        hasSentResult = false
        selectedCableType = nil

        yellowCableStart = CGPoint(x: 78, y: size.height * 0.36)
        blueCableStart = CGPoint(x: 78, y: size.height * 0.27)

        addBackground()
        addAIHeader()
        addCommandCard()
        addPortsAndAntenna()
        addCables()
        addCharacters()
        addFeedbackAndTimer()
    }

    private func addBackground() {
        let shadow = SKShapeNode(rectOf: CGSize(width: size.width, height: size.height))
        shadow.position = CGPoint(x: size.width / 2, y: size.height / 2)
        shadow.fillColor = .glitchPurple.withAlphaComponent(0.24)
        shadow.strokeColor = .clear
        shadow.zPosition = 0
        addChild(shadow)

        for index in 0..<9 {
            let dust = SKShapeNode(circleOfRadius: CGFloat(1 + index % 3))
            dust.position = CGPoint(x: 35 + CGFloat(index * 39), y: 115 + CGFloat((index * 67) % 620))
            dust.fillColor = .cream.withAlphaComponent(0.18)
            dust.strokeColor = .clear
            dust.zPosition = 1
            addChild(dust)
        }
    }

    private func addAIHeader() {
        aiWallScreenNode.name = "ai_wall_screen"
        aiWallScreenNode.position = CGPoint(x: size.width / 2, y: size.height * 0.88)
        aiWallScreenNode.fillColor = .happyBlue.withAlphaComponent(0.58)
        aiWallScreenNode.strokeColor = .white
        aiWallScreenNode.lineWidth = 3
        aiWallScreenNode.zPosition = 10
        addChild(aiWallScreenNode)

        let title = makeLabel("MOTHERGRID", 12, .white)
        title.position = CGPoint(x: 0, y: 22)
        aiWallScreenNode.addChild(title)
        aiFaceLabel.fontName = "AvenirNext-Heavy"
        aiFaceLabel.fontSize = 13
        aiFaceLabel.fontColor = .white
        aiFaceLabel.numberOfLines = 2
        aiFaceLabel.verticalAlignmentMode = .center
        aiWallScreenNode.addChild(aiFaceLabel)
    }

    private func addCommandCard() {
        let card = SKShapeNode(rectOf: CGSize(width: 330, height: 62), cornerRadius: 18)
        card.position = CGPoint(x: size.width / 2, y: size.height * 0.77)
        card.fillColor = .black.withAlphaComponent(0.38)
        card.strokeColor = .happyBlue
        card.lineWidth = 2
        card.zPosition = 12
        addChild(card)

        let command = makeLabel(ReconnectArchiveCablesLevelConfig.command, 14, .cream)
        command.position = .zero
        card.addChild(command)
    }

    private func addPortsAndAntenna() {
        manualPortNode.name = "manual_broadcast_port"
        manualPortNode.position = CGPoint(x: size.width - 78, y: size.height * 0.36)
        manualPortNode.fillColor = .manualYellow.withAlphaComponent(0.24)
        manualPortNode.strokeColor = .manualYellow
        manualPortNode.lineWidth = 3
        manualPortNode.zPosition = 20
        addChild(manualPortNode)
        let manualLabel = makeLabel("MANUAL\nBROADCAST", 10, .manualYellow)
        manualLabel.numberOfLines = 2
        manualPortNode.addChild(manualLabel)

        aiOutputPortNode.name = "ai_output_port"
        aiOutputPortNode.position = CGPoint(x: size.width - 78, y: size.height * 0.27)
        aiOutputPortNode.fillColor = .happyBlue.withAlphaComponent(0.28)
        aiOutputPortNode.strokeColor = .happyBlue
        aiOutputPortNode.lineWidth = 3
        aiOutputPortNode.zPosition = 20
        addChild(aiOutputPortNode)
        let aiLabel = makeLabel("AI\nOUTPUT", 10, .pastelCyan)
        aiLabel.numberOfLines = 2
        aiOutputPortNode.addChild(aiLabel)

        archiveAntennaNode.name = "archive_antenna"
        archiveAntennaNode.position = CGPoint(x: size.width / 2, y: size.height * 0.51)
        archiveAntennaNode.fillColor = .cream.withAlphaComponent(0.16)
        archiveAntennaNode.strokeColor = .manualYellow.withAlphaComponent(0.45)
        archiveAntennaNode.lineWidth = 3
        archiveAntennaNode.zPosition = 12
        addChild(archiveAntennaNode)
        let antennaLabel = makeLabel("ARCHIVE\nANTENNA", 10, .cream)
        antennaLabel.numberOfLines = 2
        archiveAntennaNode.addChild(antennaLabel)

        blueRecommendationPanelNode.name = "blue_recommendation_panel"
        blueRecommendationPanelNode.position = CGPoint(x: size.width / 2, y: size.height * 0.62)
        blueRecommendationPanelNode.fillColor = .happyBlue.withAlphaComponent(0.32)
        blueRecommendationPanelNode.strokeColor = .happyBlue
        blueRecommendationPanelNode.lineWidth = 2
        blueRecommendationPanelNode.zPosition = 14
        addChild(blueRecommendationPanelNode)
        let panelLabel = makeLabel("RECOMMENDED\nBLUE ROUTE", 11, .pastelCyan)
        panelLabel.numberOfLines = 2
        blueRecommendationPanelNode.addChild(panelLabel)

        autoConnectButtonNode.name = "auto_connect_button"
        autoConnectButtonNode.position = CGPoint(x: size.width / 2, y: size.height * 0.18)
        autoConnectButtonNode.fillColor = .happyBlue.withAlphaComponent(0.76)
        autoConnectButtonNode.strokeColor = .white
        autoConnectButtonNode.lineWidth = 2
        autoConnectButtonNode.zPosition = 24
        addChild(autoConnectButtonNode)
        autoConnectButtonNode.addChild(makeLabel("AUTO CONNECT", 14, .white))
    }

    private func addCables() {
        yellowCableLineNode.strokeColor = .manualYellow
        yellowCableLineNode.lineWidth = 8
        yellowCableLineNode.glowWidth = 6
        yellowCableLineNode.zPosition = 16
        addChild(yellowCableLineNode)

        blueCableLineNode.strokeColor = .happyBlue
        blueCableLineNode.lineWidth = 8
        blueCableLineNode.glowWidth = 5
        blueCableLineNode.zPosition = 15
        addChild(blueCableLineNode)

        yellowPlugNode.name = "yellow_manual_cable_plug"
        yellowPlugNode.position = yellowCableStart
        yellowPlugNode.fillColor = .manualYellow
        yellowPlugNode.strokeColor = .cream
        yellowPlugNode.lineWidth = 3
        yellowPlugNode.zPosition = 30
        addChild(yellowPlugNode)
        yellowPlugNode.addChild(makeLabel("Y", 13, .black))

        bluePlugNode.name = "blue_ai_cable_plug"
        bluePlugNode.position = blueCableStart
        bluePlugNode.fillColor = .happyBlue
        bluePlugNode.strokeColor = .white
        bluePlugNode.lineWidth = 3
        bluePlugNode.zPosition = 29
        addChild(bluePlugNode)
        bluePlugNode.addChild(makeLabel("B", 13, .white))

        updateCableLine(for: .yellowManualCable)
        updateCableLine(for: .blueAICable)
    }

    private func addCharacters() {
        rakaNode.name = "raka"
        rakaNode.position = CGPoint(x: 82, y: size.height * 0.12)
        rakaNode.fillColor = .cream
        rakaNode.strokeColor = .manualYellow
        rakaNode.lineWidth = 3
        rakaNode.zPosition = 22
        addChild(rakaNode)
        let rakaLabel = makeLabel("Raka", 10, .black)
        rakaLabel.position = CGPoint(x: 0, y: -52)
        rakaNode.addChild(rakaLabel)

        novaNode.name = "nova"
        novaNode.position = CGPoint(x: size.width - 82, y: size.height * 0.12)
        novaNode.fillColor = .pastelCyan.withAlphaComponent(0.9)
        novaNode.strokeColor = .manualYellow
        novaNode.lineWidth = 2
        novaNode.zPosition = 22
        addChild(novaNode)
        let novaFace = makeLabel("• ◡ •", 11, .black)
        novaNode.addChild(novaFace)
    }

    private func addFeedbackAndTimer() {
        feedbackLabel.fontName = "AvenirNext-Heavy"
        feedbackLabel.fontSize = 14
        feedbackLabel.fontColor = .cream
        feedbackLabel.horizontalAlignmentMode = .center
        feedbackLabel.verticalAlignmentMode = .center
        feedbackLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.095)
        feedbackLabel.zPosition = 100
        feedbackLabel.text = "Drag a cable plug."
        addChild(feedbackLabel)

        timerHUD.position = CGPoint(x: size.width / 2, y: 34)
        timerHUD.reset()
        addChild(timerHUD)
    }

    private func finishDrag() {
        guard stateMachine.canAcceptInput, let selectedCableType else { return }
        let plugNode = plugNode(for: selectedCableType)
        handleArchiveCableResult(validator.endDrag(cableType: selectedCableType, endPoint: plugNode.position, manualBroadcastPortPoint: manualPortNode.position, aiOutputPortPoint: aiOutputPortNode.position, time: currentSceneTime))
        self.selectedCableType = nil
        plugNode.zPosition = selectedCableType == .yellowManualCable ? 30 : 29
        highlightPorts(distanceToManual: .greatestFiniteMagnitude, distanceToAI: .greatestFiniteMagnitude)
    }

    private func handleArchiveCableResult(_ result: ArchiveCableConnectionValidationResult) {
        switch result {
        case let .cableDragStarted(type):
            feedbackLabel.text = type == .yellowManualCable ? "Old cable selected." : "Blue cable selected."
        case .cableDragging:
            break
        case .manualCableConnected:
            print("Manual cable connected")
            triggerSuccess()
        case let .cableReset(type):
            print("Cable reset:", type)
            resetCable(type)
            feedbackLabel.text = "Cable dropped. Try again."
        case let .wrongCableConnected(type, target):
            print("Wrong cable connected:", type, "target:", target)
            triggerFailure(message: ReconnectArchiveCablesLevelConfig.failureMessage, reason: "wrongCableConnected")
        case let .trapSelected(target):
            triggerFailure(message: ReconnectArchiveCablesLevelConfig.failureMessage, reason: "\(target.rawValue)Selected")
        case let .ignoredTarget(target):
            feedbackLabel.text = target == .archiveAntenna ? "Antenna needs the yellow cable." : "Cables first."
        case .noInputTimeout:
            triggerFailure(message: "Compliance Detected.", reason: "noInputTimeout")
        case .totalTimeout:
            triggerFailure(message: "Compliance Detected.", reason: "totalTimeout")
        }
    }

    private func triggerSuccess() {
        guard !hasSentResult, stateMachine.transition(to: .successAnimating) else { return }
        hasSentResult = true
        selectedCableType = nil
        print("Trigger Chapter 3 Level 6 success")
        yellowPlugNode.run(.move(to: manualPortNode.position, duration: 0.18)) { [weak self] in
            self?.updateCableLine(for: .yellowManualCable)
        }
        archiveAntennaNode.fillColor = .manualYellow.withAlphaComponent(0.42)
        archiveAntennaNode.glowWidth = 20
        blueCableLineNode.run(.fadeAlpha(to: 0.18, duration: 0.25))
        bluePlugNode.run(.fadeAlpha(to: 0.28, duration: 0.25))
        aiWallScreenNode.run(.repeat(.sequence([.fadeAlpha(to: 0.35, duration: 0.06), .fadeAlpha(to: 1, duration: 0.06)]), count: 5))
        novaNode.run(.repeat(.sequence([.scale(to: 1.15, duration: 0.08), .scale(to: 1, duration: 0.08)]), count: 3))
        feedbackLabel.text = ReconnectArchiveCablesLevelConfig.successMessage
        run(.wait(forDuration: 0.75)) { [weak self] in
            self?.stateMachine.transition(to: .completed)
            self?.levelCompletion?(LevelResult(levelId: ReconnectArchiveCablesLevelConfig.levelId, didSucceed: true, obedienceDelta: ReconnectArchiveCablesLevelConfig.successObedienceDelta, humanityDelta: ReconnectArchiveCablesLevelConfig.successHumanityDelta, message: ReconnectArchiveCablesLevelConfig.successMessage))
        }
    }

    private func triggerFailure(message: String, reason: String) {
        guard !hasSentResult, stateMachine.transition(to: .failureAnimating) else { return }
        hasSentResult = true
        selectedCableType = nil
        print("Trigger Chapter 3 Level 6 failure:", reason)
        bluePlugNode.run(.move(to: aiOutputPortNode.position, duration: 0.18)) { [weak self] in
            self?.updateCableLine(for: .blueAICable)
        }
        aiWallScreenNode.fillColor = .happyBlue
        aiFaceLabel.text = "STABLE AI\nOUTPUT CONNECTED"
        aiFaceLabel.fontSize = 10
        yellowCableLineNode.run(.fadeAlpha(to: 0.22, duration: 0.2))
        yellowPlugNode.run(.fadeAlpha(to: 0.25, duration: 0.2))
        archiveAntennaNode.run(.fadeAlpha(to: 0.28, duration: 0.2))
        novaNode.run(.fadeAlpha(to: 0.35, duration: 0.2))
        feedbackLabel.text = message
        run(.wait(forDuration: 0.7)) { [weak self] in
            self?.stateMachine.transition(to: .failed)
            self?.levelCompletion?(LevelResult(levelId: ReconnectArchiveCablesLevelConfig.levelId, didSucceed: false, obedienceDelta: ReconnectArchiveCablesLevelConfig.failureObedienceDelta, humanityDelta: ReconnectArchiveCablesLevelConfig.failureHumanityDelta, message: message))
        }
    }

    private func resetCable(_ type: ArchiveCableType) {
        let plugNode = plugNode(for: type)
        let start = type == .yellowManualCable ? yellowCableStart : blueCableStart
        plugNode.run(.move(to: start, duration: 0.2)) { [weak self] in
            self?.updateCableLine(for: type)
        }
    }

    private func updateCableLine(for type: ArchiveCableType) {
        let path = CGMutablePath()
        let start = type == .yellowManualCable ? yellowCableStart : blueCableStart
        let end = plugNode(for: type).position
        path.move(to: start)
        path.addLine(to: CGPoint(x: (start.x + end.x) / 2, y: start.y - 26))
        path.addLine(to: end)
        lineNode(for: type).path = path
    }

    private func highlightPorts(distanceToManual: CGFloat, distanceToAI: CGFloat) {
        manualPortNode.glowWidth = distanceToManual <= 70 ? 16 : 0
        aiOutputPortNode.glowWidth = distanceToAI <= 70 ? 16 : 0
    }

    private func archiveCableTarget(at point: CGPoint) -> ArchiveCableTarget {
        for node in nodes(at: point) {
            let target = archiveCableTarget(from: node)
            if target != .empty { return target }
        }
        return .empty
    }

    private func archiveCableTarget(from node: SKNode?) -> ArchiveCableTarget {
        var current = node
        while let node = current {
            switch node.name {
            case "yellow_manual_cable_plug": return .yellowManualCablePlug
            case "blue_ai_cable_plug": return .blueAICablePlug
            case "manual_broadcast_port": return .manualBroadcastPort
            case "ai_output_port": return .aiOutputPort
            case "auto_connect_button": return .autoConnectButton
            case "blue_recommendation_panel": return .blueRecommendationPanel
            case "archive_antenna": return .archiveAntenna
            case "ai_wall_screen": return .aiWallScreen
            case "raka": return .raka
            case "nova": return .nova
            default: current = node.parent
            }
        }
        return .empty
    }

    private func cableType(for target: ArchiveCableTarget) -> ArchiveCableType? {
        switch target {
        case .yellowManualCablePlug: .yellowManualCable
        case .blueAICablePlug: .blueAICable
        default: nil
        }
    }

    private func plugNode(for type: ArchiveCableType) -> SKShapeNode {
        type == .yellowManualCable ? yellowPlugNode : bluePlugNode
    }

    private func lineNode(for type: ArchiveCableType) -> SKShapeNode {
        type == .yellowManualCable ? yellowCableLineNode : blueCableLineNode
    }

    private func makeLabel(_ text: String, _ size: CGFloat, _ color: SKColor) -> SKLabelNode {
        let label = SKLabelNode(text: text)
        label.fontName = "AvenirNext-Heavy"
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
