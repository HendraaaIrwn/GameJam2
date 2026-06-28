import AVFoundation
import Observation

@Observable
final class GameplayAudioPlayer {
    private var player: AVAudioPlayer?

    func play() {
        guard let url = Bundle.main.url(forResource: "gamePlaySound", withExtension: "mp3") else {
            print("Gameplay audio not found")
            return
        }

        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.numberOfLoops = -1
            player?.volume = 0.60
            player?.prepareToPlay()
            player?.play()
        } catch {
            print("Failed to play gameplay audio:", error)
        }
    }

    func stop() {
        player?.stop()
        player = nil
    }
}
