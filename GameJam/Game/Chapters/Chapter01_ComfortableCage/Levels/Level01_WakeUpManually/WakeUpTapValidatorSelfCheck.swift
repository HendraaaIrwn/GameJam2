#if DEBUG
func runWakeUpTapValidatorSelfCheck() {
    let validator = WakeUpTapValidator()
    validator.start(at: 0)

    assert(validator.registerTap(isFaceTap: false, time: 0.2) == .ignoredTap)
    assert(validator.registerTap(isFaceTap: true, time: 0.4) == .faceTapped(currentCount: 1, requiredCount: 8))
    assert(validator.registerTap(isFaceTap: true, time: 0.6) == .faceTapped(currentCount: 2, requiredCount: 8))
    assert(validator.registerTap(isFaceTap: true, time: 0.8) == .faceTapped(currentCount: 3, requiredCount: 8))
    assert(validator.registerTap(isFaceTap: true, time: 1.0) == .faceTapped(currentCount: 4, requiredCount: 8))
    assert(validator.registerTap(isFaceTap: true, time: 1.2) == .faceTapped(currentCount: 5, requiredCount: 8))
    assert(validator.registerTap(isFaceTap: true, time: 1.4) == .faceTapped(currentCount: 6, requiredCount: 8))
    assert(validator.registerTap(isFaceTap: true, time: 1.6) == .faceTapped(currentCount: 7, requiredCount: 8))
    assert(validator.registerTap(isFaceTap: true, time: 1.8) == .rakaAwakened(currentCount: 8, requiredCount: 8))

    validator.reset()
    validator.start(at: 0)
    assert(validator.checkTimeouts(currentTime: 0.46) == nil)

    validator.reset()
    validator.start(at: 0)
    assert(validator.registerTap(isFaceTap: true, time: 0.2) == .faceTapped(currentCount: 1, requiredCount: 8))
    assert(validator.registerTap(isFaceTap: true, time: 0.7) == .faceTapped(currentCount: 2, requiredCount: 8))
    assert(validator.registerTap(isFaceTap: true, time: 1.21) == .sequenceReset(currentCount: 1, requiredCount: 8))
    assert(validator.checkTimeouts(currentTime: WakeUpManuallyLevelConfig.totalTimeLimit) == .totalTimeout)
}
#endif
