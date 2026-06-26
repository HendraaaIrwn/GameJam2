#if DEBUG
func runTapSequenceValidatorSelfCheck() {
    let validator = TapSequenceValidator()
    validator.start(at: 10)
    assert(validator.registerTap(zone: .body, time: 10.1) == .correctStep(progress: 1, total: 4))
    assert(validator.registerTap(zone: .head, time: 10.5) == .correctStep(progress: 2, total: 4))
    assert(validator.registerTap(zone: .body, time: 10.9) == .correctStep(progress: 3, total: 4))
    assert(validator.registerTap(zone: .wrist, time: 11.2) == .completed)

    validator.start(at: 20)
    assert(validator.checkTimeouts(currentTime: 23.1) == .noInputTimeout)

    validator.start(at: 30)
    assert(validator.registerTap(zone: .body, time: 30.1) == .correctStep(progress: 1, total: 4))
    assert(validator.checkTimeouts(currentTime: 31.6) == .gapTimeout)
}
#endif
