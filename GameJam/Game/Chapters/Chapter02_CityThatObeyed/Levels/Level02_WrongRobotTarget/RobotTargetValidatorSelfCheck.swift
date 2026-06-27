#if DEBUG
func runRobotTargetValidatorSelfCheck() {
    var validator = RobotTargetValidator()
    validator.startLevel(at: 0)
    assert(validator.validateTap(target: .surveillanceDrone, time: 1) == .correctTarget(target: .surveillanceDrone))

    validator = RobotTargetValidator()
    validator.startLevel(at: 10)
    assert(validator.validateTap(target: .wheeledHelperRobot, time: 11) == .wrongTarget(target: .wheeledHelperRobot))
    assert(validator.validateTap(target: .passiveCitizen, time: 11) == .wrongTarget(target: .passiveCitizen))
    assert(validator.validateTap(target: .cleaningRobot, time: 11) == .wrongTarget(target: .cleaningRobot))
    assert(validator.validateTap(target: .aiApprovedRobot, time: 11) == .wrongTarget(target: .aiApprovedRobot))
    assert(validator.validateTap(target: .aiWallScreen, time: 11) == .wrongTarget(target: .aiWallScreen))
    assert(validator.validateTap(target: .stopRobotButton, time: 11) == .wrongTarget(target: .stopRobotButton))
    assert(validator.validateTap(target: .empty, time: 11) == nil)

    validator = RobotTargetValidator()
    validator.startLevel(at: 20)
    assert(validator.checkTimeouts(currentTime: 24.1) == .noInputTimeout)

    validator = RobotTargetValidator()
    validator.startLevel(at: 30)
    assert(validator.checkTimeouts(currentTime: 38.1) == .totalTimeout)
}
#endif
