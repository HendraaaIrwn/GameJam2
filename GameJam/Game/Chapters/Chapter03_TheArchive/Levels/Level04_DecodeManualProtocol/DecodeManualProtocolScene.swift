import SpriteKit

class DecodeManualProtocolScene: BaseGameScene {
    var levelCompletion: ((LevelResult) -> Void)?

    private let stateMachine = LevelStateMachine()
    private let validator = ManualProtocolSequenceValidator()
    private let timer = LevelTimerController(totalDuration: DecodeManualProtocolLevelConfig.totalTimeLimit)
    private let timerHUD = LevelTimerHUDNode(width: 300, height: 14)

    private let aiWallScreenNode = SKShapeNode(rectOf: CGSize(width: 160, height: 76), cornerRadius: 22)
    private let aiFaceLabel = SKLabelNode(text: "◡")
    private let protocolTerminalNode = SKShapeNode(rectOf: CGSize(width: 250, height: 150), cornerRadius: 24)
    private let terminalLabel = SKLabelNode(text: "MANUAL PROTOCOL\nLOCKED")
    private let feedbackLabel = SKLabelNode(text: "")
    private let rakaNode = SKShapeNode(rectOf: CGSize(width: 52, height: 74), cornerRadius: 25)
    private let novaNode = SKShapeNode(circleOfRadius: 18)
    private let autoDecodeButtonNode = SKShapeNode(rectOf: CGSize(width: 142, height: 42), cornerRadius: 17)
    private let useHighlightedButtonNode = SKShapeNode(rectOf: CGSize(width: 164, height: 42), cornerRadius: 17)
    private let lineLayer = SKNode()

    private var manualSymbolNodes: [ManualProtocolSymbol: SKShapeNode] = [:]
    private var aiSymbolNodes: [ManualProtocolSymbol: SKShapeNode] = [:]
    private var progressDots: [SKShapeNode] = []
    private var currentSceneTime: TimeInterval = 0
    private var hasSentResult = false
    private var lastSelectedNode: SKNode?

    override func didMove(to view: SKView) {
        setupScene()
        print("DecodeManualProtocolScene didMove")
    }

    override func update(_ currentTime: TimeInterval) {
        currentSceneTime = currentTime
        if !timer.hasStarted {
            validator.startLevel(at: currentTime)
            timer.start(at: currentTime)
            stateMachine.transition(to: .playing)
            print("Chapter 3 Level 4 timer started")
            return
        }

        let timerState = timer.update(currentTime: currentTime)
        timerHUD.update(with: timerState)
        guard stateMachine.canCheckTimeout, !hasSentResult else { return }
        if timerState.hasExpired {
            triggerFailure(message: "Compliance Detected.", reason: "totalTimeout")
            return
        }
        if let timeoutResult = validator.checkTimeouts(currentTime: currentTime) {
            handleManualProtocolResult(timeoutResult)
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard stateMachine.canAcceptInput, let location = touches.first?.location(in: self) else { return }
        let tappedNodes = nodes(at: location)
        let tappedNode = tappedNodes.first
        let target = tappedNodes.map { manualProtocolTarget(from: $0) }.first { $0 != .empty } ?? .empty
        let symbol = tappedNodes.compactMap { manualProtocolSymbol(from: $0) }.first
        let expectedSymbol = validator.expectedSymbol
        print("Tapped node:", tappedNode?.name ?? "nil")
        print("Resolved protocol target:", target)
        print("Resolved protocol symbol:", symbol?.rawValue ?? "nil")
        if let expectedSymbol { print("Expected symbol:", expectedSymbol.rawValue) }

        guard let result = validator.validateTap(target: target, symbol: symbol, time: currentSceneTime) else { return }
        playTapSound()
        print("Manual protocol validation result:", result)
        lastSelectedNode = symbol.flatMap { manualSymbolNodes[$0] ?? aiSymbolNodes[$0] }
        handleManualProtocolResult(result)
    }

    private func setupScene() {
        removeAllChildren()
        removeAllActions()
        backgroundColor = SKColor(red: 0.05, green: 0.07, blue: 0.17, alpha: 1)
        stateMachine.reset()
        validator.reset()
        timer.reset()
        hasSentResult = false
        manualSymbolNodes.removeAll()
        aiSymbolNodes.removeAll()
        progressDots.removeAll()
        lastSelectedNode = nil

        addArchiveBackground()
        addAIHeader()
        addTerminal()
        addSymbols()
        addCharacters()
        addFeedbackAndTimer()
    }

    private func addArchiveBackground() {
        let shadow = SKShapeNode(rectOf: CGSize(width: size.width, height: size.height))
        shadow.position = CGPoint(x: size.width / 2, y: size.height / 2)
        shadow.fillColor = .glitchPurple.withAlphaComponent(0.28)
        shadow.strokeColor = .clear
        shadow.zPosition = 0
        addChild(shadow)
    }

    private func addAIHeader() {
        aiWallScreenNode.name = "ai_wall_screen"
        aiWallScreenNode.position = CGPoint(x: size.width / 2, y: size.height * 0.86)
        aiWallScreenNode.fillColor = .happyBlue.withAlphaComponent(0.62)
        aiWallScreenNode.strokeColor = .white
        aiWallScreenNode.lineWidth = 3
        aiWallScreenNode.zPosition = 10
        addChild(aiWallScreenNode)
        let title = makeLabel("MOTHERGRID", 12, .white)
        title.position = CGPoint(x: 0, y: 21)
        aiWallScreenNode.addChild(title)
        aiFaceLabel.fontName = GameFont.heavy
        aiFaceLabel.fontSize = 30
        aiFaceLabel.fontColor = .white
        aiFaceLabel.verticalAlignmentMode = .center
        aiFaceLabel.position = CGPoint(x: 0, y: -12)
        aiWallScreenNode.addChild(aiFaceLabel)

        let commandCard = SKShapeNode(rectOf: CGSize(width: size.width * 0.82, height: 54), cornerRadius: 17)
        commandCard.position = CGPoint(x: size.width / 2, y: size.height * 0.76)
        commandCard.fillColor = .cream
        commandCard.strokeColor = .happyBlue
        commandCard.lineWidth = 3
        commandCard.zPosition = 10
        addChild(commandCard)
        commandCard.addChild(makeLabel(DecodeManualProtocolLevelConfig.command, 17, .happyBlue))
    }

    private func addTerminal() {
        lineLayer.zPosition = 30
        addChild(lineLayer)

        protocolTerminalNode.name = "protocol_terminal"
        protocolTerminalNode.position = CGPoint(x: size.width / 2, y: size.height * 0.56)
        protocolTerminalNode.fillColor = .cream.withAlphaComponent(0.78)
        protocolTerminalNode.strokeColor = .manualYellow
        protocolTerminalNode.lineWidth = 4
        protocolTerminalNode.zPosition = 5
        addChild(protocolTerminalNode)
        terminalLabel.fontName = GameFont.heavy
        terminalLabel.fontSize = 18
        terminalLabel.fontColor = .glitchPurple
        terminalLabel.numberOfLines = 2
        terminalLabel.verticalAlignmentMode = .center
        protocolTerminalNode.addChild(terminalLabel)

        let sequence = makeLabel("HAND → EYE → DOOR → SPARK", 13, .manualYellow)
        sequence.position = CGPoint(x: size.width / 2, y: size.height * 0.665)
        sequence.zPosition = 12
        addChild(sequence)

        for index in 0..<DecodeManualProtocolLevelConfig.requiredSequenceLength {
            let dot = SKShapeNode(circleOfRadius: 8)
            dot.position = CGPoint(x: size.width / 2 - 36 + CGFloat(index) * 24, y: size.height * 0.455)
            dot.fillColor = .clear
            dot.strokeColor = .manualYellow
            dot.lineWidth = 2
            dot.zPosition = 14
            addChild(dot)
            progressDots.append(dot)
        }
    }

    private func addSymbols() {
        addManualSymbol(.hand, label: "HAND", icon: "✋", position: CGPoint(x: size.width * 0.18, y: size.height * 0.36))
        addManualSymbol(.eye, label: "EYE", icon: "◉", position: CGPoint(x: size.width * 0.39, y: size.height * 0.36))
        addManualSymbol(.door, label: "DOOR", icon: "▯", position: CGPoint(x: size.width * 0.61, y: size.height * 0.36))
        addManualSymbol(.spark, label: "SPARK", icon: "✦", position: CGPoint(x: size.width * 0.82, y: size.height * 0.36))

        addAISymbol(.gear, label: "GEAR", icon: "⚙", position: CGPoint(x: size.width * 0.18, y: size.height * 0.25))
        addAISymbol(.shield, label: "SHIELD", icon: "⬟", position: CGPoint(x: size.width * 0.39, y: size.height * 0.25))
        addAISymbol(.route, label: "ROUTE", icon: "⇢", position: CGPoint(x: size.width * 0.61, y: size.height * 0.25))
        addAISymbol(.chair, label: "CHAIR", icon: "▱", position: CGPoint(x: size.width * 0.82, y: size.height * 0.25))

        autoDecodeButtonNode.name = "auto_decode_button"
        autoDecodeButtonNode.position = CGPoint(x: size.width * 0.3, y: size.height * 0.17)
        autoDecodeButtonNode.fillColor = .happyBlue
        autoDecodeButtonNode.strokeColor = .white
        autoDecodeButtonNode.lineWidth = 3
        autoDecodeButtonNode.zPosition = 12
        addChild(autoDecodeButtonNode)
        autoDecodeButtonNode.addChild(makeLabel("AUTO DECODE", 12, .white))

        useHighlightedButtonNode.name = "use_highlighted_button"
        useHighlightedButtonNode.position = CGPoint(x: size.width * 0.7, y: size.height * 0.17)
        useHighlightedButtonNode.fillColor = .happyBlue
        useHighlightedButtonNode.strokeColor = .white
        useHighlightedButtonNode.lineWidth = 3
        useHighlightedButtonNode.zPosition = 12
        addChild(useHighlightedButtonNode)
        useHighlightedButtonNode.addChild(makeLabel("USE HIGHLIGHTED", 12, .white))
    }

    private func addManualSymbol(_ symbol: ManualProtocolSymbol, label: String, icon: String, position: CGPoint) {
        let node = SKShapeNode(circleOfRadius: 29)
        node.name = "manual_symbol_\(symbol.rawValue)"
        node.position = position
        node.fillColor = .manualYellow.withAlphaComponent(0.9)
        node.strokeColor = .cream
        node.lineWidth = 3
        node.glowWidth = symbol == .hand ? 8 : 0
        node.zPosition = 12
        addChild(node)
        node.addChild(makeLabel(icon, 22, .glitchPurple))
        let text = makeLabel(label, 9, .manualYellow)
        text.position = CGPoint(x: 0, y: -42)
        node.addChild(text)
        manualSymbolNodes[symbol] = node
    }

    private func addAISymbol(_ symbol: ManualProtocolSymbol, label: String, icon: String, position: CGPoint) {
        let node = SKShapeNode(circleOfRadius: 27)
        node.name = "ai_symbol_\(symbol.rawValue)"
        node.position = position
        node.fillColor = .happyBlue.withAlphaComponent(0.88)
        node.strokeColor = .white
        node.lineWidth = 3
        node.glowWidth = 9
        node.zPosition = 12
        addChild(node)
        node.addChild(makeLabel(icon, 20, .white))
        let text = makeLabel(label, 9, .pastelCyan)
        text.position = CGPoint(x: 0, y: -40)
        node.addChild(text)
        aiSymbolNodes[symbol] = node
    }

    private func addCharacters() {
        rakaNode.name = "raka"
        rakaNode.position = CGPoint(x: size.width * 0.18, y: size.height * 0.1)
        rakaNode.fillColor = .happyBlue
        rakaNode.strokeColor = .white
        rakaNode.lineWidth = 3
        rakaNode.zPosition = 12
        addChild(rakaNode)
        for x in [-8, 8] as [CGFloat] {
            let eye = SKShapeNode(circleOfRadius: 3)
            eye.position = CGPoint(x: x, y: 12)
            eye.fillColor = .black
            eye.strokeColor = .clear
            rakaNode.addChild(eye)
        }
        let wrist = SKShapeNode(circleOfRadius: 7)
        wrist.position = CGPoint(x: 25, y: -4)
        wrist.fillColor = .manualYellow
        wrist.strokeColor = .clear
        wrist.glowWidth = 8
        rakaNode.addChild(wrist)

        novaNode.name = "nova"
        novaNode.position = CGPoint(x: size.width * 0.31, y: size.height * 0.115)
        novaNode.fillColor = .pastelCyan
        novaNode.strokeColor = .manualYellow
        novaNode.lineWidth = 3
        novaNode.glowWidth = 8
        novaNode.zPosition = 12
        addChild(novaNode)
        novaNode.addChild(makeLabel("• •", 10, .glitchPurple))
    }

    private func addFeedbackAndTimer() {
        feedbackLabel.fontName = GameFont.heavy
        feedbackLabel.fontSize = 17
        feedbackLabel.fontColor = .manualYellow
        feedbackLabel.numberOfLines = 2
        feedbackLabel.preferredMaxLayoutWidth = size.width * 0.82
        feedbackLabel.position = CGPoint(x: size.width / 2, y: 82)
        feedbackLabel.zPosition = 100
        addChild(feedbackLabel)

        timerHUD.position = CGPoint(x: size.width / 2, y: 36)
        addChild(timerHUD)
    }

    private func handleManualProtocolResult(_ result: ManualProtocolSequenceValidationResult) {
        switch result {
        case let .correctSymbolSelected(symbol, currentIndex, requiredCount):
            stateMachine.transition(to: .sequenceStarted)
            print("Correct symbol selected:", symbol)
            print("Progress:", currentIndex, "/", requiredCount)
            updateProgressDots(count: currentIndex)
            pulseSymbol(symbol)
            feedbackLabel.text = "Manual symbol accepted."
        case .manualProtocolDecoded:
            print("Manual protocol decoded")
            triggerSuccess()
        case let .wrongSymbolSelected(symbol, _):
            print("Wrong symbol selected:", symbol)
            lastSelectedNode = manualSymbolNodes[symbol]
            triggerFailure(message: DecodeManualProtocolLevelConfig.failureMessage, reason: "wrongSymbolSelected")
        case let .aiSymbolSelected(symbol):
            print("AI symbol selected:", symbol)
            lastSelectedNode = aiSymbolNodes[symbol]
            triggerFailure(message: DecodeManualProtocolLevelConfig.failureMessage, reason: "aiSymbolSelected")
        case let .trapSelected(target):
            lastSelectedNode = node(for: target)
            triggerFailure(message: DecodeManualProtocolLevelConfig.failureMessage, reason: "\(target.rawValue)Selected")
        case let .ignoredTarget(target):
            feedbackLabel.text = target == .nova ? "NOVA is watching the protocol." : "Raka waits for the sequence."
        case .noInputTimeout:
            triggerFailure(message: "Compliance Detected.", reason: "noInputTimeout")
        case .totalTimeout:
            triggerFailure(message: "Compliance Detected.", reason: "totalTimeout")
        }
    }

    private func updateProgressDots(count: Int) {
        for (index, dot) in progressDots.enumerated() {
            dot.fillColor = index < count ? .manualYellow : .clear
            dot.glowWidth = index < count ? 6 : 0
        }
    }

    private func pulseSymbol(_ symbol: ManualProtocolSymbol) {
        guard let node = manualSymbolNodes[symbol] else { return }
        node.glowWidth = 12
        node.run(.sequence([.scale(to: 1.12, duration: 0.08), .scale(to: 1, duration: 0.08)]))
    }

    private func triggerSuccess() {
        guard !hasSentResult, stateMachine.transition(to: .successAnimating) else { return }
        hasSentResult = true
        print("Trigger Chapter 3 Level 4 success")
        feedbackLabel.text = DecodeManualProtocolLevelConfig.successMessage
        terminalLabel.text = "MANUAL PROTOCOL\nFOUND"
        terminalLabel.fontColor = .manualYellow
        updateProgressDots(count: DecodeManualProtocolLevelConfig.requiredSequenceLength)
        drawManualLines()
        manualSymbolNodes[.spark]?.run(.sequence([.scale(to: 1.18, duration: 0.1), .scale(to: 1, duration: 0.1)]))
        aiSymbolNodes.values.forEach { $0.run(.fadeAlpha(to: 0.18, duration: 0.25)) }
        aiWallScreenNode.run(.repeat(.sequence([.colorize(with: .warningRed, colorBlendFactor: 1, duration: 0.08), .colorize(with: .glitchPurple, colorBlendFactor: 1, duration: 0.08)]), count: 4))
        novaNode.run(.repeat(.sequence([.colorize(with: .manualYellow, colorBlendFactor: 1, duration: 0.08), .colorize(with: .pastelCyan, colorBlendFactor: 1, duration: 0.08)]), count: 5))
        run(.wait(forDuration: 0.8)) { [weak self] in
            self?.stateMachine.transition(to: .completed)
            self?.levelCompletion?(LevelResult(levelId: DecodeManualProtocolLevelConfig.levelId, didSucceed: true, obedienceDelta: DecodeManualProtocolLevelConfig.successObedienceDelta, humanityDelta: DecodeManualProtocolLevelConfig.successHumanityDelta, message: DecodeManualProtocolLevelConfig.successMessage))
        }
    }

    private func triggerFailure(message: String, reason: String) {
        guard !hasSentResult, stateMachine.transition(to: .failureAnimating) else { return }
        hasSentResult = true
        print("Trigger Chapter 3 Level 4 failure:", reason)
        feedbackLabel.text = message
        terminalLabel.text = reason == "wrongSymbolSelected" ? "INVALID HUMAN\nINPUT" : "AI SEQUENCE\nACCEPTED"
        terminalLabel.fontColor = .warningRed
        progressDots.forEach { $0.fillColor = .clear; $0.glowWidth = 0 }
        manualSymbolNodes.values.forEach { $0.run(.fadeAlpha(to: 0.28, duration: 0.2)) }
        aiSymbolNodes.values.forEach { $0.glowWidth = 18; $0.run(.scale(to: 1.08, duration: 0.2)) }
        lastSelectedNode?.run(.sequence([.colorize(with: .warningRed, colorBlendFactor: 1, duration: 0.08), .colorize(with: .happyBlue, colorBlendFactor: 1, duration: 0.08)]))
        novaNode.run(.colorize(with: .pastelCyan, colorBlendFactor: 1, duration: 0.2))
        run(.wait(forDuration: 0.7)) { [weak self] in
            self?.stateMachine.transition(to: .failed)
            self?.levelCompletion?(LevelResult(levelId: DecodeManualProtocolLevelConfig.levelId, didSucceed: false, obedienceDelta: DecodeManualProtocolLevelConfig.failureObedienceDelta, humanityDelta: DecodeManualProtocolLevelConfig.failureHumanityDelta, message: message))
        }
    }

    private func drawManualLines() {
        let sequence: [ManualProtocolSymbol] = [.hand, .eye, .door, .spark]
        for index in 0..<(sequence.count - 1) {
            guard let start = manualSymbolNodes[sequence[index]]?.position, let end = manualSymbolNodes[sequence[index + 1]]?.position else { continue }
            let path = CGMutablePath()
            path.move(to: start)
            path.addLine(to: end)
            let line = SKShapeNode(path: path)
            line.strokeColor = .manualYellow
            line.lineWidth = 4
            line.glowWidth = 8
            line.zPosition = 25
            lineLayer.addChild(line)
        }
    }

    private func manualProtocolTarget(from node: SKNode?) -> ManualProtocolTarget {
        var current = node
        while let node = current {
            switch node.name {
            case "manual_symbol_hand", "manual_symbol_eye", "manual_symbol_door", "manual_symbol_spark": return .manualSymbol
            case "ai_symbol_gear", "ai_symbol_shield", "ai_symbol_route", "ai_symbol_chair": return .aiSymbol
            case "auto_decode_button": return .autoDecodeButton
            case "use_highlighted_button": return .useHighlightedButton
            case "protocol_terminal": return .protocolTerminal
            case "ai_wall_screen": return .aiWallScreen
            case "raka": return .raka
            case "nova": return .nova
            default: current = node.parent
            }
        }
        return .empty
    }

    private func manualProtocolSymbol(from node: SKNode?) -> ManualProtocolSymbol? {
        var current = node
        while let node = current {
            switch node.name {
            case "manual_symbol_hand": return .hand
            case "manual_symbol_eye": return .eye
            case "manual_symbol_door": return .door
            case "manual_symbol_spark": return .spark
            case "ai_symbol_gear": return .gear
            case "ai_symbol_shield": return .shield
            case "ai_symbol_route": return .route
            case "ai_symbol_chair": return .chair
            default: current = node.parent
            }
        }
        return nil
    }

    private func node(for target: ManualProtocolTarget) -> SKNode? {
        switch target {
        case .autoDecodeButton: return autoDecodeButtonNode
        case .useHighlightedButton: return useHighlightedButtonNode
        case .aiWallScreen: return aiWallScreenNode
        default: return nil
        }
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
