import SpriteKit

final class Chapter02ToChapter03TransitionScene: SKScene {
    var onTransitionCompleted: (() -> Void)?

    private enum Chapter02To03TransitionBeat {
        case tunnelDoorClosing
        case citySignalFades
        case oldTransitRide
        case archiveSignalDetected
        case titleCard
        case completed
    }

    private var beat: Chapter02To03TransitionBeat = .tunnelDoorClosing
    private var hasStarted = false
    private var hasCompletedTransition = false
    private var dialogueIndex = 0

    private let cityLayer = SKNode()
    private let tunnelLayer = SKNode()
    private let archiveLayer = SKNode()
    private let titleLayer = SKNode()
    private let movingLayer = SKNode()
    private let dustLayer = SKNode()

    private let cityGlow = SKShapeNode(rectOf: .zero)
    private let doorNode = SKShapeNode(rectOf: .zero)
    private let mothergridNode = SKShapeNode(rectOf: .zero)
    private let mothergridFace = SKLabelNode(text: "◡")
    private let rakaNode = SKShapeNode(rectOf: .zero)
    private let wristLight = SKShapeNode(circleOfRadius: 14)
    private let novaNode = SKShapeNode(circleOfRadius: 20)
    private let archiveDoor = SKShapeNode(rectOf: .zero)
    private let monitorText = SKLabelNode(text: "")
    private let dialogueBox = SKShapeNode(rectOf: CGSize(width: 344, height: 104), cornerRadius: 22)
    private let speakerLabel = SKLabelNode(text: "")
    private let dialogueLabel = SKLabelNode(text: "")
    private let continueLabel = SKLabelNode(text: "Tap to continue")

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
        backgroundColor = SKColor(red: 0.05, green: 0.08, blue: 0.18, alpha: 1)
        beat = .tunnelDoorClosing
        hasStarted = false
        hasCompletedTransition = false
        dialogueIndex = 0

        [cityLayer, tunnelLayer, movingLayer, dustLayer, archiveLayer, titleLayer].forEach(addChild)
        archiveLayer.alpha = 0
        titleLayer.alpha = 0

        addCityEntrance()
        addTunnel()
        addCharacters()
        addDust()
        addArchiveDoor()
        addDialogueBox()
        addTitleCard()
    }

    private func startTransitionIfNeeded() {
        guard !hasStarted else { return }
        hasStarted = true
        print("Chapter02ToChapter03TransitionScene didMove")
        runTunnelDoorClosing()
    }

    private func advanceFromTap() {
        removeAction(forKey: "beat")
        switch beat {
        case .tunnelDoorClosing:
            runCitySignalFades()
        case .citySignalFades:
            runOldTransitRide()
        case .oldTransitRide:
            runArchiveSignalDetected()
        case .archiveSignalDetected:
            runTitleCard()
        case .titleCard:
            completeTransitionIfNeeded()
        case .completed:
            break
        }
    }

    private func addCityEntrance() {
        cityGlow.path = CGPath(roundedRect: CGRect(x: -size.width / 2, y: -size.height / 2, width: size.width, height: size.height), cornerWidth: 0, cornerHeight: 0, transform: nil)
        cityGlow.position = CGPoint(x: size.width / 2, y: size.height / 2)
        cityGlow.fillColor = .pastelCyan
        cityGlow.strokeColor = .clear
        cityGlow.zPosition = 0
        cityLayer.addChild(cityGlow)

        for index in 0..<4 {
            let building = SKShapeNode(rectOf: CGSize(width: 56, height: CGFloat(130 + index * 18)), cornerRadius: 18)
            building.position = CGPoint(x: 40 + CGFloat(index) * 74, y: size.height * 0.52)
            building.fillColor = [SKColor.cream, .mint, .pastelCyan, .manualYellow][index]
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

        mothergridNode.path = CGPath(roundedRect: CGRect(x: -82, y: -48, width: 164, height: 96), cornerWidth: 22, cornerHeight: 22, transform: nil)
        mothergridNode.position = CGPoint(x: size.width * 0.68, y: size.height * 0.72)
        mothergridNode.fillColor = .happyBlue
        mothergridNode.strokeColor = .white
        mothergridNode.lineWidth = 4
        mothergridNode.zPosition = 4
        cityLayer.addChild(mothergridNode)

        let name = makeLabel("MOTHERGRID", size: 12, color: .white)
        name.position = CGPoint(x: 0, y: 24)
        mothergridNode.addChild(name)
        mothergridFace.fontName = "AvenirNext-Heavy"
        mothergridFace.fontSize = 42
        mothergridFace.fontColor = .white
        mothergridFace.verticalAlignmentMode = .center
        mothergridFace.position = CGPoint(x: 0, y: -10)
        mothergridNode.addChild(mothergridFace)
    }

    private func addTunnel() {
        let back = SKShapeNode(rectOf: CGSize(width: size.width, height: size.height))
        back.position = CGPoint(x: size.width / 2, y: size.height / 2)
        back.fillColor = SKColor(red: 0.05, green: 0.07, blue: 0.16, alpha: 1)
        back.strokeColor = .clear
        back.zPosition = 1
        tunnelLayer.addChild(back)

        let arch = SKShapeNode(ellipseOf: CGSize(width: size.width * 1.25, height: size.height * 0.9))
        arch.position = CGPoint(x: size.width / 2, y: size.height * 0.35)
        arch.fillColor = .glitchPurple.withAlphaComponent(0.28)
        arch.strokeColor = .cream.withAlphaComponent(0.25)
        arch.lineWidth = 6
        arch.zPosition = 2
        tunnelLayer.addChild(arch)

        doorNode.path = CGPath(roundedRect: CGRect(x: -118, y: -220, width: 236, height: 440), cornerWidth: 30, cornerHeight: 30, transform: nil)
        doorNode.position = CGPoint(x: size.width / 2, y: size.height * 0.48)
        doorNode.fillColor = SKColor(red: 0.55, green: 0.54, blue: 0.5, alpha: 1)
        doorNode.strokeColor = .manualYellow
        doorNode.lineWidth = 5
        doorNode.zPosition = 6
        doorNode.xScale = 0.08
        tunnelLayer.addChild(doorNode)

        for index in 0..<5 {
            addMovingSign(text: ["OLD TRANSIT", "MANUAL ACCESS", "ARCHIVE SECTOR", "→", "↘"][index], x: size.width + CGFloat(index) * 120, y: size.height * CGFloat(0.62 - Double(index % 2) * 0.18))
        }
    }

    private func addMovingSign(text: String, x: CGFloat, y: CGFloat) {
        let sign = SKShapeNode(rectOf: CGSize(width: 104, height: 34), cornerRadius: 10)
        sign.position = CGPoint(x: x, y: y)
        sign.fillColor = .cream.withAlphaComponent(0.9)
        sign.strokeColor = .manualYellow
        sign.lineWidth = 2
        sign.zPosition = 3
        movingLayer.addChild(sign)

        let label = makeLabel(text, size: 10, color: .glitchPurple)
        label.verticalAlignmentMode = .center
        sign.addChild(label)
    }

    private func addCharacters() {
        rakaNode.path = CGPath(roundedRect: CGRect(x: -32, y: -48, width: 64, height: 96), cornerWidth: 30, cornerHeight: 30, transform: nil)
        rakaNode.position = CGPoint(x: size.width * 0.42, y: size.height * 0.28)
        rakaNode.fillColor = .happyBlue
        rakaNode.strokeColor = .white
        rakaNode.lineWidth = 4
        rakaNode.zPosition = 10
        addChild(rakaNode)

        for x in [-12, 12] as [CGFloat] {
            let eye = SKShapeNode(circleOfRadius: 4)
            eye.position = CGPoint(x: x, y: 14)
            eye.fillColor = .black
            eye.strokeColor = .clear
            rakaNode.addChild(eye)
        }

        wristLight.position = CGPoint(x: 31, y: -4)
        wristLight.fillColor = .manualYellow
        wristLight.strokeColor = .clear
        wristLight.glowWidth = 12
        rakaNode.addChild(wristLight)

        novaNode.position = CGPoint(x: size.width * 0.62, y: size.height * 0.37)
        novaNode.fillColor = .pastelCyan
        novaNode.strokeColor = .manualYellow
        novaNode.lineWidth = 3
        novaNode.glowWidth = 10
        novaNode.zPosition = 10
        addChild(novaNode)

        let novaFace = makeLabel("• •", size: 12, color: .glitchPurple)
        novaFace.verticalAlignmentMode = .center
        novaNode.addChild(novaFace)

        for angle in [20, 160, 260] as [CGFloat] {
            let crack = SKShapeNode(rectOf: CGSize(width: 4, height: 18), cornerRadius: 2)
            crack.position = CGPoint(x: cos(angle * .pi / 180) * 11, y: sin(angle * .pi / 180) * 11)
            crack.zRotation = angle * .pi / 180
            crack.fillColor = .warningRed
            crack.strokeColor = .clear
            crack.alpha = 0.75
            novaNode.addChild(crack)
        }
    }

    private func addDust() {
        for index in 0..<28 {
            let dust = SKShapeNode(circleOfRadius: CGFloat(1 + index % 3))
            dust.position = CGPoint(x: CGFloat.random(in: 10...(size.width - 10)), y: CGFloat.random(in: 120...(size.height - 120)))
            dust.fillColor = .cream
            dust.strokeColor = .clear
            dust.alpha = 0
            dust.zPosition = 8
            dustLayer.addChild(dust)
        }
    }

    private func addArchiveDoor() {
        archiveDoor.path = CGPath(roundedRect: CGRect(x: -120, y: -170, width: 240, height: 340), cornerWidth: 30, cornerHeight: 30, transform: nil)
        archiveDoor.position = CGPoint(x: size.width / 2, y: size.height * 0.5)
        archiveDoor.fillColor = SKColor(red: 0.32, green: 0.32, blue: 0.38, alpha: 1)
        archiveDoor.strokeColor = .manualYellow
        archiveDoor.lineWidth = 5
        archiveDoor.glowWidth = 0
        archiveDoor.zPosition = 8
        archiveLayer.addChild(archiveDoor)

        let doorLabel = makeLabel("ARCHIVE", size: 24, color: .manualYellow)
        doorLabel.position = CGPoint(x: 0, y: 100)
        archiveDoor.addChild(doorLabel)

        let lock = SKShapeNode(circleOfRadius: 24)
        lock.position = CGPoint(x: 0, y: -8)
        lock.fillColor = .manualYellow
        lock.strokeColor = .cream
        lock.lineWidth = 3
        archiveDoor.addChild(lock)

        for index in 0..<4 {
            let monitor = SKShapeNode(rectOf: CGSize(width: 88, height: 48), cornerRadius: 12)
            monitor.position = CGPoint(x: index % 2 == 0 ? 62 : -62, y: CGFloat(48 - index * 44))
            monitor.fillColor = .black
            monitor.strokeColor = .glitchPurple
            monitor.lineWidth = 2
            monitor.alpha = 0.28
            monitor.name = "dead_monitor"
            archiveDoor.addChild(monitor)
        }

        monitorText.fontName = "AvenirNext-Heavy"
        monitorText.fontSize = 11
        monitorText.fontColor = .manualYellow
        monitorText.numberOfLines = 2
        monitorText.preferredMaxLayoutWidth = 190
        monitorText.position = CGPoint(x: size.width / 2, y: size.height * 0.25)
        monitorText.zPosition = 12
        archiveLayer.addChild(monitorText)
    }

    private func addDialogueBox() {
        dialogueBox.position = CGPoint(x: size.width / 2, y: 76)
        dialogueBox.fillColor = SKColor.black.withAlphaComponent(0.62)
        dialogueBox.strokeColor = .manualYellow
        dialogueBox.lineWidth = 3
        dialogueBox.zPosition = 30
        addChild(dialogueBox)

        speakerLabel.fontName = "AvenirNext-Heavy"
        speakerLabel.fontSize = 15
        speakerLabel.fontColor = .manualYellow
        speakerLabel.horizontalAlignmentMode = .left
        speakerLabel.position = CGPoint(x: -150, y: 22)
        dialogueBox.addChild(speakerLabel)

        dialogueLabel.fontName = "AvenirNext-DemiBold"
        dialogueLabel.fontSize = 15
        dialogueLabel.fontColor = .white
        dialogueLabel.horizontalAlignmentMode = .left
        dialogueLabel.numberOfLines = 2
        dialogueLabel.preferredMaxLayoutWidth = 300
        dialogueLabel.position = CGPoint(x: -150, y: -20)
        dialogueBox.addChild(dialogueLabel)
    }

    private func addTitleCard() {
        let overlay = SKShapeNode(rectOf: CGSize(width: size.width, height: size.height))
        overlay.position = CGPoint(x: size.width / 2, y: size.height / 2)
        overlay.fillColor = SKColor.black.withAlphaComponent(0.82)
        overlay.strokeColor = .clear
        overlay.zPosition = 40
        titleLayer.addChild(overlay)

        let chapter = makeLabel("CHAPTER 3", size: 34, color: .manualYellow)
        chapter.position = CGPoint(x: size.width / 2, y: size.height * 0.58)
        chapter.zPosition = 41
        chapter.setScale(0.95)
        chapter.name = "chapter_title"
        titleLayer.addChild(chapter)

        let title = makeLabel("The Archive", size: 42, color: .cream)
        title.position = CGPoint(x: size.width / 2, y: size.height * 0.51)
        title.zPosition = 41
        title.name = "archive_title"
        titleLayer.addChild(title)

        let subtitle = makeLabel("Some choices were deleted.", size: 18, color: .white)
        subtitle.position = CGPoint(x: size.width / 2, y: size.height * 0.43)
        subtitle.alpha = 0
        subtitle.zPosition = 41
        subtitle.name = "subtitle"
        titleLayer.addChild(subtitle)

        let novaLine = makeLabel("NOVA: Raka... something here knows my name.", size: 15, color: .pastelCyan)
        novaLine.position = CGPoint(x: size.width / 2, y: size.height * 0.34)
        novaLine.alpha = 0
        novaLine.zPosition = 41
        novaLine.name = "nova_line"
        titleLayer.addChild(novaLine)

        continueLabel.fontName = "AvenirNext-DemiBold"
        continueLabel.fontSize = 17
        continueLabel.fontColor = .manualYellow
        continueLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.22)
        continueLabel.zPosition = 41
        titleLayer.addChild(continueLabel)
    }

    private func runTunnelDoorClosing() {
        beat = .tunnelDoorClosing
        print("Transition beat: tunnelDoorClosing")
        showDialogue(speaker: "MOTHERGRID", text: "Manual deviation has been recorded.")
        // TODO: play heavy old door closing sound
        doorNode.run(.scaleX(to: 1, duration: 1.4))
        cityGlow.run(.fadeAlpha(to: 0.45, duration: 1.4))
        mothergridNode.run(.sequence([.wait(forDuration: 0.7), .colorize(with: .warningRed, colorBlendFactor: 1, duration: 0.08), .colorize(with: .glitchPurple, colorBlendFactor: 1, duration: 0.08), .fadeAlpha(to: 0.35, duration: 0.5)]))
        run(.sequence([.wait(forDuration: 0.75), .run { [weak self] in self?.showDialogue(speaker: "Raka", text: "Good. Write it down twice.") }, .wait(forDuration: 0.75), .run { [weak self] in self?.runCitySignalFades() }]), withKey: "beat")
    }

    private func runCitySignalFades() {
        beat = .citySignalFades
        print("Transition beat: citySignalFades")
        showDialogue(speaker: "NOVA", text: "Signal from Eden Loop is dropping.")
        // TODO: play tunnel ambience
        cityLayer.children.filter { $0.name == "route_line" }.forEach { $0.run(.fadeOut(withDuration: 0.8)) }
        cityLayer.run(.fadeAlpha(to: 0.05, duration: 1.3))
        wristLight.run(.repeatForever(.sequence([.scale(to: 1.35, duration: 0.35), .scale(to: 0.85, duration: 0.35)])))
        dustLayer.children.forEach { $0.run(.fadeAlpha(to: CGFloat.random(in: 0.25...0.7), duration: 0.8)) }
        novaNode.run(.move(to: CGPoint(x: size.width * 0.53, y: size.height * 0.34), duration: 1.0))
        run(.sequence([.wait(forDuration: 0.75), .run { [weak self] in self?.showDialogue(speaker: "Raka", text: "That sounds peaceful.") }, .wait(forDuration: 0.75), .run { [weak self] in self?.runOldTransitRide() }]), withKey: "beat")
    }

    private func runOldTransitRide() {
        beat = .oldTransitRide
        print("Transition beat: oldTransitRide")
        showDialogue(speaker: "NOVA", text: "This tunnel is not in the approved city map.")
        movingLayer.run(.moveBy(x: -size.width - 520, y: 0, duration: 2.0))
        rakaNode.run(.repeat(.sequence([.moveBy(x: 0, y: 10, duration: 0.18), .moveBy(x: 0, y: -10, duration: 0.18)]), count: 5))
        novaNode.run(.repeat(.sequence([.colorize(with: .manualYellow, colorBlendFactor: 0.9, duration: 0.08), .colorize(with: .pastelCyan, colorBlendFactor: 1, duration: 0.08)]), count: 8))
        addSparks()
        run(.sequence([.wait(forDuration: 1.0), .run { [weak self] in self?.showDialogue(speaker: "Raka", text: "Then maybe it still belongs to people.") }, .wait(forDuration: 1.0), .run { [weak self] in self?.runArchiveSignalDetected() }]), withKey: "beat")
    }

    private func runArchiveSignalDetected() {
        beat = .archiveSignalDetected
        print("Transition beat: archiveSignalDetected")
        showDialogue(speaker: "NOVA", text: "There is a signal ahead. Old. Manual. Almost... familiar.")
        // TODO: play soft archive monitor flicker
        archiveLayer.run(.fadeIn(withDuration: 0.6))
        archiveDoor.run(.sequence([.wait(forDuration: 0.35), .run { [weak self] in self?.archiveDoor.glowWidth = 14 }]))
        archiveDoor.children.filter { $0.name == "dead_monitor" }.enumerated().forEach { index, node in
            node.run(.sequence([.wait(forDuration: Double(index) * 0.18), .fadeAlpha(to: 1, duration: 0.12), .fadeAlpha(to: 0.45, duration: 0.12), .fadeAlpha(to: 1, duration: 0.12)]))
        }
        monitorText.run(.sequence([.wait(forDuration: 0.6), .run { [weak self] in self?.monitorText.text = "ARCHIVE NODE DETECTED" }, .wait(forDuration: 0.7), .run { [weak self] in self?.monitorText.text = "HISTORY ACCESS: RESTRICTED" }]))
        novaNode.run(.repeat(.sequence([.colorize(with: .warningRed, colorBlendFactor: 1, duration: 0.05), .colorize(with: .glitchPurple, colorBlendFactor: 1, duration: 0.05), .colorize(with: .pastelCyan, colorBlendFactor: 1, duration: 0.08)]), count: 8))
        run(.sequence([.wait(forDuration: 0.9), .run { [weak self] in self?.showDialogue(speaker: "Raka", text: "You remember this place?") }, .wait(forDuration: 0.75), .run { [weak self] in self?.showDialogue(speaker: "NOVA", text: "I do not remember remembering it.") }, .wait(forDuration: 0.85), .run { [weak self] in self?.runTitleCard() }]), withKey: "beat")
    }

    private func runTitleCard() {
        beat = .titleCard
        print("Transition beat: titleCard")
        dialogueBox.run(.fadeOut(withDuration: 0.25))
        titleLayer.run(.fadeIn(withDuration: 0.6))
        titleLayer.childNode(withName: "chapter_title")?.run(.scale(to: 1, duration: 0.45))
        titleLayer.childNode(withName: "subtitle")?.run(.sequence([.wait(forDuration: 0.3), .fadeIn(withDuration: 0.35)]))
        titleLayer.childNode(withName: "nova_line")?.run(.sequence([.wait(forDuration: 0.55), .fadeIn(withDuration: 0.35)]))
        continueLabel.run(.repeatForever(.sequence([.fadeAlpha(to: 0.35, duration: 0.6), .fadeAlpha(to: 1, duration: 0.6)])))
        // TODO: play Chapter 3 title card chime
    }

    private func addSparks() {
        for index in 0..<5 {
            let spark = SKShapeNode(circleOfRadius: 4)
            spark.position = CGPoint(x: size.width * 0.78, y: size.height * CGFloat(0.58 - Double(index) * 0.06))
            spark.fillColor = .manualYellow
            spark.strokeColor = .clear
            spark.glowWidth = 8
            spark.zPosition = 12
            addChild(spark)
            spark.run(.sequence([.wait(forDuration: Double(index) * 0.14), .fadeIn(withDuration: 0.04), .moveBy(x: -24, y: -30, duration: 0.18), .fadeOut(withDuration: 0.08), .removeFromParent()]))
        }
    }

    private func showDialogue(speaker: String, text: String) {
        speakerLabel.text = speaker
        dialogueLabel.text = text
        dialogueBox.alpha = 1
        dialogueBox.run(.sequence([.scale(to: 1.03, duration: 0.08), .scale(to: 1, duration: 0.08)]))
    }

    private func completeTransitionIfNeeded() {
        guard !hasCompletedTransition else { return }
        hasCompletedTransition = true
        beat = .completed
        print("Chapter 2 to Chapter 3 transition completed")
        DispatchQueue.main.async {
            self.onTransitionCompleted?()
        }
    }

    private func makeLabel(_ text: String, size: CGFloat, color: SKColor) -> SKLabelNode {
        let label = SKLabelNode(text: text)
        label.fontName = "AvenirNext-Heavy"
        label.fontSize = size
        label.fontColor = color
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .center
        return label
    }
}
