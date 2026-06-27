#if DEBUG
func runManualKeySearchValidatorSelfCheck() {
    var validator = ManualKeySearchValidator()
    validator.startLevel(at: 0)
    assert(validator.checkTimeouts(currentTime: 5.1) == .noInputTimeout)

    validator = ManualKeySearchValidator()
    validator.startLevel(at: 0)
    assert(validator.recordDrag(at: 4.9, didRevealManualKey: false) == .searching)
    assert(validator.checkTimeouts(currentTime: 5.1) == nil)

    validator = ManualKeySearchValidator()
    validator.startLevel(at: 0)
    assert(validator.recordDrag(at: 1, didRevealManualKey: true) == .manualKeyRevealed)
    assert(validator.select(choice: .manualKey, at: 2) == .correctKeySelected)

    validator = ManualKeySearchValidator()
    validator.startLevel(at: 0)
    assert(validator.select(choice: .manualKey, at: 1) == .manualKeyTappedBeforeReveal)
    assert(validator.select(choice: .aiKey, at: 1) == .wrongKeySelected(choice: .aiKey))
    assert(validator.select(choice: .fakeKey, at: 1) == .wrongKeySelected(choice: .fakeKey))
    assert(validator.select(choice: .aiWallScreen, at: 1) == .wrongKeySelected(choice: .aiWallScreen))
    assert(validator.select(choice: .aiSuggestionButton, at: 1) == .wrongKeySelected(choice: .aiSuggestionButton))

    validator = ManualKeySearchValidator()
    validator.startLevel(at: 0)
    assert(validator.checkTimeouts(currentTime: 12.1) == .totalTimeout)
}
#endif
