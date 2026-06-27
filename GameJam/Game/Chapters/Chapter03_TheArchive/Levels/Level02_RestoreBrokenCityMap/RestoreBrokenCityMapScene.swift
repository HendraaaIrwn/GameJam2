import SpriteKit

final class RestoreBrokenCityMapScene: SKScene {
    var levelCompletion: ((LevelResult) -> Void)?

    private let stateMachine = LevelStateMachine()
    private let validator = BrokenCityMapValidator()
    private let timer = LevelTimerController(totalDuration: RestoreBrokenCityMapLevelConfig.totalTimeLimit)
    private let timerHUD = LevelTimerHUDNode(width: 300, height: 14)

    private let aiWallScreenNode = SKShapeNode(rectOf: CGSize(width: 156, height: 76), cornerRadius: 22)
    private let aiFaceLabel = SKLabelNode(text: "◡")
    private let oldMapBoardNode = SKShapeNode(rectOf: CGSize(width: 238, height: 240), cornerRadius: 22)
    private let updatedCityMapNode = SKShapeNode(rectOf: CGSize(width: 132, height: 154), cornerRadius: 18)
    private let blueAIMapNode = SKShapeNode(rectOf: CGSize(width: 146, height: 172), cornerRadius: 20)
    private let useUpdatedMapButtonNode = SKShapeNode(rectOf: CGSize(width: 154, height: 42), cornerRadius: 17)
    private let aiOverlayNode = SKShapeNode(rectOf: CGSize(width: 238, height: 240), cornerRadius: 22)
    private let currentVersionLabel = SKLabelNode(text: "CURRENT VERSION ONLY")
    private let feedbackLabel = SKLabelNode(text: "")
    private let novaNode = SKShapeNode(circleOfRadius: 18)
    private let mapLineLayer = SKNode()

    private var fragmentNodes: [CityMapFragmentType: SKShapeNode] = [:]
    private var outlineNodes: [CityMapFragmentType: SKShapeNode] = [:]
    private var fragmentStartPositions: [CityMapFragmentType: CGPoint] = [:]
    private var outlinePositions: [CityMapFragmentType: CGPoint] = [:]
    private var placedFragments = Set<CityMapFragmentType>()
    private var draggingFragmentNode: SKNode?
    private var draggingFragmentType: CityMapFragmentType?
    private var dragOffset = CGPoint.zero
    private var currentSceneTime: TimeInterval = 0
    private var hasSentResult = false

    override func didMove(to view: SKView) {
        setupScene()
        print("RestoreBrokenCityMapScene didMove")
    }

    override func update(_ currentTime: TimeInterval) {
        currentSceneTime = currentTime
        if !timer.hasStarted {
            timer.start(at: currentTime)
            validator.startLevel(at: currentTime)
            stateMachine.transition(to: .playing)
            print("Chapter 3 Level 2 timer started")
            return
        }

        timerHUD.update(with: timer.update(currentTime: currentTime))
        guard stateMachine.canCheckTimeout, !hasSentResult else { return }
        if let result = validator.checkTimeouts(currentTime: currentTime) {
            handleValidation(result)
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard stateMachine.canAcceptInput, let touchPoint = touches.first?.location(in: self) else { return }
        let target = cityMapTarget(at: touchPoint)
        let fragmentType = fragmentType(at: touchPoint)
        print("Tapped target:", target.rawValue)

        if let result = validator.validateTap(target: target, time: currentSceneTime) {
            print("Broken city map validation result:", result)
            handleValidation(result)
            return
        }

        guard let fragmentType, let fragmentNode = fragmentNodes[fragmentType], !placedFragments.contains(fragmentType) else { return }
        if let result = validator.beginDrag(target: target, fragmentType: fragmentType, startPoint: touchPoint, time: currentSceneTime) {
            draggingFragmentNode = fragmentNode
            draggingFragmentType = fragmentType
            dragOffset = CGPoint(x: fragmentNode.position.x - touchPoint.x, y: fragmentNode.position.y - touchPoint.y)
            fragmentNode.zPosition = 500
            stateMachine.transition(to: .sequenceStarted)
            print("Fragment drag started:", fragmentType)
            handleValidation(result)
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard stateMachine.canAcceptInput, let touchPoint = touches.first?.location(in: self), let fragmentNode = draggingFragmentNode, let fragmentType = draggingFragmentType else { return }
        fragmentNode.position = CGPoint(x: touchPoint.x + dragOffset.x, y: touchPoint.y + dragOffset.y)
        print("Dragging fragment:", fragmentType, "position:", fragmentNode.position)
        updateOutlineHighlight(for: fragmentType, position: fragmentNode.position)
        if blueAIMapNode.containsScenePoint(fragmentNode.position) {
            blueAIMapNode.run(.sequence([.scale(to: 1.04, duration: 0.06), .scale(to: 1, duration: 0.06)]))
        }
        handleValidation(validator.updateDrag(fragmentType: fragmentType, currentPoint: fragmentNode.position, time: currentSceneTime))
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
        backgroundColor = SKColor(red: 0.05, green: 0.07, blue: 0.17, alpha: 1)
        stateMachine.reset()
        validator.reset()
        timer.reset()
        hasSentResult = false
        placedFragments.removeAll()
        fragmentNodes.removeAll()
        outlineNodes.removeAll()
        fragmentStartPositions.removeAll()
        outlinePositions.removeAll()

        addArchiveBackground()
        addAISide()
        addOldMapBoard()
        addCharacters()
        addFragments()
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
            let shelf = SKShapeNode(rectOf: CGSize(width: size.width * 0.9, height: 18), cornerRadius: 9)
            shelf.position = CGPoint(x: size.width / 2, y: size.height * CGFloat(0.28 + Double(index) * 0.1))
            shelf.fillColor = .cream.withAlphaComponent(0.14)
            shelf.strokeColor = .clear
            shelf.zPosition = 1
            addChild(shelf)
        }
    }

    private func addAISide() {
        aiWallScreenNode.name = "ai_wall_screen"
        aiWallScreenNode.position = CGPoint(x: size.width / 2, y: size.height * 0.86)
        aiWallScreenNode.fillColor = .happyBlue.withAlphaComponent(0.58)
        aiWallScreenNode.strokeColor = .white
        aiWallScreenNode.lineWidth = 3
        aiWallScreenNode.zPosition = 10
        addChild(aiWallScreenNode)
        let name = makeLabel("MOTHERGRID", 12, .white)
        name.position = CGPoint(x: 0, y: 21)
        aiWallScreenNode.addChild(name)
        aiFaceLabel.fontName = "AvenirNext-Heavy"
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
        commandCard.addChild(makeLabel(RestoreBrokenCityMapLevelConfig.command, 17, .happyBlue))

        blueAIMapNode.name = "blue_ai_map"
        blueAIMapNode.position = CGPoint(x: size.width * 0.79, y: size.height * 0.54)
        blueAIMapNode.fillColor = .happyBlue.withAlphaComponent(0.45)
        blueAIMapNode.strokeColor = .white
        blueAIMapNode.lineWidth = 3
        blueAIMapNode.glowWidth = 9
        blueAIMapNode.zPosition = 8
        addChild(blueAIMapNode)

        updatedCityMapNode.name = "updated_city_map"
        updatedCityMapNode.fillColor = .pastelCyan.withAlphaComponent(0.88)
        updatedCityMapNode.strokeColor = .happyBlue
        updatedCityMapNode.lineWidth = 3
        updatedCityMapNode.zPosition = 1
        blueAIMapNode.addChild(updatedCityMapNode)
        updatedCityMapNode.addChild(makeLabel("UPDATED MAP\nCURRENT VERSION", 11, .happyBlue))
        addBlueRoutes(to: updatedCityMapNode)

        useUpdatedMapButtonNode.name = "use_updated_map_button"
        useUpdatedMapButtonNode.position = CGPoint(x: size.width * 0.79, y: size.height * 0.38)
        useUpdatedMapButtonNode.fillColor = .happyBlue
        useUpdatedMapButtonNode.strokeColor = .white
        useUpdatedMapButtonNode.lineWidth = 3
        useUpdatedMapButtonNode.zPosition = 10
        addChild(useUpdatedMapButtonNode)
        useUpdatedMapButtonNode.addChild(makeLabel("USE UPDATED MAP", 12, .white))
    }

    private func addBlueRoutes(to node: SKNode) {
        for offset in [-34, 0, 34] as [CGFloat] {
            let route = SKShapeNode(rectOf: CGSize(width: 92, height: 5), cornerRadius: 3)
            route.position = CGPoint(x: 0, y: offset)
            route.zRotation = offset == 0 ? 0.35 : -0.2
            route.fillColor = .happyBlue
            route.strokeColor = .clear
            route.glowWidth = 5
            node.addChild(route)
        }
    }

    private func addOldMapBoard() {
        oldMapBoardNode.name = "old_broken_map"
        oldMapBoardNode.position = CGPoint(x: size.width * 0.38, y: size.height * 0.5)
        oldMapBoardNode.fillColor = .cream.withAlphaComponent(0.78)
        oldMapBoardNode.strokeColor = .manualYellow
        oldMapBoardNode.lineWidth = 4
        oldMapBoardNode.zPosition = 5
        addChild(oldMapBoardNode)
        let title = makeLabel("OLD EDEN LOOP MAP", 13, .glitchPurple)
        title.position = CGPoint(x: 0, y: 96)
        oldMapBoardNode.addChild(title)

        mapLineLayer.zPosition = 7
        addChild(mapLineLayer)

        addOutline(type: .residentialZone, position: CGPoint(x: size.width * 0.25, y: size.height * 0.53), label: "RES")
        addOutline(type: .transitArchive, position: CGPoint(x: size.width * 0.42, y: size.height * 0.56), label: "TRANSIT")
        addOutline(type: .manualDistrict, position: CGPoint(x: size.width * 0.36, y: size.height * 0.43), label: "MANUAL")

        aiOverlayNode.fillColor = .happyBlue.withAlphaComponent(0.0)
        aiOverlayNode.strokeColor = .clear
        aiOverlayNode.position = oldMapBoardNode.position
        aiOverlayNode.zPosition = 15
        addChild(aiOverlayNode)

        currentVersionLabel.fontName = "AvenirNext-Heavy"
        currentVersionLabel.fontSize = 17
        currentVersionLabel.fontColor = .white
        currentVersionLabel.alpha = 0
        currentVersionLabel.position = oldMapBoardNode.position
        currentVersionLabel.zPosition = 16
        addChild(currentVersionLabel)
    }

    private func addOutline(type: CityMapFragmentType, position: CGPoint, label: String) {
        let outline = SKShapeNode(rectOf: CGSize(width: 78, height: 58), cornerRadius: 12)
        outline.position = position
        outline.fillColor = .clear
        outline.strokeColor = .manualYellow
        outline.lineWidth = 3
        outline.alpha = 0.45
        outline.name = outlineName(for: type)
        outline.zPosition = 6
        addChild(outline)
        outline.addChild(makeLabel(label, 10, .manualYellow))
        outlineNodes[type] = outline
        outlinePositions[type] = position
    }

    private func addCharacters() {
        let raka = SKShapeNode(rectOf: CGSize(width: 50, height: 72), cornerRadius: 24)
        raka.position = CGPoint(x: size.width * 0.15, y: size.height * 0.22)
        raka.fillColor = .happyBlue
        raka.strokeColor = .white
        raka.lineWidth = 3
        raka.zPosition = 9
        addChild(raka)
        for x in [-8, 8] as [CGFloat] {
            let eye = SKShapeNode(circleOfRadius: 3)
            eye.position = CGPoint(x: x, y: 12)
            eye.fillColor = .black
            eye.strokeColor = .clear
            raka.addChild(eye)
        }
        let wrist = SKShapeNode(circleOfRadius: 7)
        wrist.position = CGPoint(x: 25, y: -4)
        wrist.fillColor = .manualYellow
        wrist.strokeColor = .clear
        wrist.glowWidth = 8
        raka.addChild(wrist)

        novaNode.position = CGPoint(x: size.width * 0.25, y: size.height * 0.25)
        novaNode.fillColor = .pastelCyan
        novaNode.strokeColor = .manualYellow
        novaNode.lineWidth = 3
        novaNode.glowWidth = 8
        novaNode.zPosition = 9
        addChild(novaNode)
        novaNode.addChild(makeLabel("• •", 10, .glitchPurple))
        novaNode.run(.repeatForever(.sequence([.moveBy(x: 0, y: 7, duration: 0.65), .moveBy(x: 0, y: -7, duration: 0.65)])))
    }

    private func addFragments() {
        addFragment(type: .residentialZone, position: CGPoint(x: size.width * 0.22, y: size.height * 0.28), color: .mint, label: "RES\n⌂")
        addFragment(type: .transitArchive, position: CGPoint(x: size.width * 0.5, y: size.height * 0.27), color: .glitchPurple.withAlphaComponent(0.9), label: "TRANSIT\n⇄")
        addFragment(type: .manualDistrict, position: CGPoint(x: size.width * 0.73, y: size.height * 0.26), color: .manualYellow, label: "MANUAL\n✦")
    }

    private func addFragment(type: CityMapFragmentType, position: CGPoint, color: SKColor, label: String) {
        let fragment = SKShapeNode(rectOf: CGSize(width: 74, height: 56), cornerRadius: 14)
        fragment.name = fragmentName(for: type)
        fragment.position = position
        fragment.fillColor = color
        fragment.strokeColor = .cream
        fragment.lineWidth = 3
        fragment.zPosition = 20
        addChild(fragment)
        let fragmentLabel = makeLabel(label, 11, type == .manualDistrict ? .glitchPurple : .white)
        fragment.addChild(fragmentLabel)

        let hitbox = SKShapeNode(rectOf: CGSize(width: 82, height: 64), cornerRadius: 16)
        hitbox.name = fragment.name
        hitbox.fillColor = .clear
        hitbox.strokeColor = .clear
        fragment.addChild(hitbox)

        fragmentNodes[type] = fragment
        fragmentStartPositions[type] = position
    }

    private func addFeedbackAndTimer() {
        feedbackLabel.fontName = "AvenirNext-Heavy"
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

    private func finishDrag() {
        guard stateMachine.canAcceptInput, let fragmentNode = draggingFragmentNode, let fragmentType = draggingFragmentType, let outlinePosition = outlinePositions[fragmentType] else { return }
        print("Fragment released:", fragmentType)
        print("Distance to correct outline:", fragmentNode.position.distance(to: outlinePosition))
        let result = validator.endDrag(fragmentType: fragmentType, endPoint: fragmentNode.position, correctOutlinePoint: outlinePosition, blueAIMapNode: blueAIMapNode, time: currentSceneTime)
        handleValidation(result)
        draggingFragmentNode = nil
        draggingFragmentType = nil
        resetOutlineHighlights()
    }

    private func handleValidation(_ result: BrokenCityMapValidationResult) {
        switch result {
        case .fragmentDragStarted:
            break
        case .fragmentDragging:
            break
        case let .fragmentPlacedCorrectly(type, placedCount, requiredCount):
            placeFragment(type)
            print("Fragment placed correctly:", type)
            print("Placed fragments:", placedCount, "/", requiredCount)
        case .allFragmentsRestored:
            if let type = draggingFragmentType {
                placeFragment(type)
                print("Fragment placed correctly:", type)
            }
            print("Placed fragments:", RestoreBrokenCityMapLevelConfig.requiredFragments, "/", RestoreBrokenCityMapLevelConfig.requiredFragments)
            triggerSuccess()
        case let .wrongOldMapPlacement(type):
            resetFragment(type)
        case let .droppedOnAIMap(type):
            triggerFailure(message: RestoreBrokenCityMapLevelConfig.failureMessage, reason: "droppedOnAIMap_\(type.rawValue)")
        case let .trapSelected(target):
            triggerFailure(message: RestoreBrokenCityMapLevelConfig.failureMessage, reason: "\(target.rawValue)Selected")
        case .noInputTimeout:
            triggerFailure(message: "Compliance Detected.", reason: "noInputTimeout")
        case .totalTimeout:
            triggerFailure(message: "Compliance Detected.", reason: "totalTimeout")
        }
    }

    private func placeFragment(_ type: CityMapFragmentType) {
        guard let fragmentNode = fragmentNodes[type], let outlinePosition = outlinePositions[type] else { return }
        placedFragments.insert(type)
        fragmentNode.run(.move(to: outlinePosition, duration: 0.15))
        fragmentNode.zPosition = 300
        outlineNodes[type]?.alpha = 1
        outlineNodes[type]?.glowWidth = 8
    }

    private func resetFragment(_ type: CityMapFragmentType) {
        guard let fragmentNode = fragmentNodes[type], let startPosition = fragmentStartPositions[type] else { return }
        fragmentNode.zPosition = 20
        fragmentNode.run(.move(to: startPosition, duration: 0.18))
        feedbackLabel.text = "That piece belongs elsewhere."
    }

    private func triggerSuccess() {
        guard !hasSentResult, stateMachine.transition(to: .successAnimating) else { return }
        hasSentResult = true
        print("All map fragments restored")
        print("Trigger Chapter 3 Level 2 success")
        feedbackLabel.text = RestoreBrokenCityMapLevelConfig.successMessage
        drawManualDistrictLines()
        updatedCityMapNode.run(.repeat(.sequence([.colorize(with: .warningRed, colorBlendFactor: 1, duration: 0.08), .colorize(with: .glitchPurple, colorBlendFactor: 1, duration: 0.08)]), count: 4))
        aiWallScreenNode.run(.repeat(.sequence([.colorize(with: .warningRed, colorBlendFactor: 1, duration: 0.08), .colorize(with: .glitchPurple, colorBlendFactor: 1, duration: 0.08)]), count: 4))
        novaNode.run(.repeat(.sequence([.colorize(with: .manualYellow, colorBlendFactor: 1, duration: 0.08), .colorize(with: .pastelCyan, colorBlendFactor: 1, duration: 0.08)]), count: 5))
        run(.wait(forDuration: 0.8)) { [weak self] in
            self?.stateMachine.transition(to: .completed)
            self?.levelCompletion?(LevelResult(levelId: RestoreBrokenCityMapLevelConfig.levelId, didSucceed: true, obedienceDelta: RestoreBrokenCityMapLevelConfig.successObedienceDelta, humanityDelta: RestoreBrokenCityMapLevelConfig.successHumanityDelta, message: RestoreBrokenCityMapLevelConfig.successMessage))
        }
    }

    private func triggerFailure(message: String, reason: String) {
        guard !hasSentResult, stateMachine.transition(to: .failureAnimating) else { return }
        hasSentResult = true
        print("Trigger Chapter 3 Level 2 failure:", reason)
        feedbackLabel.text = message
        aiFaceLabel.text = "◠"
        blueAIMapNode.run(.scale(to: 1.12, duration: 0.2))
        aiOverlayNode.fillColor = .happyBlue.withAlphaComponent(0.0)
        aiOverlayNode.run(.fadeAlpha(to: 0.72, duration: 0.25))
        currentVersionLabel.run(.fadeIn(withDuration: 0.25))
        fragmentNodes.values.forEach { $0.run(.fadeAlpha(to: 0.16, duration: 0.25)) }
        run(.wait(forDuration: 0.7)) { [weak self] in
            self?.stateMachine.transition(to: .failed)
            self?.levelCompletion?(LevelResult(levelId: RestoreBrokenCityMapLevelConfig.levelId, didSucceed: false, obedienceDelta: RestoreBrokenCityMapLevelConfig.failureObedienceDelta, humanityDelta: RestoreBrokenCityMapLevelConfig.failureHumanityDelta, message: message))
        }
    }

    private func drawManualDistrictLines() {
        let points = CityMapFragmentType.allCases.compactMap { outlinePositions[$0] }
        guard points.count == 3 else { return }
        for index in 0..<(points.count - 1) {
            let path = CGMutablePath()
            path.move(to: points[index])
            path.addLine(to: points[index + 1])
            let line = SKShapeNode(path: path)
            line.strokeColor = .manualYellow
            line.lineWidth = 5
            line.glowWidth = 8
            line.zPosition = 301
            mapLineLayer.addChild(line)
        }
        let district = makeLabel("MANUAL DISTRICT", 14, .manualYellow)
        district.position = CGPoint(x: size.width * 0.39, y: size.height * 0.36)
        district.zPosition = 302
        mapLineLayer.addChild(district)
    }

    private func updateOutlineHighlight(for fragmentType: CityMapFragmentType, position: CGPoint) {
        guard let outlineNode = outlineNodes[fragmentType] else { return }
        let shouldHighlight = position.distance(to: outlineNode.position) <= 70
        outlineNode.run(.fadeAlpha(to: shouldHighlight ? 1.0 : 0.45, duration: 0.08))
    }

    private func resetOutlineHighlights() {
        for (type, node) in outlineNodes where !placedFragments.contains(type) {
            node.run(.fadeAlpha(to: 0.45, duration: 0.08))
        }
    }

    private func cityMapTarget(at point: CGPoint) -> CityMapTarget {
        for node in nodes(at: point) {
            let target = cityMapTarget(from: node)
            if target != .empty { return target }
        }
        return .empty
    }

    private func cityMapTarget(from node: SKNode?) -> CityMapTarget {
        var current = node
        while let node = current {
            switch node.name {
            case "fragment_residential_zone", "fragment_transit_archive", "fragment_manual_district": return .mapFragment
            case "outline_residential_zone": return .residentialOutline
            case "outline_transit_archive": return .transitArchiveOutline
            case "outline_manual_district": return .manualDistrictOutline
            case "old_broken_map": return .oldBrokenMap
            case "updated_city_map": return .updatedCityMap
            case "blue_ai_map": return .blueAIMap
            case "use_updated_map_button": return .useUpdatedMapButton
            case "ai_wall_screen": return .aiWallScreen
            default: current = node.parent
            }
        }
        return .empty
    }

    private func fragmentType(at point: CGPoint) -> CityMapFragmentType? {
        for node in nodes(at: point) {
            if let type = fragmentType(from: node) { return type }
        }
        return nil
    }

    private func fragmentType(from node: SKNode?) -> CityMapFragmentType? {
        var current = node
        while let node = current {
            switch node.name {
            case "fragment_residential_zone": return .residentialZone
            case "fragment_transit_archive": return .transitArchive
            case "fragment_manual_district": return .manualDistrict
            default: current = node.parent
            }
        }
        return nil
    }

    private func fragmentName(for type: CityMapFragmentType) -> String {
        switch type {
        case .residentialZone: return "fragment_residential_zone"
        case .transitArchive: return "fragment_transit_archive"
        case .manualDistrict: return "fragment_manual_district"
        }
    }

    private func outlineName(for type: CityMapFragmentType) -> String {
        switch type {
        case .residentialZone: return "outline_residential_zone"
        case .transitArchive: return "outline_transit_archive"
        case .manualDistrict: return "outline_manual_district"
        }
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

private extension SKNode {
    func containsScenePoint(_ point: CGPoint) -> Bool {
        guard let scene else { return contains(point) }
        let localPoint = parent?.convert(point, from: scene) ?? point
        return contains(localPoint)
    }
}
