#if DEBUG
func runManualKeySearchValidatorSelfCheck() {
    var validator = ManualKeySearchValidator()
    validator.startLevel(at: 0)
    assert(validator.checkTimeouts(currentTime: 4.9) == nil)
    assert(validator.checkTimeouts(currentTime: 5.0) == .noInputTimeout)

    validator = ManualKeySearchValidator()
    validator.startLevel(at: 0)
    _ = validator.validateTap(target: .brokenCable, time: 1.0)
    assert(validator.checkTimeouts(currentTime: 5.0) == nil)
    assert(validator.checkTimeouts(currentTime: 6.1) == .noInputTimeout)

    validator = ManualKeySearchValidator()
    validator.startLevel(at: 0)
    assert(validator.validateTap(target: .manualKey, time: 1.0) == .manualKeySelected)
    assert(validator.validateTap(target: .smartKey, time: 2.0) == .smartKeySelected)

    validator = ManualKeySearchValidator()
    validator.startLevel(at: 0)
    assert(validator.validateTap(target: .brokenCable, time: 1.0) == .distractionSelected(target: .brokenCable))
    assert(validator.validateTap(target: .oldPhoto, time: 1.0) == .distractionSelected(target: .oldPhoto))
    assert(validator.validateTap(target: .redChip, time: 1.0) == .distractionSelected(target: .redChip))
    assert(validator.validateTap(target: .toyDoll, time: 1.0) == .distractionSelected(target: .toyDoll))
    assert(validator.validateTap(target: .table, time: 1.0) == .distractionSelected(target: .table))

    validator = ManualKeySearchValidator()
    validator.startLevel(at: 0)
    assert(validator.validateTap(target: .blueKeyHintButton, time: 1.0) == .trapSelected(target: .blueKeyHintButton))
    assert(validator.validateTap(target: .aiWallScreen, time: 1.0) == .trapSelected(target: .aiWallScreen))

    validator = ManualKeySearchValidator()
    validator.startLevel(at: 0)
    assert(validator.validateTap(target: .empty, time: 1.0) == nil)

    validator = ManualKeySearchValidator()
    validator.startLevel(at: 0)
    assert(validator.checkTimeouts(currentTime: 12.0) == .totalTimeout)
}
#endif
