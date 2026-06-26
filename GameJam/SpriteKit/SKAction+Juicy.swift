import SpriteKit

extension SKAction {
    static func smallBounce() -> SKAction {
        .sequence([
            .scale(to: 1.08, duration: 0.12),
            .scale(to: 0.96, duration: 0.08),
            .scale(to: 1.0, duration: 0.08)
        ])
    }
}
