import SpriteKit

class BaseGameScene: SKScene {
    func playTapSound() {
        run(SKAction.playSoundFileNamed("tapSound.mp3", waitForCompletion: false))
    }
}
