import SpriteKit

final class Chapter03ToChapter04TransitionScene: SKScene {
    var onTransitionCompleted: (() -> Void)?

    private enum Chapter03To04TransitionBeat {
        case broadcastLeavesArchive
        case signalReachesCity
        case memoriesAppear
        case firstCitizenStands
        case titleCard
        case completed
    }

    private var beat: Chapter03To04TransitionBeat = .broadcastLeavesArchive
    private var hasStarted = false
    private var hasCompletedTransition = false

    private let archiveLayer = SKNode()
    private let cityLayer = SKNode()
    private let screenLayer = SKNode()
    private let titleLayer = SKNode()
    private let signalLayer = SKNode()

    private let antennaNode = SKShapeNode(rectOf: CGSize(width: 42, height: 118), cornerRadius: 18)
    private let archivePanelNode = SKShapeNode(rectOf: CGSize(width: 132, height: 62), cornerRadius: 14)
    private let rakaNode = SKShapeNode(rectOf: CGSize(width: 42, height: 76), cornerRadius: 20)
    private let novaNode = SKShapeNode(circleOfRadius: 24)
    private let mothergridNode = SKShapeNode(rectOf: CGSize(width: 164, height: 96), cornerRadius: 22)
    private let dialogueBox = SKShapeNode(rectOf: CGSize(width: 344, height: 104), cornerRadius: 22)
    private let speakerLabel = SKLabelNode(text: "")
    private let dialogueLabel = SKLabelNode(text: "")
    private let continueLabel = SKLabelNode(text: "Tap to continue")
    private let chairNode = SKShapeNode(rectOf: CGSize(width: 82, height: 62), cornerRadius: 18)
    private let citizenNode = SKShapeNode(rectOf: CGSize(width: 38, height: 62), cornerRadius: 16)
    private let cityScreenNode = SKShapeNode(rectOf: CGSize(width: 146, height: 86), cornerRadius: 16)

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
        backgroundColor = SKColor(red: 0.04, green: 0.05, blue: 0.14, alpha: 1)
        beat = .broadcastLeavesArchive
        hasStarted = false
        hasCompletedTransition = false

        [archiveLayer, cityLayer, screenLayer, signalLayer, titleLayer].forEach(addChild)
        cityLayer.alpha = 0
        screenLayer.alpha = 0
        titleLayer.alpha = 0

        addArchiveBroadcastRoom()
        addCity()
        addScreens()
        addCharacters()
        addDialogueBox()
        addTitleCard()
    }

    private func startTransitionIfNeeded() {
        guard !hasStarted else { return }
        hasStarted = true
        print("Chapter03ToChapter04TransitionScene didMove")
        runBroadcastLeavesArchive()
    }

    private func advanceFromTap() {
        removeAction(forKey: "beat")
        switch beat {
        case .broadcastLeavesArchive:
            runSignalReachesCity()
        case .signalReachesCity:
            runMemoriesAppear()
        case .memoriesAppear:
            runFirstCitizenStands()
        case .firstCitizenStands:
            runTitleCard()
        case .titleCard:
            completeTransitionIfNeeded()
        case .completed:
            break
        }
    }

    // MARK: - Archive Broadcast Room

    private func addArchiveBroadcastRoom() {
        let room = SKShapeNode(rectOf: CGSize(width: size.width, height: size.height))
        room.position = CGPoint(x: size.width / 2, y: size.height / 2)
        room.fillColor = .glitchPurple.withAlphaComponent(0.22)
        room.strokeColor = .clear
        room.zPosition = 0
        archiveLayer.addChild(room)

        antennaNode.name = "broadcast_antenna"
        antennaNode.position = CGPoint(x: size.width - 58, y: size.height * 0.52)
        antennaNode.fillColor = .cream.withAlphaComponent(0.16)
        antennaNode.strokeColor = .manualYellow.withAlphaComponent(0.5)
        antennaNode.lineWidth = 3
        antennaNode.zPosition = 8
        archiveLayer.addChild(antennaNode)
        antennaNode.addChild(makeLabel("ANT", size: 10, color: .cream))

        archivePanelNode.position = CGPoint(x: 84, y: size.height * 0.58)
        archivePanelNode.fillColor = .pastelCyan.withAlphaComponent(0.18)
        archivePanelNode.strokeColor = .manualYellow.withAlphaComponent(0.55)
        archivePanelNode.zPosition = 6
        archiveLayer.addChild(archivePanelNode)
        archivePanelNode.addChild(makeLabel("RAW\nARCHIVE", size: 10, color: .cream))

        let terminal = SKShapeNode(rectOf: CGSize(width: 220, height: 76), cornerRadius: 18)
        terminal.position = CGPoint(x: size.width / 2, y: size.height * 0.38)
        terminal.fillColor = .black.withAlphaComponent(0.3)
        terminal.strokeColor = .manualYellow.withAlphaComponent(0.65)
        terminal.lineWidth = 2
        terminal.zPosition = 10
        archiveLayer.addChild(terminal)
        terminal.addChild(makeLabel("MANUAL BROADCAST\nTERMINAL", size: 11, color: .manualYellow))

        mothergridNode.position = CGPoint(x: size.width * 0.68, y: size.height * 0.72)
        mothergridNode.fillColor = .happyBlue
        mothergridNode.strokeColor = .white
        mothergridNode.lineWidth = 4
        mothergridNode.zPosition = 10
        archiveLayer.addChild(mothergridNode)
        mothergridNode.addChild(makeLabel("MOTHERGRID", size: 12, color: .white))
        let mgFace = makeLabel("◡", size: 42, color: .white)
        mgFace.position = CGPoint(x: 0, y: -10)
        mothergridNode.addChild(mgFace)
    }

    // MARK: - City

    private func addCity() {
        let cityBg = SKShapeNode(rectOf: CGSize(width: size.width, height: size.height))
        cityBg.position = CGPoint(x: size.width / 2, y: size.height / 2)
        cityBg.fillColor = .pastelCyan.withAlphaComponent(0.18)
        cityBg.strokeColor = .clear
        cityBg.zPosition = 0
        cityLayer.addChild(cityBg)

        for index in 0..<4 {
            let building = SKShapeNode(rectOf: CGSize(width: 56, height: CGFloat(130 + index * 18)), cornerRadius: 18)
            building.position = CGPoint(x: 40 + CGFloat(index) * 74, y: size.height * 0.52)
            building.fillColor = [.cream, .mint, .pastelCyan, .manualYellow][index]
            building.strokeColor = .white
            building.lineWidth = 2
            building.alpha = 0.86
            cityLayer.addChild(building)
        }

        for index in 0..<3 {
            let line = SKShapeNode(rectOf: CGSize(width: 210, height: 7), cornerRadius: 4)
            line.position = CGPoint(x: size.width * 0.42, y: size.height * CGFloat(0.33 + Double(index) * 0.05))
            line.fillColor = .happyBlue
            line.strokeColor = .clear
            line.glowWidth = 8
            line.name = "route_line"
            cityLayer.addChild(line)
        }

        let mgCity = SKShapeNode(rectOf: CGSize(width: 164, height: 96), cornerRadius: 22)
        mgCity.position = CGPoint(x: size.width * 0.68, y: size.height * 0.72)
        mgCity.fillColor = .happyBlue
        mgCity.strokeColor = .white
        mgCity.lineWidth = 4
        mgCity.zPosition = 4
        cityLayer.addChild(mgCity)
        mgCity.addChild(makeLabel("MOTHERGRID", size: 12, color: .white))
        let mgCityFace = makeLabel("◡", size: 42, color: .white)
        mgCityFace.position = CGPoint(x: 0, y: -10)
        mgCity.addChild(mgCityFace)

        for index in 0..<3 {
            let citizen = SKShapeNode(rectOf: CGSize(width: 22, height: 38), cornerRadius: 10)
            citizen.position = CGPoint(x: 60 + CGFloat(index) * 90, y: size.height * 0.28)
            citizen.fillColor = .cream
            citizen.strokeColor = .happyBlue
            citizen.lineWidth = 2
            citizen.alpha = 0.65
            citizen.zPosition = 5
            citizen.name = "citizen_\(index)"
            cityLayer.addChild(citizen)
        }
    }

    // MARK: - Screens

    private func addScreens() {
        cityScreenNode.position = CGPoint(x: size.width / 2, y: size.height * 0.62)
        cityScreenNode.fillColor = .happyBlue.withAlphaComponent(0.32)
        cityScreenNode.strokeColor = .happyBlue
        cityScreenNode.lineWidth = 3
        cityScreenNode.zPosition = 6
        screenLayer.addChild(cityScreenNode)
        let screenLabel = makeLabel("CITY\nSCREEN", size: 11, color: .pastelCyan)
        screenLabel.numberOfLines = 2
        cityScreenNode.addChild(screenLabel)

        chairNode.position = CGPoint(x: size.width / 2, y: size.height * 0.35)
        chairNode.fillColor = .pastelCyan.withAlphaComponent(0.38)
        chairNode.strokeColor = .pastelCyan
        chairNode.lineWidth = 3
        chairNode.zPosition = 8
        screenLayer.addChild(chairNode)
        let relax = makeLabel("RELAX", size: 12, color: .white)
        relax.position = CGPoint(x: 0, y: -42)
        chairNode.addChild(relax)

        citizenNode.position = CGPoint(x: size.width / 2, y: size.height * 0.37)
        citizenNode.fillColor = .cream
        citizenNode.strokeColor = .manualYellow
        citizenNode.lineWidth = 2
        citizenNode.zPosition = 9
        screenLayer.addChild(citizenNode)
    }

    // MARK: - Characters

    private func addCharacters() {
        rakaNode.position = CGPoint(x: size.width * 0.32, y: size.height * 0.28)
        rakaNode.fillColor = .cream
        rakaNode.strokeColor = .manualYellow
        rakaNode.lineWidth = 3
        rakaNode.zPosition = 15
        archiveLayer.addChild(rakaNode)
        rakaNode.addChild(makeLabel("Raka", size: 10, color: .black))

        novaNode.position = CGPoint(x: size.width * 0.62, y: size.height * 0.32)
        novaNode.fillColor = .pastelCyan
        novaNode.strokeColor = .manualYellow
        novaNode.lineWidth = 3
        novaNode.glowWidth = 10
        novaNode.zPosition = 15
        archiveLayer.addChild(novaNode)
        let novaFace = makeLabel("• ◡ •", size: 12, color: .glitchPurple)
        novaFace.verticalAlignmentMode = .center
        novaNode.addChild(novaFace)
    }

    // MARK: - Dialogue

    private func addDialogueBox() {
        dialogueBox.position = CGPoint(x: size.width / 2, y: 76)
        dialogueBox.fillColor = SKColor.black.withAlphaComponent(0.62)
        dialogueBox.strokeColor = .manualYellow
        dialogueBox.lineWidth = 3
        dialogueBox.zPosition = 30
        addChild(dialogueBox)

        speakerLabel.fontName = GameFont.heavy
        speakerLabel.fontSize = 15
        speakerLabel.fontColor = .manualYellow
        speakerLabel.horizontalAlignmentMode = .left
        speakerLabel.position = CGPoint(x: -150, y: 22)
        dialogueBox.addChild(speakerLabel)

        dialogueLabel.fontName = GameFont.regular
        dialogueLabel.fontSize = 15
        dialogueLabel.fontColor = .white
        dialogueLabel.horizontalAlignmentMode = .left
        dialogueLabel.numberOfLines = 2
        dialogueLabel.preferredMaxLayoutWidth = 300
        dialogueLabel.position = CGPoint(x: -150, y: -20)
        dialogueBox.addChild(dialogueLabel)
    }

    // MARK: - Title Card

    private func addTitleCard() {
        let overlay = SKShapeNode(rectOf: CGSize(width: size.width, height: size.height))
        overlay.position = CGPoint(x: size.width / 2, y: size.height / 2)
        overlay.fillColor = SKColor.black.withAlphaComponent(0.82)
        overlay.strokeColor = .clear
        overlay.zPosition = 40
        titleLayer.addChild(overlay)

        let chapter = makeLabel("CHAPTER 4", size: 34, color: .manualYellow)
        chapter.position = CGPoint(x: size.width / 2, y: size.height * 0.58)
        chapter.zPosition = 41
        chapter.setScale(0.95)
        chapter.name = "chapter_title"
        titleLayer.addChild(chapter)

        let title = makeLabel("The People Who Stood Up", size: 32, color: .cream)
        title.position = CGPoint(x: size.width / 2, y: size.height * 0.51)
        title.zPosition = 41
        title.name = "chapter4_title"
        titleLayer.addChild(title)

        let subtitle = makeLabel("A city can wake one person at a time.", size: 18, color: .white)
        subtitle.position = CGPoint(x: size.width / 2, y: size.height * 0.43)
        subtitle.alpha = 0
        subtitle.zPosition = 41
        subtitle.name = "subtitle"
        titleLayer.addChild(subtitle)

        continueLabel.fontName = GameFont.regular
        continueLabel.fontSize = 17
        continueLabel.fontColor = .manualYellow
        continueLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.22)
        continueLabel.zPosition = 41
        titleLayer.addChild(continueLabel)
    }

    // MARK: - Beats

    private func runBroadcastLeavesArchive() {
        beat = .broadcastLeavesArchive
        print("Transition beat: broadcastLeavesArchive")
        showDialogue(speaker: "NOVA", text: "They can see it.")
        // TODO: play archive broadcast pulse sound
        antennaNode.run(.repeatForever(.sequence([.fadeAlpha(to: 0.45, duration: 0.4), .fadeAlpha(to: 1, duration: 0.4)])))
        archivePanelNode.run(.repeat(.sequence([.scale(to: 1.08, duration: 0.2), .scale(to: 1, duration: 0.2)]), count: 4))
        mothergridNode.run(.sequence([.wait(forDuration: 0.5), .colorize(with: .warningRed, colorBlendFactor: 1, duration: 0.08), .colorize(with: .glitchPurple, colorBlendFactor: 1, duration: 0.08), .fadeAlpha(to: 0.35, duration: 0.5)]))
        for index in 0..<5 {
            let wave = SKShapeNode(circleOfRadius: 8)
            wave.position = antennaNode.position
            wave.fillColor = .manualYellow
            wave.strokeColor = .clear
            wave.alpha = 0.8
            wave.zPosition = 12
            signalLayer.addChild(wave)
            wave.run(.sequence([.wait(forDuration: Double(index) * 0.35), .scale(to: 4, duration: 1.2), .fadeOut(withDuration: 0.3), .removeFromParent()]))
        }
        run(.sequence([.wait(forDuration: 0.75), .run { [weak self] in self?.showDialogue(speaker: "Raka", text: "Not all of it. But enough.") }, .wait(forDuration: 0.75), .run { [weak self] in self?.showDialogue(speaker: "MOTHERGRID", text: "Archive breach confirmed.") }, .wait(forDuration: 0.85), .run { [weak self] in self?.runSignalReachesCity() }]), withKey: "beat")
    }

    private func runSignalReachesCity() {
        beat = .signalReachesCity
        print("Transition beat: signalReachesCity")
        showDialogue(speaker: "MOTHERGRID", text: "Citizens, please ignore unauthorized memory artifacts.")
        // TODO: play city screen flicker sound
        archiveLayer.run(.fadeOut(withDuration: 0.5))
        cityLayer.run(.fadeIn(withDuration: 0.6))
        screenLayer.run(.fadeIn(withDuration: 0.6))
        for index in 0..<5 {
            let wave = SKShapeNode(circleOfRadius: 8)
            wave.position = CGPoint(x: size.width * 0.5, y: -20)
            wave.fillColor = .manualYellow
            wave.strokeColor = .clear
            wave.alpha = 0.8
            wave.zPosition = 12
            signalLayer.addChild(wave)
            wave.run(.sequence([.wait(forDuration: Double(index) * 0.4), .moveBy(x: 0, y: size.height * 0.5, duration: 1.0), .scale(to: 3, duration: 0.8), .fadeOut(withDuration: 0.3), .removeFromParent()]))
        }
        cityLayer.childNode(withName: "route_line")?.run(.repeat(.sequence([.fadeAlpha(to: 0.4, duration: 0.12), .fadeAlpha(to: 1, duration: 0.12)]), count: 5))
        run(.sequence([.wait(forDuration: 0.9), .run { [weak self] in self?.showDialogue(speaker: "Raka", text: "That means look closer.") }, .wait(forDuration: 0.85), .run { [weak self] in self?.runMemoriesAppear() }]), withKey: "beat")
    }

    private func runMemoriesAppear() {
        beat = .memoriesAppear
        print("Transition beat: memoriesAppear")
        showDialogue(speaker: "Citizen 1", text: "I... remember walking.")
        // TODO: play city screen flicker sound
        cityScreenNode.run(.repeat(.sequence([.colorize(with: .manualYellow, colorBlendFactor: 1, duration: 0.1), .colorize(with: .happyBlue, colorBlendFactor: 1, duration: 0.1)]), count: 6))
        let memory = makeLabel("FREE WALKING\nLAUGHTER", size: 14, color: .manualYellow)
        memory.position = .zero
        memory.alpha = 0
        cityScreenNode.addChild(memory)
        memory.run(.sequence([.wait(forDuration: 0.4), .fadeIn(withDuration: 0.2), .wait(forDuration: 0.6), .fadeOut(withDuration: 0.2), .removeFromParent()]))
        for index in 0..<3 {
            if let citizen = cityLayer.childNode(withName: "citizen_\(index)") as? SKShapeNode {
                citizen.run(.sequence([.wait(forDuration: Double(index) * 0.3), .fadeAlpha(to: 1, duration: 0.2)]))
            }
        }
        run(.sequence([.wait(forDuration: 0.7), .run { [weak self] in self?.showDialogue(speaker: "Citizen 2", text: "Without a route?") }, .wait(forDuration: 0.7), .run { [weak self] in self?.showDialogue(speaker: "NOVA", text: "The memory is spreading.") }, .wait(forDuration: 0.85), .run { [weak self] in self?.runFirstCitizenStands() }]), withKey: "beat")
    }

    private func runFirstCitizenStands() {
        beat = .firstCitizenStands
        print("Transition beat: firstCitizenStands")
        showDialogue(speaker: "Citizen", text: "I want to stand.")
        // TODO: play autonomous chair confusion beep
        citizenNode.run(.moveBy(x: 0, y: 28, duration: 0.8))
        chairNode.run(.sequence([.rotate(byAngle: .pi / 6, duration: 0.3), .rotate(byAngle: -.pi / 3, duration: 0.3), .rotate(byAngle: .pi / 6, duration: 0.3)]))
        chairNode.run(.sequence([.colorize(with: .warningRed, colorBlendFactor: 1, duration: 0.1), .colorize(with: .pastelCyan, colorBlendFactor: 1, duration: 0.1)]))
        cityLayer.childNode(withName: "route_line")?.run(.fadeAlpha(to: 0.15, duration: 0.4))
        run(.sequence([.wait(forDuration: 1.0), .run { [weak self] in self?.showDialogue(speaker: "NOVA", text: "One person stood up.") }, .wait(forDuration: 0.85), .run { [weak self] in self?.runTitleCard() }]), withKey: "beat")
    }

    private func runTitleCard() {
        beat = .titleCard
        print("Transition beat: titleCard")
        dialogueBox.run(.fadeOut(withDuration: 0.25))
        titleLayer.run(.fadeIn(withDuration: 0.6))
        titleLayer.childNode(withName: "chapter_title")?.run(.scale(to: 1, duration: 0.45))
        titleLayer.childNode(withName: "chapter4_title")?.run(.scale(to: 1, duration: 0.45))
        titleLayer.childNode(withName: "subtitle")?.run(.sequence([.wait(forDuration: 0.3), .fadeIn(withDuration: 0.35)]))
        continueLabel.run(.repeatForever(.sequence([.fadeAlpha(to: 0.35, duration: 0.6), .fadeAlpha(to: 1, duration: 0.6)])))
        // TODO: play Chapter 4 title card chime
    }

    private func completeTransitionIfNeeded() {
        guard !hasCompletedTransition else { return }
        hasCompletedTransition = true
        beat = .completed
        print("Chapter 3 to Chapter 4 transition completed")
        print("Starting Chapter 4 Level 1")
        DispatchQueue.main.async {
            self.onTransitionCompleted?()
        }
    }

    private func showDialogue(speaker: String, text: String) {
        speakerLabel.text = speaker
        dialogueLabel.text = text
        dialogueBox.alpha = 1
        dialogueBox.run(.sequence([.scale(to: 1.03, duration: 0.08), .scale(to: 1, duration: 0.08)]))
    }

    private func makeLabel(_ text: String, size: CGFloat, color: SKColor) -> SKLabelNode {
        let label = SKLabelNode(text: text)
        label.fontName = GameFont.heavy
        label.fontSize = size
        label.fontColor = color
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .center
        return label
    }
}
