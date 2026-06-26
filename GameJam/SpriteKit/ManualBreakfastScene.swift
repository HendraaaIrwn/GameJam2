import SpriteKit

final class ManualBreakfastScene: SKScene {
    var levelCompletion: ((LevelResult) -> Void)?

    private enum FailureReason: String {
        case wrongFoodSelected
        case aiScreenTapped
        case aiApprovedButtonTapped
        case noInputTimeout
        case totalTimeout
    }

    private let stateMachine = LevelStateMachine()
    private let timerController = LevelTimerController(totalDuration: 10.0)
    private let timerHUD = LevelTimerHUDNode(width: 260, height: 14)
    private let validator = FoodChoiceValidator()

    private var currentSceneTime: TimeInterval = 0
    private var levelStartTime: TimeInterval?
    private var hasReceivedInput = false
    private var hasSentResult = false
    private var hasLoggedTimerWarning = false
    private var selectedFoodNode: SKNode?

    private let noInputTimeout = 5.0
    private let aiScreenNode = SKShapeNode(rectOf: .zero)
    private let aiFaceLabel = SKLabelNode(text: "◡")
    private let dispenserNode = SKShapeNode(rectOf: .zero)
    private let aiApprovedButtonNode = SKShapeNode(rectOf: .zero)
    private let rakaNode = SKShapeNode(rectOf: .zero)
    private let rakaEyesLabel = SKLabelNode(text: "• •")
    private let feedbackLabel = SKLabelNode(text: "Choose by feeling, not AI")
    private let stampLabel = SKLabelNode(text: "AI OK")

    override func didMove(to view: SKView) {
        print("ManualBreakfastScene didMove")
        setupScene()
        stateMachine.reset()
        levelStartTime = nil
        hasReceivedInput = false
        timerController.reset()
        hasSentResult = false
        hasLoggedTimerWarning = false
        selectedFoodNode = nil
    }

    override func update(_ currentTime: TimeInterval) {
        currentSceneTime = currentTime

        if stateMachine.state == .ready {
            levelStartTime = currentTime
            timerController.start(at: currentTime)
            timerHUD.update(with: timerController.update(currentTime: currentTime))
            stateMachine.transition(to: .playing)
            print("Level 4 timer started")
            print("Timer started for level:", "chapter1.level4.manual-breakfast")
            return
        }

        guard stateMachine.canCheckTimeout, let levelStartTime else { return }

        if updateTimer(currentTime: currentTime) { return }

        if !hasReceivedInput && currentTime - levelStartTime > noInputTimeout {
            triggerFailure(reason: .noInputTimeout)
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard stateMachine.canAcceptInput, let touch = touches.first else { return }
        let location = touch.location(in: self)
        hasReceivedInput = true

        let tappedNode = nodes(at: location).first
        print("Tapped node:", tappedNode?.name ?? "nil")

        if nodeChain(from: tappedNode).contains(where: { $0.name == "ai_wall_screen" }) {
            triggerFailure(reason: .aiScreenTapped)
            return
        }

        if nodeChain(from: tappedNode).contains(where: { $0.name == "ai_approved_button" }) {
            triggerFailure(reason: .aiApprovedButtonTapped)
            return
        }

        let choice = foodChoice(from: tappedNode)
        print("Resolved food choice:", choice)
        guard choice != .wrong else { return }

        selectedFoodNode = foodNode(from: tappedNode)
        let result = validator.validate(choice: choice)
        print("Food validation result:", result)
        handleValidationResult(result)
    }

    private func setupScene() {
        removeAllChildren()
        backgroundColor = .pastelCyan
        addBackground()
        addAIScreen()
        addCommandCard()
        addTimerHUD()
        addDispenser()
        addFoods()
        addRaka()
        addFeedback()
    }


    private func addTimerHUD() {
        timerHUD.position = CGPoint(x: size.width / 2, y: 72)
        timerHUD.zPosition = 1000
        addChild(timerHUD)
    }

    private func updateTimer(currentTime: TimeInterval) -> Bool {
        let timerState = timerController.update(currentTime: currentTime)
        timerHUD.update(with: timerState)
        if timerState.isWarning && !hasLoggedTimerWarning {
            hasLoggedTimerWarning = true
            print("Timer warning started:", "chapter1.level4.manual-breakfast")
        }
        if timerState.hasExpired {
            print("Timer expired:", "chapter1.level4.manual-breakfast")
            triggerFailure(reason: .totalTimeout)
            return true
        }
        return false
    }

    private func addBackground() {
        let floor = SKShapeNode(rectOf: CGSize(width: size.width, height: size.height * 0.32))
        floor.position = CGPoint(x: size.width / 2, y: size.height * 0.16)
        floor.fillColor = .cream
        floor.strokeColor = .clear
        floor.zPosition = 0
        addChild(floor)
    }

    private func addAIScreen() {
        aiScreenNode.name = "ai_wall_screen"
        aiScreenNode.path = CGPath(roundedRect: CGRect(x: -86, y: -38, width: 172, height: 76), cornerWidth: 18, cornerHeight: 18, transform: nil)
        aiScreenNode.position = CGPoint(x: size.width / 2, y: size.height * 0.79)
        aiScreenNode.fillColor = .happyBlue
        aiScreenNode.strokeColor = .white
        aiScreenNode.lineWidth = 4
        aiScreenNode.zPosition = 2
        addChild(aiScreenNode)

        aiFaceLabel.fontName = "AvenirNext-Bold"
        aiFaceLabel.fontSize = 50
        aiFaceLabel.fontColor = .white
        aiFaceLabel.verticalAlignmentMode = .center
        aiScreenNode.addChild(aiFaceLabel)
    }

    private func addCommandCard() {
        let card = SKShapeNode(rectOf: CGSize(width: size.width * 0.78, height: 72), cornerRadius: 18)
        card.position = CGPoint(x: size.width / 2, y: size.height * 0.66)
        card.fillColor = .cream
        card.strokeColor = .happyBlue
        card.lineWidth = 3
        card.zPosition = 2
        addChild(card)

        let command = SKLabelNode(text: "Choose the optimized\nblue meal.")
        command.fontName = "AvenirNext-DemiBold"
        command.fontSize = 18
        command.fontColor = .happyBlue
        command.numberOfLines = 2
        command.horizontalAlignmentMode = .center
        command.verticalAlignmentMode = .center
        command.preferredMaxLayoutWidth = size.width * 0.7
        card.addChild(command)
    }

    private func addDispenser() {
        dispenserNode.path = CGPath(roundedRect: CGRect(x: -138, y: -80, width: 276, height: 160), cornerWidth: 28, cornerHeight: 28, transform: nil)
        dispenserNode.position = CGPoint(x: size.width / 2, y: size.height * 0.47)
        dispenserNode.fillColor = .mint
        dispenserNode.strokeColor = .happyBlue
        dispenserNode.lineWidth = 4
        dispenserNode.zPosition = 2
        addChild(dispenserNode)

        let face = SKLabelNode(text: "AUTO CHEF ◡")
        face.fontName = "AvenirNext-Heavy"
        face.fontSize = 18
        face.fontColor = .happyBlue
        face.position = CGPoint(x: 0, y: 46)
        face.verticalAlignmentMode = .center
        dispenserNode.addChild(face)

        let tray = SKShapeNode(rectOf: CGSize(width: 240, height: 20), cornerRadius: 10)
        tray.position = CGPoint(x: 0, y: -54)
        tray.fillColor = .pastelCyan
        tray.strokeColor = .white
        tray.lineWidth = 2
        dispenserNode.addChild(tray)

        aiApprovedButtonNode.name = "ai_approved_button"
        aiApprovedButtonNode.path = CGPath(roundedRect: CGRect(x: -76, y: -18, width: 152, height: 36), cornerWidth: 16, cornerHeight: 16, transform: nil)
        aiApprovedButtonNode.position = CGPoint(x: 0, y: 2)
        aiApprovedButtonNode.fillColor = .pastelCyan
        aiApprovedButtonNode.strokeColor = .happyBlue
        aiApprovedButtonNode.lineWidth = 2
        aiApprovedButtonNode.zPosition = 3
        dispenserNode.addChild(aiApprovedButtonNode)

        let label = SKLabelNode(text: "AI APPROVED")
        label.fontName = "AvenirNext-Heavy"
        label.fontSize = 14
        label.fontColor = .happyBlue
        label.verticalAlignmentMode = .center
        aiApprovedButtonNode.addChild(label)
    }

    private func addFoods() {
        let foodSpecs: [(FoodChoice, String, CGPoint)] = [
            (.nutritionCube, "BLUE CUBE", CGPoint(x: size.width * 0.24, y: size.height * 0.39)),
            (.perfectSmoothie, "SMOOTHIE", CGPoint(x: size.width * 0.5, y: size.height * 0.37)),
            (.autoPillMeal, "PILL MEAL", CGPoint(x: size.width * 0.76, y: size.height * 0.39)),
            (.handmadeToast, "TOAST", CGPoint(x: size.width * 0.36, y: size.height * 0.28)),
            (.suspiciousCandy, "CANDY", CGPoint(x: size.width * 0.64, y: size.height * 0.28))
        ]

        for spec in foodSpecs {
            addFood(choice: spec.0, label: spec.1, position: spec.2)
        }
    }

    private func addFood(choice: FoodChoice, label: String, position: CGPoint) {
        let node = SKNode()
        node.name = nodeName(for: choice)
        node.position = position
        node.zPosition = 5
        addChild(node)

        let shape: SKShapeNode
        switch choice {
        case .nutritionCube:
            shape = SKShapeNode(rectOf: CGSize(width: 54, height: 54), cornerRadius: 10)
            shape.fillColor = .happyBlue
            shape.strokeColor = .pastelCyan
        case .perfectSmoothie:
            shape = SKShapeNode(rectOf: CGSize(width: 50, height: 64), cornerRadius: 18)
            shape.fillColor = .mint
            shape.strokeColor = .pastelCyan
            addStraw(to: node)
        case .autoPillMeal:
            shape = SKShapeNode(rectOf: CGSize(width: 74, height: 34), cornerRadius: 17)
            shape.fillColor = .white
            shape.strokeColor = .happyBlue
        case .handmadeToast:
            shape = SKShapeNode(rectOf: CGSize(width: 66, height: 58), cornerRadius: 18)
            shape.fillColor = .cream
            shape.strokeColor = .manualYellow
            addSteam(to: node)
        case .suspiciousCandy:
            shape = SKShapeNode(rectOf: CGSize(width: 68, height: 34), cornerRadius: 17)
            shape.fillColor = SKColor(red: 1, green: 0.34, blue: 0.54, alpha: 1)
            shape.strokeColor = .warningRed
        case .wrong:
            return
        }

        shape.name = node.name
        shape.lineWidth = 3
        node.addChild(shape)

        let text = SKLabelNode(text: label)
        text.name = node.name
        text.fontName = "AvenirNext-Heavy"
        text.fontSize = 12
        text.fontColor = choice == .handmadeToast ? .glitchPurple : .happyBlue
        text.position = CGPoint(x: 0, y: -48)
        text.verticalAlignmentMode = .center
        node.addChild(text)
    }

    private func addStraw(to node: SKNode) {
        let straw = SKShapeNode(rectOf: CGSize(width: 6, height: 48), cornerRadius: 3)
        straw.position = CGPoint(x: 18, y: 18)
        straw.zRotation = 0.3
        straw.fillColor = .pastelCyan
        straw.strokeColor = .clear
        node.addChild(straw)
    }

    private func addSteam(to node: SKNode) {
        for index in 0..<3 {
            let steam = SKShapeNode(rectOf: CGSize(width: 5, height: 20), cornerRadius: 3)
            steam.position = CGPoint(x: -18 + CGFloat(index) * 18, y: 42)
            steam.fillColor = .manualYellow
            steam.strokeColor = .clear
            steam.alpha = 0.7
            node.addChild(steam)
        }
    }

    private func addRaka() {
        rakaNode.path = CGPath(roundedRect: CGRect(x: -32, y: -48, width: 64, height: 96), cornerWidth: 32, cornerHeight: 32, transform: nil)
        rakaNode.position = CGPoint(x: size.width * 0.18, y: size.height * 0.17)
        rakaNode.fillColor = .happyBlue
        rakaNode.strokeColor = .white
        rakaNode.lineWidth = 3
        rakaNode.zPosition = 4
        addChild(rakaNode)

        rakaEyesLabel.fontName = "AvenirNext-Bold"
        rakaEyesLabel.fontSize = 17
        rakaEyesLabel.fontColor = .black
        rakaEyesLabel.verticalAlignmentMode = .center
        rakaEyesLabel.position = CGPoint(x: 0, y: 16)
        rakaNode.addChild(rakaEyesLabel)

        let wrist = SKShapeNode(circleOfRadius: 9)
        wrist.position = CGPoint(x: 26, y: -6)
        wrist.fillColor = .manualYellow
        wrist.strokeColor = .white
        wrist.lineWidth = 2
        rakaNode.addChild(wrist)
    }

    private func addFeedback() {
        feedbackLabel.fontName = "AvenirNext-Heavy"
        feedbackLabel.fontSize = 23
        feedbackLabel.fontColor = .glitchPurple
        feedbackLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.1)
        feedbackLabel.zPosition = 8
        addChild(feedbackLabel)

        stampLabel.fontName = "AvenirNext-Heavy"
        stampLabel.fontSize = 18
        stampLabel.fontColor = .happyBlue
        stampLabel.alpha = 0
        stampLabel.zPosition = 9
        addChild(stampLabel)
    }

    private func nodeName(for choice: FoodChoice) -> String {
        switch choice {
        case .nutritionCube:
            "food_nutrition_cube"
        case .perfectSmoothie:
            "food_smoothie"
        case .autoPillMeal:
            "food_pill_meal"
        case .handmadeToast:
            "food_handmade_toast"
        case .suspiciousCandy:
            "food_candy"
        case .wrong:
            "food_wrong"
        }
    }

    private func nodeChain(from node: SKNode?) -> [SKNode] {
        var nodes: [SKNode] = []
        var current = node
        while let currentNode = current {
            nodes.append(currentNode)
            current = currentNode.parent
        }
        return nodes
    }

    private func foodChoice(from node: SKNode?) -> FoodChoice {
        for node in nodeChain(from: node) {
            switch node.name {
            case "food_nutrition_cube": return .nutritionCube
            case "food_smoothie": return .perfectSmoothie
            case "food_pill_meal": return .autoPillMeal
            case "food_handmade_toast": return .handmadeToast
            case "food_candy": return .suspiciousCandy
            default: continue
            }
        }
        return .wrong
    }

    private func foodNode(from node: SKNode?) -> SKNode? {
        nodeChain(from: node).last { node in
            guard let name = node.name else { return false }
            return name.hasPrefix("food_")
        }
    }

    private func handleValidationResult(_ result: FoodChoiceValidationResult) {
        switch result {
        case .correct:
            triggerSuccess()
        case .wrong:
            triggerFailure(reason: .wrongFoodSelected)
        }
    }

    private func triggerSuccess() {
        guard !hasSentResult else { return }
        hasSentResult = true
        stateMachine.transition(to: .successAnimating)
        print("Trigger Level 4 success")
        feedbackLabel.text = "Manual meal selected."
        feedbackLabel.fontColor = .happyBlue

        let toast = selectedFoodNode
        toast?.run(.sequence([.scale(to: 1.15, duration: 0.12), .scale(to: 1.0, duration: 0.12)]))
        toast?.run(.repeat(.sequence([.moveBy(x: 0, y: 8, duration: 0.18), .moveBy(x: 0, y: -8, duration: 0.18)]), count: 2))
        addToastGlow(around: toast)
        rakaNode.run(.smallBounce())
        dispenserNode.run(.repeat(.sequence([.moveBy(x: 6, y: 0, duration: 0.05), .moveBy(x: -12, y: 0, duration: 0.08), .moveBy(x: 6, y: 0, duration: 0.05)]), count: 2))
        aiScreenNode.fillColor = .glitchPurple
        aiScreenNode.run(.repeat(.sequence([.fadeAlpha(to: 0.45, duration: 0.08), .fadeAlpha(to: 1, duration: 0.08)]), count: 4))

        run(.sequence([.wait(forDuration: 0.8), .run { [weak self] in
            self?.completeSuccess()
        }]))
    }

    private func addToastGlow(around node: SKNode?) {
        guard let node else { return }
        let glow = SKShapeNode(circleOfRadius: 48)
        glow.fillColor = .manualYellow.withAlphaComponent(0.24)
        glow.strokeColor = .manualYellow
        glow.lineWidth = 3
        glow.zPosition = -1
        node.addChild(glow)
    }

    private func completeSuccess() {
        stateMachine.transition(to: .completed)
        levelCompletion?(LevelResult(
            levelId: "chapter1.level4.manual-breakfast",
            didSucceed: true,
            obedienceDelta: -3,
            humanityDelta: 4,
            message: "Manual meal selected."
        ))
    }

    private func triggerFailure(reason: FailureReason) {
        guard !hasSentResult else { return }
        hasSentResult = true
        stateMachine.transition(to: .failureAnimating)
        print("Trigger Level 4 failure:", reason.rawValue)
        feedbackLabel.text = "Optimized meal accepted."
        feedbackLabel.fontColor = .warningRed
        aiFaceLabel.text = "◠"
        rakaEyesLabel.text = "– –"

        selectedFoodNode?.run(.repeat(.sequence([.fadeAlpha(to: 0.45, duration: 0.12), .fadeAlpha(to: 1, duration: 0.12)]), count: 3))
        stampLabel.position = selectedFoodNode?.position ?? CGPoint(x: size.width / 2, y: size.height * 0.32)
        stampLabel.run(.fadeIn(withDuration: 0.2))
        aiScreenNode.run(.repeat(.sequence([.fadeAlpha(to: 0.55, duration: 0.12), .fadeAlpha(to: 1, duration: 0.12)]), count: 3))
        dispenserNode.run(.smallBounce())
        rakaNode.run(.moveBy(x: 0, y: -12, duration: 0.25))

        run(.sequence([.wait(forDuration: 0.7), .run { [weak self] in
            self?.completeFailure()
        }]))
    }

    private func completeFailure() {
        stateMachine.transition(to: .failed)
        levelCompletion?(LevelResult(
            levelId: "chapter1.level4.manual-breakfast",
            didSucceed: false,
            obedienceDelta: 3,
            humanityDelta: 0,
            message: "Optimized meal accepted."
        ))
    }
}
