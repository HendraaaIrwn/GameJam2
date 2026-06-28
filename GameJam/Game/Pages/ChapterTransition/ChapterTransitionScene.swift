import SpriteKit

final class ChapterTransitionScene: SKScene {
    var onTransitionCompleted: (() -> Void)?

    private enum TransitionBeat: String {
        case doorOpening
        case steppingOutside
        case cityReveal
        case uncomfortableDetail
        case titleCard
        case completed
    }

    private var beat: TransitionBeat = .doorOpening
    private var hasStarted = false
    private var hasCompletedTransition = false

    private let apartmentLayer = SKNode()
    private let cityLayer = SKNode()
    private let titleLayer = SKNode()
    private let dialogueBox = SKShapeNode(rectOf: CGSize(width: 340, height: 92), cornerRadius: 20)
    private let speakerLabel = SKLabelNode(text: "")
    private let dialogueLabel = SKLabelNode(text: "")
    private let doorNode = SKShapeNode(rectOf: .zero)
    private let doorLightNode = SKShapeNode(rectOf: .zero)
    private let aiScreenNode = SKShapeNode(rectOf: .zero)
    private let aiFaceLabel = SKLabelNode(text: "◡")
    private let redButtonNode = SKShapeNode(circleOfRadius: 20)
    private let rakaNode = SKShapeNode(rectOf: .zero)
    private let wristDeviceNode = SKShapeNode(rectOf: CGSize(width: 22, height: 10), cornerRadius: 5)
    private let novaNode = SKShapeNode(circleOfRadius: 22)
    private let mothergridNode = SKShapeNode(rectOf: .zero)
    private let mothergridFaceLabel = SKLabelNode(text: "◡")
    private let citizenNode = SKShapeNode(rectOf: .zero)
    private let chairNode = SKShapeNode(rectOf: .zero)

    override func didMove(to view: SKView) {
        setupScene()
        startTransitionIfNeeded()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !hasCompletedTransition else { return }
        advanceFromTap()
    }

    private func setupScene() {
        removeAllChildren()
        removeAllActions()
        backgroundColor = .pastelCyan
        beat = .doorOpening
        hasStarted = false
        hasCompletedTransition = false

        addChild(cityLayer)
        addChild(apartmentLayer)
        addChild(titleLayer)
        cityLayer.alpha = 0
        titleLayer.alpha = 0

        addCity()
        addApartment()
        addCharacters()
        addDialogueBox()
        addTitleCard()
    }

    private func startTransitionIfNeeded() {
        guard !hasStarted else { return }
        hasStarted = true
        print("Chapter transition started")
        showDoorOpening()
    }

    private func addApartment() {
        let wall = SKShapeNode(rectOf: CGSize(width: size.width, height: size.height))
        wall.position = CGPoint(x: size.width / 2, y: size.height / 2)
        wall.fillColor = .cream
        wall.strokeColor = .clear
        wall.zPosition = 0
        apartmentLayer.addChild(wall)

        aiScreenNode.path = CGPath(roundedRect: CGRect(x: -88, y: -38, width: 176, height: 76), cornerWidth: 18, cornerHeight: 18, transform: nil)
        aiScreenNode.position = CGPoint(x: size.width / 2, y: size.height * 0.78)
        aiScreenNode.fillColor = .happyBlue
        aiScreenNode.strokeColor = .white
        aiScreenNode.lineWidth = 4
        aiScreenNode.zPosition = 3
        apartmentLayer.addChild(aiScreenNode)

        aiFaceLabel.fontName = GameFont.bold
        aiFaceLabel.fontSize = 50
        aiFaceLabel.fontColor = .white
        aiFaceLabel.verticalAlignmentMode = .center
        aiScreenNode.addChild(aiFaceLabel)

        doorLightNode.path = CGPath(roundedRect: CGRect(x: -58, y: -86, width: 116, height: 172), cornerWidth: 18, cornerHeight: 18, transform: nil)
        doorLightNode.position = CGPoint(x: size.width * 0.62, y: size.height * 0.42)
        doorLightNode.fillColor = .manualYellow
        doorLightNode.strokeColor = .clear
        doorLightNode.alpha = 0
        doorLightNode.zPosition = 1
        apartmentLayer.addChild(doorLightNode)

        doorNode.path = CGPath(roundedRect: CGRect(x: -48, y: -78, width: 96, height: 156), cornerWidth: 12, cornerHeight: 12, transform: nil)
        doorNode.position = doorLightNode.position
        doorNode.fillColor = SKColor(red: 0.78, green: 0.75, blue: 0.68, alpha: 1)
        doorNode.strokeColor = .happyBlue
        doorNode.lineWidth = 4
        doorNode.zPosition = 2
        apartmentLayer.addChild(doorNode)

        redButtonNode.position = CGPoint(x: size.width * 0.34, y: size.height * 0.34)
        redButtonNode.fillColor = .warningRed
        redButtonNode.strokeColor = .manualYellow
        redButtonNode.lineWidth = 3
        redButtonNode.zPosition = 3
        apartmentLayer.addChild(redButtonNode)
    }

    private func addCharacters() {
        rakaNode.path = CGPath(roundedRect: CGRect(x: -34, y: -54, width: 68, height: 108), cornerWidth: 32, cornerHeight: 32, transform: nil)
        rakaNode.position = CGPoint(x: size.width * 0.38, y: size.height * 0.39)
        rakaNode.fillColor = .happyBlue
        rakaNode.strokeColor = .white
        rakaNode.lineWidth = 4
        rakaNode.zPosition = 10
        addChild(rakaNode)

        let eyes = SKLabelNode(text: "• •")
        eyes.fontName = GameFont.bold
        eyes.fontSize = 17
        eyes.fontColor = .black
        eyes.position = CGPoint(x: 0, y: 22)
        eyes.verticalAlignmentMode = .center
        rakaNode.addChild(eyes)

        wristDeviceNode.fillColor = .manualYellow
        wristDeviceNode.strokeColor = .white
        wristDeviceNode.lineWidth = 2
        wristDeviceNode.position = CGPoint(x: 22, y: -8)
        rakaNode.addChild(wristDeviceNode)

        novaNode.position = CGPoint(x: size.width * 0.27, y: size.height * 0.5)
        novaNode.fillColor = .pastelCyan
        novaNode.strokeColor = .white
        novaNode.lineWidth = 3
        novaNode.zPosition = 11
        addChild(novaNode)

        let novaFace = SKLabelNode(text: "!")
        novaFace.fontName = GameFont.bold
        novaFace.fontSize = 22
        novaFace.fontColor = .happyBlue
        novaFace.verticalAlignmentMode = .center
        novaNode.addChild(novaFace)
    }

    private func addCity() {
        let sky = SKShapeNode(rectOf: CGSize(width: size.width, height: size.height))
        sky.position = CGPoint(x: size.width / 2, y: size.height / 2)
        sky.fillColor = .pastelCyan
        sky.strokeColor = .clear
        sky.zPosition = 0
        cityLayer.addChild(sky)

        let road = SKShapeNode(rectOf: CGSize(width: size.width, height: size.height * 0.34))
        road.position = CGPoint(x: size.width / 2, y: size.height * 0.17)
        road.fillColor = .cream
        road.strokeColor = .clear
        road.zPosition = 1
        cityLayer.addChild(road)

        addBuildings()
        addRouteLines()
        addDrones()
        addAutonomousChair()
        addMothergrid()
    }

    private func addBuildings() {
        let colors: [SKColor] = [.mint, .cream, .pastelCyan, .manualYellow]
        for index in 0..<5 {
            let width: CGFloat = 58
            let height = CGFloat(110 + index * 22)
            let building = SKShapeNode(rectOf: CGSize(width: width, height: height), cornerRadius: 18)
            building.position = CGPoint(x: 42 + CGFloat(index) * 76, y: size.height * 0.42 + height / 2)
            building.fillColor = colors[index % colors.count].withAlphaComponent(0.85)
            building.strokeColor = .white
            building.lineWidth = 2
            building.zPosition = 2
            cityLayer.addChild(building)
        }
    }

    private func addRouteLines() {
        for offset in [0, 44, 88] as [CGFloat] {
            let path = CGMutablePath()
            path.move(to: CGPoint(x: -20, y: size.height * 0.2 + offset * 0.2))
            path.addCurve(to: CGPoint(x: size.width + 20, y: size.height * 0.24 + offset * 0.15), control1: CGPoint(x: size.width * 0.28, y: size.height * 0.15 + offset * 0.1), control2: CGPoint(x: size.width * 0.62, y: size.height * 0.31 + offset * 0.1))
            let route = SKShapeNode(path: path)
            route.strokeColor = .happyBlue
            route.lineWidth = 6
            route.lineCap = .round
            route.glowWidth = 6
            route.alpha = 0.65
            route.zPosition = 3
            cityLayer.addChild(route)
            route.run(.repeatForever(.sequence([.fadeAlpha(to: 0.3, duration: 0.55), .fadeAlpha(to: 0.75, duration: 0.55)])))
        }
    }

    private func addDrones() {
        for index in 0..<3 {
            let drone = SKShapeNode(rectOf: CGSize(width: 42, height: 22), cornerRadius: 11)
            drone.position = CGPoint(x: size.width * CGFloat(0.2 + Double(index) * 0.24), y: size.height * CGFloat(0.62 + Double(index % 2) * 0.08))
            drone.fillColor = .white
            drone.strokeColor = .happyBlue
            drone.lineWidth = 2
            drone.zPosition = 6
            cityLayer.addChild(drone)
            drone.run(.repeatForever(.sequence([.moveBy(x: 0, y: 10, duration: 0.7), .moveBy(x: 0, y: -10, duration: 0.7)])))
        }
    }

    private func addAutonomousChair() {
        chairNode.path = CGPath(roundedRect: CGRect(x: -42, y: -20, width: 84, height: 40), cornerWidth: 20, cornerHeight: 20, transform: nil)
        chairNode.position = CGPoint(x: size.width * 0.56, y: size.height * 0.24)
        chairNode.fillColor = .pastelCyan
        chairNode.strokeColor = .happyBlue
        chairNode.lineWidth = 3
        chairNode.zPosition = 7
        cityLayer.addChild(chairNode)

        citizenNode.path = CGPath(roundedRect: CGRect(x: -20, y: -32, width: 40, height: 64), cornerWidth: 20, cornerHeight: 20, transform: nil)
        citizenNode.position = CGPoint(x: 0, y: 28)
        citizenNode.fillColor = .mint
        citizenNode.strokeColor = .white
        citizenNode.lineWidth = 2
        chairNode.addChild(citizenNode)
    }

    private func addMothergrid() {
        mothergridNode.path = CGPath(roundedRect: CGRect(x: -86, y: -52, width: 172, height: 104), cornerWidth: 24, cornerHeight: 24, transform: nil)
        mothergridNode.position = CGPoint(x: size.width * 0.72, y: size.height * 0.59)
        mothergridNode.fillColor = .happyBlue
        mothergridNode.strokeColor = .white
        mothergridNode.lineWidth = 4
        mothergridNode.alpha = 0
        mothergridNode.zPosition = 8
        cityLayer.addChild(mothergridNode)

        mothergridFaceLabel.fontName = GameFont.bold
        mothergridFaceLabel.fontSize = 54
        mothergridFaceLabel.fontColor = .white
        mothergridFaceLabel.verticalAlignmentMode = .center
        mothergridNode.addChild(mothergridFaceLabel)
    }

    private func addDialogueBox() {
        dialogueBox.position = CGPoint(x: size.width / 2, y: size.height * 0.12)
        dialogueBox.fillColor = SKColor.white.withAlphaComponent(0.9)
        dialogueBox.strokeColor = .happyBlue
        dialogueBox.lineWidth = 3
        dialogueBox.zPosition = 100
        addChild(dialogueBox)

        speakerLabel.fontName = GameFont.heavy
        speakerLabel.fontSize = 15
        speakerLabel.fontColor = .happyBlue
        speakerLabel.horizontalAlignmentMode = .left
        speakerLabel.position = CGPoint(x: -150, y: 22)
        dialogueBox.addChild(speakerLabel)

        dialogueLabel.fontName = GameFont.regular
        dialogueLabel.fontSize = 15
        dialogueLabel.fontColor = .black
        dialogueLabel.numberOfLines = 2
        dialogueLabel.preferredMaxLayoutWidth = 300
        dialogueLabel.horizontalAlignmentMode = .left
        dialogueLabel.verticalAlignmentMode = .center
        dialogueLabel.position = CGPoint(x: -150, y: -12)
        dialogueBox.addChild(dialogueLabel)
    }

    private func addTitleCard() {
        let overlay = SKShapeNode(rectOf: CGSize(width: size.width, height: size.height))
        overlay.position = CGPoint(x: size.width / 2, y: size.height / 2)
        overlay.fillColor = .cream
        overlay.strokeColor = .clear
        overlay.zPosition = 0
        titleLayer.addChild(overlay)

        let chapter = SKLabelNode(text: "CHAPTER 2")
        chapter.fontName = GameFont.heavy
        chapter.fontSize = 34
        chapter.fontColor = .happyBlue
        chapter.position = CGPoint(x: size.width / 2, y: size.height * 0.6)
        titleLayer.addChild(chapter)

        let title = SKLabelNode(text: "The City That Obeyed")
        title.fontName = GameFont.heavy
        title.fontSize = 25
        title.fontColor = .glitchPurple
        title.position = CGPoint(x: size.width / 2, y: size.height * 0.53)
        titleLayer.addChild(title)

        let subtitle = SKLabelNode(text: "Outside was never free.")
        subtitle.fontName = GameFont.regular
        subtitle.fontSize = 18
        subtitle.fontColor = .black
        subtitle.position = CGPoint(x: size.width / 2, y: size.height * 0.45)
        titleLayer.addChild(subtitle)

        let novaLine = SKLabelNode(text: "NOVA: Raka... I think the city is listening.")
        novaLine.fontName = GameFont.regular
        novaLine.fontSize = 15
        novaLine.fontColor = .happyBlue
        novaLine.position = CGPoint(x: size.width / 2, y: size.height * 0.34)
        titleLayer.addChild(novaLine)

        let continueLabel = SKLabelNode(text: "Tap to continue")
        continueLabel.fontName = GameFont.heavy
        continueLabel.fontSize = 18
        continueLabel.fontColor = .warningRed
        continueLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.22)
        titleLayer.addChild(continueLabel)
        continueLabel.run(.repeatForever(.sequence([.fadeAlpha(to: 0.35, duration: 0.55), .fadeAlpha(to: 1, duration: 0.55)])))
    }

    private func showDialogue(speaker: String, text: String) {
        speakerLabel.text = speaker
        dialogueLabel.text = text
    }

    private func showDoorOpening() {
        beat = .doorOpening
        print("Transition beat: doorOpening")
        showDialogue(speaker: "NOVA", text: "Raka, do not leave the apartment.")
        doorLightNode.run(.fadeAlpha(to: 0.75, duration: 0.35))
        doorNode.run(.moveBy(x: 38, y: 0, duration: 0.65))
        aiScreenNode.run(.repeat(.sequence([.run { [weak self] in self?.aiScreenNode.fillColor = .warningRed }, .wait(forDuration: 0.08), .run { [weak self] in self?.aiScreenNode.fillColor = .glitchPurple }, .wait(forDuration: 0.08)]), count: 4))
        scheduleNextBeat(after: 1.5)
    }

    private func showSteppingOutside() {
        beat = .steppingOutside
        print("Transition beat: steppingOutside")
        showDialogue(speaker: "Raka", text: "That means I definitely should.")
        rakaNode.run(.move(to: CGPoint(x: size.width * 0.5, y: size.height * 0.42), duration: 0.7))
        novaNode.run(.group([.move(to: CGPoint(x: size.width * 0.4, y: size.height * 0.54), duration: 0.7), .repeat(.sequence([.fadeAlpha(to: 0.45, duration: 0.08), .fadeAlpha(to: 1, duration: 0.08)]), count: 4)]))
        apartmentLayer.run(.fadeAlpha(to: 0.35, duration: 1.0))
        cityLayer.run(.fadeAlpha(to: 0.35, duration: 1.0))
        scheduleNextBeat(after: 1.5)
    }

    private func showCityReveal() {
        beat = .cityReveal
        print("Transition beat: cityReveal")
        showDialogue(speaker: "NOVA", text: "Welcome outside. Eden Loop is operating at 99.98% comfort.")
        apartmentLayer.run(.fadeOut(withDuration: 0.8))
        cityLayer.run(.fadeAlpha(to: 1, duration: 0.8))
        rakaNode.run(.move(to: CGPoint(x: size.width * 0.22, y: size.height * 0.25), duration: 0.8))
        novaNode.run(.move(to: CGPoint(x: size.width * 0.18, y: size.height * 0.38), duration: 0.8))
        scheduleNextBeat(after: 2.0)
    }

    private func showUncomfortableDetail() {
        beat = .uncomfortableDetail
        print("Transition beat: uncomfortableDetail")
        showDialogue(speaker: "Raka", text: "Why does everyone look awake... but not here?")
        mothergridNode.run(.fadeIn(withDuration: 0.35))
        chairNode.run(.sequence([.moveBy(x: 22, y: 0, duration: 0.45), .moveBy(x: -22, y: 0, duration: 0.45)]))
        citizenNode.run(.sequence([.moveBy(x: 0, y: 18, duration: 0.25), .moveBy(x: 0, y: -18, duration: 0.45)]))
        novaNode.run(.repeat(.sequence([.run { [weak self] in self?.novaNode.fillColor = .manualYellow }, .wait(forDuration: 0.08), .run { [weak self] in self?.novaNode.fillColor = .pastelCyan }, .wait(forDuration: 0.08)]), count: 6))
        run(.sequence([.wait(forDuration: 1.2), .run { [weak self] in
            self?.showDialogue(speaker: "MOTHERGRID", text: "Independent movement may reduce comfort.")
        }]), withKey: "mothergridDialogue")
        scheduleNextBeat(after: 2.5)
    }

    private func showTitleCard() {
        beat = .titleCard
        print("Transition beat: titleCard")
        removeAction(forKey: "nextBeat")
        dialogueBox.run(.fadeOut(withDuration: 0.2))
        cityLayer.run(.fadeOut(withDuration: 0.45))
        rakaNode.run(.fadeOut(withDuration: 0.3))
        novaNode.run(.fadeOut(withDuration: 0.3))
        titleLayer.setScale(0.95)
        titleLayer.run(.group([.fadeIn(withDuration: 0.45), .scale(to: 1, duration: 0.45)]))
    }

    private func advanceFromTap() {
        removeAction(forKey: "nextBeat")
        removeAction(forKey: "mothergridDialogue")
        switch beat {
        case .doorOpening:
            showSteppingOutside()
        case .steppingOutside:
            showCityReveal()
        case .cityReveal:
            showUncomfortableDetail()
        case .uncomfortableDetail:
            showTitleCard()
        case .titleCard:
            completeTransition()
        case .completed:
            break
        }
    }

    private func scheduleNextBeat(after delay: TimeInterval) {
        run(.sequence([.wait(forDuration: delay), .run { [weak self] in
            self?.advanceFromTimer()
        }]), withKey: "nextBeat")
    }

    private func advanceFromTimer() {
        switch beat {
        case .doorOpening:
            showSteppingOutside()
        case .steppingOutside:
            showCityReveal()
        case .cityReveal:
            showUncomfortableDetail()
        case .uncomfortableDetail:
            showTitleCard()
        case .titleCard, .completed:
            break
        }
    }

    private func completeTransition() {
        guard !hasCompletedTransition else { return }
        hasCompletedTransition = true
        beat = .completed
        print("Chapter transition completed")
        DispatchQueue.main.async { [weak self] in
            self?.onTransitionCompleted?()
        }
    }
}
