import AVFoundation
import Observation

@Observable
final class StorylineAudioPlayer {
    private var player: AVAudioPlayer?

    func play() {
        guard let url = Bundle.main.url(forResource: "backsoundStroyLine", withExtension: "mp3") else {
            print("Storyline audio not found")
            return
        }

        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.numberOfLoops = 0
            player?.volume = 0.75
            player?.prepareToPlay()
            player?.play()
            print("Storyline audio started")
        } catch {
            print("Failed to play storyline audio:", error)
        }
    }

    func stop() {
        player?.stop()
        player = nil
    }
}
