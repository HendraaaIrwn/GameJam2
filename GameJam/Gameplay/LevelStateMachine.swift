final class LevelStateMachine {
    private(set) var state: LevelPlayState = .ready

    var canAcceptInput: Bool {
        state == .playing || state == .sequenceStarted
    }

    var canCheckTimeout: Bool {
        state == .playing || state == .sequenceStarted
    }

    var hasEnded: Bool {
        state == .completed || state == .failed
    }

    @discardableResult
    func transition(to newState: LevelPlayState) -> Bool {
        guard canTransition(to: newState) else { return false }
        state = newState
        return true
    }

    func reset() {
        state = .ready
    }

    private func canTransition(to newState: LevelPlayState) -> Bool {
        switch (state, newState) {
        case (.ready, .playing),
             (.playing, .sequenceStarted),
             (.playing, .successAnimating),
             (.playing, .failureAnimating),
             (.sequenceStarted, .successAnimating),
             (.sequenceStarted, .failureAnimating),
             (.successAnimating, .completed),
             (.failureAnimating, .failed):
            true
        default:
            false
        }
    }
}
