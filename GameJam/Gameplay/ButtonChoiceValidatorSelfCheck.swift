#if DEBUG
func runButtonChoiceValidatorSelfCheck() {
    var validator = ButtonChoiceValidator()
    validator.startLevel(at: 0)
    assert(validator.validateTap(button: .redManualOverride, time: 1) == .correctChoice(button: .redManualOverride))

    validator = ButtonChoiceValidator()
    validator.startLevel(at: 10)
    assert(validator.validateTap(button: .greenSafe, time: 11) == .wrongChoice(button: .greenSafe))
    assert(validator.validateTap(button: .blueAuto, time: 11) == .wrongChoice(button: .blueAuto))
    assert(validator.validateTap(button: .cyanOptimize, time: 11) == .wrongChoice(button: .cyanOptimize))
    assert(validator.validateTap(button: .door, time: 11) == .wrongChoice(button: .door))
    assert(validator.validateTap(button: .aiWallScreen, time: 11) == .wrongChoice(button: .aiWallScreen))
    assert(validator.validateTap(button: .empty, time: 11) == nil)

    validator = ButtonChoiceValidator()
    validator.startLevel(at: 20)
    assert(validator.checkTimeouts(currentTime: 24.1) == .noInputTimeout)

    validator = ButtonChoiceValidator()
    validator.startLevel(at: 30)
    assert(validator.checkTimeouts(currentTime: 38.1) == .totalTimeout)
}
#endif
