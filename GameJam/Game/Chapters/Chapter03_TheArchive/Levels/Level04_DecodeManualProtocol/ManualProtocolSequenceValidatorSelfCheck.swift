#if DEBUG
func runManualProtocolSequenceValidatorSelfCheck() {
    let validator = ManualProtocolSequenceValidator()
    validator.startLevel(at: 0)
    assert(validator.validateTap(target: .manualSymbol, symbol: .hand, time: 0.1) == .correctSymbolSelected(symbol: .hand, currentIndex: 1, requiredCount: 4))
    assert(validator.validateTap(target: .manualSymbol, symbol: .eye, time: 0.2) == .correctSymbolSelected(symbol: .eye, currentIndex: 2, requiredCount: 4))
    assert(validator.validateTap(target: .manualSymbol, symbol: .door, time: 0.3) == .correctSymbolSelected(symbol: .door, currentIndex: 3, requiredCount: 4))
    assert(validator.validateTap(target: .manualSymbol, symbol: .spark, time: 0.4) == .manualProtocolDecoded)

    let wrong = ManualProtocolSequenceValidator()
    wrong.startLevel(at: 0)
    assert(wrong.validateTap(target: .manualSymbol, symbol: .eye, time: 0.1) == .wrongSymbolSelected(symbol: .eye, expected: .hand))

    let ai = ManualProtocolSequenceValidator()
    ai.startLevel(at: 0)
    assert(ai.validateTap(target: .aiSymbol, symbol: .gear, time: 0.1) == .aiSymbolSelected(symbol: .gear))
    assert(ai.validateTap(target: .autoDecodeButton, symbol: nil, time: 0.2) == .trapSelected(target: .autoDecodeButton))
    assert(ai.validateTap(target: .useHighlightedButton, symbol: nil, time: 0.3) == .trapSelected(target: .useHighlightedButton))
    assert(ai.validateTap(target: .aiWallScreen, symbol: nil, time: 0.4) == .trapSelected(target: .aiWallScreen))
    assert(ai.validateTap(target: .raka, symbol: nil, time: 0.5) == .ignoredTarget(target: .raka))
    assert(ai.validateTap(target: .nova, symbol: nil, time: 0.6) == .ignoredTarget(target: .nova))
    assert(ai.validateTap(target: .empty, symbol: nil, time: 0.7) == nil)

    let noInput = ManualProtocolSequenceValidator()
    noInput.startLevel(at: 0)
    assert(noInput.checkTimeouts(currentTime: 4.1) == .noInputTimeout)

    let total = ManualProtocolSequenceValidator()
    total.startLevel(at: 0)
    _ = total.validateTap(target: .raka, symbol: nil, time: 0.1)
    assert(total.checkTimeouts(currentTime: 10.1) == .totalTimeout)

    validator.reset()
    assert(!validator.hasReceivedInput)
    assert(validator.currentSequenceIndex == 0)
}
#endif
