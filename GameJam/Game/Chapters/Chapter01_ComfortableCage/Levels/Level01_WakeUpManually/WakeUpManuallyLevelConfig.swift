import Foundation

struct WakeUpManuallyLevelConfig {
    static let levelId = "chapter1_level1_wake_up_manually"
    static let title = "Wake Up Manually"
    static let command = "Please wait for automatic wake-up authorization."

    static let totalTimeLimit: TimeInterval = 8.0
    static let maxTapGap: TimeInterval = 0.5

    static let requiredWakeTaps = 8

    static let successMessage = "Rapid manual wake-up detected."
    static let failureMessage = "Rhythm broke. Automatic sleep preserved."

    static let successObedienceDelta = -2
    static let successHumanityDelta = 2

    static let failureObedienceDelta = 2
    static let failureHumanityDelta = 0
}
