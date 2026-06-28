import SpriteKit

final class LevelTimerHUDNode: SKNode {
    private let width: CGFloat
    private let height: CGFloat
    private let titleLabel: SKLabelNode
    private let backgroundBar: SKShapeNode
    private let fillBar: SKShapeNode
    private let countdownLabel: SKLabelNode
    private var isWarningAnimationActive = false

    init(width: CGFloat, height: CGFloat) {
        self.width = width
        self.height = height
        titleLabel = SKLabelNode(text: "TIME LEFT")
        backgroundBar = SKShapeNode(rectOf: CGSize(width: width, height: height), cornerRadius: height / 2)
        fillBar = SKShapeNode(rectOf: CGSize(width: width, height: height), cornerRadius: height / 2)
        countdownLabel = SKLabelNode(text: "")
        super.init()
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(with state: LevelTimerState) {
        let fillWidth = max(width * state.progress, 1)
        fillBar.path = CGPath(roundedRect: CGRect(x: -width / 2, y: -height / 2, width: fillWidth, height: height), cornerWidth: height / 2, cornerHeight: height / 2, transform: nil)
        fillBar.fillColor = state.isWarning ? .appDanger : .appMintGreen
        countdownLabel.text = formatRemainingTime(state.remaining)
        countdownLabel.fontColor = state.isWarning ? .appDanger : .appGlitchPurple

        if state.isWarning {
            startWarningAnimation()
        } else {
            stopWarningAnimation()
        }
    }

    func reset() {
        update(with: LevelTimerState(elapsed: 0, remaining: 0, progress: 1, hasExpired: false, isWarning: false))
        stopWarningAnimation()
    }

    private func setup() {
        zPosition = 1000

        titleLabel.fontName = GameFont.heavy
        titleLabel.fontSize = 12
        titleLabel.fontColor = .appGlitchPurple
        titleLabel.horizontalAlignmentMode = .left
        titleLabel.verticalAlignmentMode = .center
        titleLabel.position = CGPoint(x: -width / 2, y: 20)
        titleLabel.zPosition = 2
//        addChild(titleLabel)

        countdownLabel.fontName = GameFont.heavy
        countdownLabel.fontSize = 16
        countdownLabel.fontColor = .appGlitchPurple
        countdownLabel.horizontalAlignmentMode = .right
        countdownLabel.verticalAlignmentMode = .center
        countdownLabel.position = CGPoint(x: width / 2, y: 20)
        countdownLabel.zPosition = 2
        addChild(countdownLabel)

        backgroundBar.fillColor = .appSurfaceSecondary.withAlphaComponent(0.45)
        backgroundBar.strokeColor = .appBorderSoft
        backgroundBar.lineWidth = 2
        backgroundBar.position = .zero
        addChild(backgroundBar)

        fillBar.path = CGPath(roundedRect: CGRect(x: -width / 2, y: -height / 2, width: width, height: height), cornerWidth: height / 2, cornerHeight: height / 2, transform: nil)
        fillBar.fillColor = .appMintGreen
        fillBar.strokeColor = .clear
        fillBar.zPosition = 1
        addChild(fillBar)
    }

    private func formatRemainingTime(_ remaining: TimeInterval) -> String {
        String(format: "%.1fs", max(remaining, 0))
    }

    private func startWarningAnimation() {
        guard !isWarningAnimationActive else { return }
        isWarningAnimationActive = true
        print("Timer warning started")
        countdownLabel.run(.repeatForever(.sequence([.scale(to: 1.12, duration: 0.18), .scale(to: 1.0, duration: 0.18)])), withKey: "timerWarningPulse")
    }

    private func stopWarningAnimation() {
        guard isWarningAnimationActive else { return }
        isWarningAnimationActive = false
        countdownLabel.removeAction(forKey: "timerWarningPulse")
        countdownLabel.setScale(1)
    }
}
