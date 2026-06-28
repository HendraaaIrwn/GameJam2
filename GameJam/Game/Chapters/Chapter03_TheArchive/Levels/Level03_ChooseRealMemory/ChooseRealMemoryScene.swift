import SpriteKit

final class ChooseRealMemoryScene: SKScene {
    var levelCompletion: ((LevelResult) -> Void)?

    private let stateMachine = LevelStateMachine()
    private let validator = MemoryChoiceValidator()
    private let timer = LevelTimerController(totalDuration: ChooseRealMemoryLevelConfig.totalTimeLimit)
    private let timerHUD = LevelTimerHUDNode(width: 300, height: 14)

    private let aiWallScreenNode = SKShapeNode(rectOf: CGSize(width: 160, height: 76), cornerRadius: 22)
    private let aiFaceLabel = SKLabelNode(text: "◡")
    private let correctedMemoryNode = SKShapeNode(rectOf: CGSize(width: 112, height: 180), cornerRadius: 18)
    private let optimizedMemoryNode = SKShapeNode(rectOf: CGSize(width: 112, height: 180), cornerRadius: 18)
    private let rawMemoryNode = SKShapeNode(rectOf: CGSize(width: 112, height: 180), cornerRadius: 18)
    private let aiApprovedOverlayNode = SKShapeNode(rectOf: CGSize(width: 238, height: 200), cornerRadius: 22)
    private let selectCorrectedButtonNode = SKShapeNode(rectOf: CGSize(width: 176, height: 44), cornerRadius: 18)
    private let feedbackLabel = SKLabelNode(text: "")
    private let memoryCorrectedLabel = SKLabelNode(text: "MEMORY CORRECTED")
    private let novaNode = SKShapeNode(circleOfRadius: 18)
    private let rakaNode = SKShapeNode(rectOf: CGSize(width: 52, height: 74), cornerRadius: 25)

    private var currentSceneTime: TimeInterval = 0
    private var hasSentResult = false
    private var selectedWrongNode: SKNode?

    override func didMove(to view: SKView) {
        setupScene()
        print("ChooseRealMemoryScene didMove")
    }

    override func update(_ currentTime: TimeInterval) {
        currentSceneTime = currentTime
        if !timer.hasStarted {
            validator.startLevel(at: currentTime)
            timer.start(at: currentTime)
            stateMachine.transition(to: .playing)
            print("Chapter 3 Level 3 timer started")
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
            handleMemoryChoiceResult(result)
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard stateMachine.canAcceptInput, let location = touches.first?.location(in: self) else { return }
        let tappedNode = nodes(at: location).first
        print("Tapped node:", tappedNode?.name ?? "nil")
        let target = memoryChoiceTarget(at: location)
        print("Resolved memory target:", target)
        guard let result = validator.validateTap(target: target, time: currentSceneTime) else { return }
        print("Memory choice validation result:", result)
        handleMemoryChoiceResult(result)
    }

    private func setupScene() {
        removeAllChildren()
        removeAllActions()
        backgroundColor = SKColor(red: 0.05, green: 0.07, blue: 0.17, alpha: 1)
        stateMachine.reset()
        validator.reset()
        timer.reset()
        hasSentResult = false
        selectedWrongNode = nil

        addArchiveBackground()
        addAIHeader()
        addMemoryCards()
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

        for index in 0..<4 {
            let shelf = SKShapeNode(rectOf: CGSize(width: size.width * 0.86, height: 16), cornerRadius: 8)
            shelf.position = CGPoint(x: size.width / 2, y: size.height * CGFloat(0.28 + Double(index) * 0.1))
            shelf.fillColor = .cream.withAlphaComponent(0.12)
            shelf.strokeColor = .clear
            shelf.zPosition = 1
            addChild(shelf)
        }
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
        commandCard.addChild(makeLabel(ChooseRealMemoryLevelConfig.command, 17, .happyBlue))
    }

    private func addMemoryCards() {
        addMemoryCard(correctedMemoryNode, name: "corrected_memory", title: "CORRECTED\nMEMORY", subtitle: "AI ✓", position: CGPoint(x: size.width * 0.18, y: size.height * 0.52), fill: .pastelCyan, warm: false)
        addMemoryCard(optimizedMemoryNode, name: "optimized_memory", title: "OPTIMIZED\nMEMORY", subtitle: "COMFORT 100", position: CGPoint(x: size.width * 0.5, y: size.height * 0.52), fill: .happyBlue.withAlphaComponent(0.82), warm: false)
        addMemoryCard(rawMemoryNode, name: "raw_memory", title: "RAW\nMEMORY", subtitle: "MESSY + TRUE", position: CGPoint(x: size.width * 0.82, y: size.height * 0.52), fill: .cream, warm: true)

        aiApprovedOverlayNode.name = "ai_approved_overlay"
        aiApprovedOverlayNode.position = CGPoint(x: size.width * 0.34, y: size.height * 0.52)
        aiApprovedOverlayNode.fillColor = .happyBlue.withAlphaComponent(0.04)
        aiApprovedOverlayNode.strokeColor = .happyBlue.withAlphaComponent(0.4)
        aiApprovedOverlayNode.lineWidth = 2
        aiApprovedOverlayNode.zPosition = 11
        addChild(aiApprovedOverlayNode)
        let overlayLabel = makeLabel("AI APPROVED", 13, .happyBlue)
        overlayLabel.position = CGPoint(x: 0, y: 82)
        aiApprovedOverlayNode.addChild(overlayLabel)

        selectCorrectedButtonNode.name = "select_corrected_button"
        selectCorrectedButtonNode.position = CGPoint(x: size.width / 2, y: size.height * 0.27)
        selectCorrectedButtonNode.fillColor = .happyBlue
        selectCorrectedButtonNode.strokeColor = .white
        selectCorrectedButtonNode.lineWidth = 3
        selectCorrectedButtonNode.zPosition = 12
        addChild(selectCorrectedButtonNode)
        selectCorrectedButtonNode.addChild(makeLabel("SELECT CORRECTED", 13, .white))

        memoryCorrectedLabel.fontName = GameFont.heavy
        memoryCorrectedLabel.fontSize = 22
        memoryCorrectedLabel.fontColor = .white
        memoryCorrectedLabel.alpha = 0
        memoryCorrectedLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.43)
        memoryCorrectedLabel.zPosition = 50
        addChild(memoryCorrectedLabel)
    }

    private func addMemoryCard(_ card: SKShapeNode, name: String, title: String, subtitle: String, position: CGPoint, fill: SKColor, warm: Bool) {
        card.name = name
        card.position = position
        card.fillColor = fill
        card.strokeColor = warm ? .manualYellow : .white
        card.lineWidth = 3
        card.zPosition = 8
        addChild(card)

        let label = makeLabel(title, 13, warm ? .glitchPurple : .happyBlue)
        label.position = CGPoint(x: 0, y: 66)
        card.addChild(label)
        let sub = makeLabel(subtitle, 10, warm ? .warningRed : .white)
        sub.position = CGPoint(x: 0, y: -66)
        card.addChild(sub)

        for index in 0..<3 {
            let citizen = SKShapeNode(circleOfRadius: 8)
            citizen.position = CGPoint(x: CGFloat(-28 + index * 28), y: CGFloat(18 - index * 8))
            citizen.fillColor = warm ? [.mint, .manualYellow, .warningRed][index] : .pastelCyan
            citizen.strokeColor = warm ? .glitchPurple : .happyBlue
            citizen.lineWidth = 2
            card.addChild(citizen)
        }

        if warm {
            card.addChild(makeLabel("!?  ha", 12, .glitchPurple))
            addSpark(to: card, at: CGPoint(x: 34, y: 24))
            addSpark(to: card, at: CGPoint(x: -36, y: -10))
        } else {
            for offset in [-20, 8, 34] as [CGFloat] {
                let route = SKShapeNode(rectOf: CGSize(width: 78, height: 4), cornerRadius: 2)
                route.position = CGPoint(x: 0, y: offset)
                route.fillColor = .happyBlue
                route.strokeColor = .clear
                route.glowWidth = 4
                card.addChild(route)
            }
        }
    }

    private func addSpark(to node: SKNode, at position: CGPoint) {
        let spark = SKShapeNode(circleOfRadius: 4)
        spark.position = position
        spark.fillColor = .manualYellow
        spark.strokeColor = .clear
        spark.glowWidth = 8
        node.addChild(spark)
    }

    private func addCharacters() {
        rakaNode.name = "raka"
        rakaNode.position = CGPoint(x: size.width * 0.22, y: size.height * 0.19)
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
        novaNode.position = CGPoint(x: size.width * 0.35, y: size.height * 0.22)
        novaNode.fillColor = .pastelCyan
        novaNode.strokeColor = .manualYellow
        novaNode.lineWidth = 3
        novaNode.glowWidth = 8
        novaNode.zPosition = 12
        addChild(novaNode)
        novaNode.addChild(makeLabel("• •", 10, .glitchPurple))
        novaNode.run(.repeatForever(.sequence([.moveBy(x: 0, y: 7, duration: 0.65), .moveBy(x: 0, y: -7, duration: 0.65)])))
    }

    private func addFeedbackAndTimer() {
        feedbackLabel.fontName = GameFont.heavy
        feedbackLabel.fontSize = 17
        feedbackLabel.fontColor = .manualYellow
        feedbackLabel.numberOfLines = 2
        feedbackLabel.preferredMaxLayoutWidth = size.width * 0.82
        feedbackLabel.position = CGPoint(x: size.width / 2, y: 103)
        feedbackLabel.zPosition = 100
        addChild(feedbackLabel)

        timerHUD.position = CGPoint(x: size.width / 2, y: 46)
        addChild(timerHUD)
    }

    private func handleMemoryChoiceResult(_ result: MemoryChoiceValidationResult) {
        switch result {
        case .correctMemorySelected:
            print("Correct memory selected: rawMemory")
            triggerSuccess()
        case let .wrongMemorySelected(target):
            print("Wrong memory selected:", target)
            selectedWrongNode = node(for: target)
            triggerFailure(message: ChooseRealMemoryLevelConfig.failureMessage, reason: "\(target.rawValue)Selected")
        case let .ignoredTarget(target):
            feedbackLabel.text = target == .nova ? "NOVA is still reading the files." : "Raka waits for your choice."
        case .noInputTimeout:
            triggerFailure(message: "Compliance Detected.", reason: "noInputTimeout")
        case .totalTimeout:
            triggerFailure(message: "Compliance Detected.", reason: "totalTimeout")
        }
    }

    private func triggerSuccess() {
        guard !hasSentResult, stateMachine.transition(to: .successAnimating) else { return }
        hasSentResult = true
        print("Trigger Chapter 3 Level 3 success")
        feedbackLabel.text = ChooseRealMemoryLevelConfig.successMessage
        rawMemoryNode.run(.scale(to: 1.08, duration: 0.2))
        rawMemoryNode.glowWidth = 16
        correctedMemoryNode.run(.sequence([.colorize(with: .warningRed, colorBlendFactor: 1, duration: 0.08), .colorize(with: .glitchPurple, colorBlendFactor: 1, duration: 0.08), .fadeAlpha(to: 0.22, duration: 0.25)]))
        optimizedMemoryNode.run(.sequence([.colorize(with: .warningRed, colorBlendFactor: 1, duration: 0.08), .colorize(with: .glitchPurple, colorBlendFactor: 1, duration: 0.08), .fadeAlpha(to: 0.22, duration: 0.25)]))
        aiWallScreenNode.run(.repeat(.sequence([.colorize(with: .warningRed, colorBlendFactor: 1, duration: 0.08), .colorize(with: .glitchPurple, colorBlendFactor: 1, duration: 0.08)]), count: 4))
        novaNode.run(.repeat(.sequence([.colorize(with: .manualYellow, colorBlendFactor: 1, duration: 0.08), .colorize(with: .pastelCyan, colorBlendFactor: 1, duration: 0.08)]), count: 5))
        rakaNode.run(.sequence([.moveBy(x: 0, y: 10, duration: 0.14), .moveBy(x: 0, y: -10, duration: 0.14)]))
        run(.wait(forDuration: 0.8)) { [weak self] in
            self?.stateMachine.transition(to: .completed)
            self?.levelCompletion?(LevelResult(levelId: ChooseRealMemoryLevelConfig.levelId, didSucceed: true, obedienceDelta: ChooseRealMemoryLevelConfig.successObedienceDelta, humanityDelta: ChooseRealMemoryLevelConfig.successHumanityDelta, message: ChooseRealMemoryLevelConfig.successMessage))
        }
    }

    private func triggerFailure(message: String, reason: String) {
        guard !hasSentResult, stateMachine.transition(to: .failureAnimating) else { return }
        hasSentResult = true
        print("Trigger Chapter 3 Level 3 failure:", reason)
        feedbackLabel.text = message
        aiFaceLabel.text = "MEMORY\nCORRECTED"
        aiFaceLabel.fontSize = 13
        selectedWrongNode?.run(.scale(to: 1.12, duration: 0.2))
        rawMemoryNode.fillColor = .happyBlue.withAlphaComponent(0.8)
        rawMemoryNode.strokeColor = .white
        rawMemoryNode.removeAllChildren()
        rawMemoryNode.addChild(makeLabel("CORRECTED", 15, .white))
        memoryCorrectedLabel.run(.fadeIn(withDuration: 0.22))
        novaNode.run(.colorize(with: .pastelCyan, colorBlendFactor: 1, duration: 0.2))
        run(.wait(forDuration: 0.7)) { [weak self] in
            self?.stateMachine.transition(to: .failed)
            self?.levelCompletion?(LevelResult(levelId: ChooseRealMemoryLevelConfig.levelId, didSucceed: false, obedienceDelta: ChooseRealMemoryLevelConfig.failureObedienceDelta, humanityDelta: ChooseRealMemoryLevelConfig.failureHumanityDelta, message: message))
        }
    }

    private func memoryChoiceTarget(at point: CGPoint) -> MemoryChoiceTarget {
        for node in nodes(at: point) {
            let target = memoryChoiceTarget(from: node)
            if target != .empty { return target }
        }
        return .empty
    }

    private func memoryChoiceTarget(from node: SKNode?) -> MemoryChoiceTarget {
        var current = node
        while let node = current {
            switch node.name {
            case "corrected_memory": return .correctedMemory
            case "optimized_memory": return .optimizedMemory
            case "raw_memory": return .rawMemory
            case "ai_approved_overlay": return .aiApprovedOverlay
            case "select_corrected_button": return .selectCorrectedButton
            case "ai_wall_screen": return .aiWallScreen
            case "raka": return .raka
            case "nova": return .nova
            default: current = node.parent
            }
        }
        return .empty
    }

    private func node(for target: MemoryChoiceTarget) -> SKNode? {
        switch target {
        case .correctedMemory: return correctedMemoryNode
        case .optimizedMemory: return optimizedMemoryNode
        case .aiApprovedOverlay: return aiApprovedOverlayNode
        case .selectCorrectedButton: return selectCorrectedButtonNode
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
