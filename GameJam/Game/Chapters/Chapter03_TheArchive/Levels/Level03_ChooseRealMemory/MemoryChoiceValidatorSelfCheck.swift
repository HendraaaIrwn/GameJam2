#if DEBUG
func runMemoryChoiceValidatorSelfCheck() {
    let validator = MemoryChoiceValidator()
    validator.startLevel(at: 0)
    assert(validator.validateTap(target: .rawMemory, time: 0.1) == .correctMemorySelected(target: .rawMemory))
    assert(validator.validateTap(target: .correctedMemory, time: 0.2) == .wrongMemorySelected(target: .correctedMemory))
    assert(validator.validateTap(target: .optimizedMemory, time: 0.3) == .wrongMemorySelected(target: .optimizedMemory))
    assert(validator.validateTap(target: .aiApprovedOverlay, time: 0.4) == .wrongMemorySelected(target: .aiApprovedOverlay))
    assert(validator.validateTap(target: .selectCorrectedButton, time: 0.5) == .wrongMemorySelected(target: .selectCorrectedButton))
    assert(validator.validateTap(target: .aiWallScreen, time: 0.6) == .wrongMemorySelected(target: .aiWallScreen))
    assert(validator.validateTap(target: .raka, time: 0.7) == .ignoredTarget(target: .raka))
    assert(validator.validateTap(target: .nova, time: 0.8) == .ignoredTarget(target: .nova))
    assert(validator.validateTap(target: .empty, time: 0.9) == nil)

    let noInput = MemoryChoiceValidator()
    noInput.startLevel(at: 0)
    assert(noInput.checkTimeouts(currentTime: 4.1) == .noInputTimeout)

    let total = MemoryChoiceValidator()
    total.startLevel(at: 0)
    _ = total.validateTap(target: .raka, time: 0.1)
    assert(total.checkTimeouts(currentTime: 8.1) == .totalTimeout)

    validator.reset()
    assert(!validator.hasReceivedInput)
}
#endif
