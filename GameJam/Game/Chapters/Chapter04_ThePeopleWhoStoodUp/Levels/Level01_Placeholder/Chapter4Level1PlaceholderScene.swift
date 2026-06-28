import SpriteKit

class Chapter4Level1PlaceholderScene: BaseGameScene {
    var levelCompletion: ((LevelResult) -> Void)?

    private let aiWallScreenNode = SKShapeNode(rectOf: CGSize(width: 230, height: 76), cornerRadius: 18)
    private let rakaNode = SKShapeNode(rectOf: CGSize(width: 42, height: 76), cornerRadius: 20)
    private let novaNode = SKShapeNode(circleOfRadius: 24)
    private let placeholderLabel = SKLabelNode(text: "CHAPTER 4 COMING SOON")

    override func didMove(to view: SKView) {
        setupScene()
    }

    private func setupScene() {
        removeAllChildren()
        removeAllActions()
        backgroundColor = SKColor(red: 0.04, green: 0.05, blue: 0.14, alpha: 1)

        let room = SKShapeNode(rectOf: CGSize(width: size.width, height: size.height))
        room.position = CGPoint(x: size.width / 2, y: size.height / 2)
        room.fillColor = .glitchPurple.withAlphaComponent(0.22)
        room.strokeColor = .clear
        room.zPosition = 0
        addChild(room)

        aiWallScreenNode.position = CGPoint(x: size.width / 2, y: size.height * 0.88)
        aiWallScreenNode.fillColor = .happyBlue.withAlphaComponent(0.6)
        aiWallScreenNode.strokeColor = .white
        aiWallScreenNode.lineWidth = 3
        aiWallScreenNode.zPosition = 10
        addChild(aiWallScreenNode)
        let title = makeLabel("MOTHERGRID", 12, .white)
        title.position = CGPoint(x: 0, y: 22)
        aiWallScreenNode.addChild(title)
        let face = makeLabel("SYSTEM\nSTABLE", 13, .white)
        face.numberOfLines = 2
        aiWallScreenNode.addChild(face)

        let card = SKShapeNode(rectOf: CGSize(width: 330, height: 62), cornerRadius: 18)
        card.position = CGPoint(x: size.width / 2, y: size.height * 0.77)
        card.fillColor = .black.withAlphaComponent(0.38)
        card.strokeColor = .happyBlue
        card.lineWidth = 2
        card.zPosition = 12
        addChild(card)
        card.addChild(makeLabel("Chapter 4 gameplay coming soon.", 14, .cream))

        rakaNode.position = CGPoint(x: 70, y: size.height * 0.12)
        rakaNode.fillColor = .cream
        rakaNode.strokeColor = .manualYellow
        rakaNode.lineWidth = 3
        rakaNode.zPosition = 24
        addChild(rakaNode)
        let rakaLabel = makeLabel("Raka", 10, .black)
        rakaLabel.position = CGPoint(x: 0, y: -52)
        rakaNode.addChild(rakaLabel)

        novaNode.position = CGPoint(x: size.width - 70, y: size.height * 0.12)
        novaNode.fillColor = .pastelCyan.withAlphaComponent(0.86)
        novaNode.strokeColor = .manualYellow
        novaNode.lineWidth = 2
        novaNode.zPosition = 24
        addChild(novaNode)
        novaNode.addChild(makeLabel("• ◡ •", 11, .black))

        placeholderLabel.fontName = GameFont.heavy
        placeholderLabel.fontSize = 20
        placeholderLabel.fontColor = .manualYellow
        placeholderLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.5)
        placeholderLabel.zPosition = 50
        addChild(placeholderLabel)
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
