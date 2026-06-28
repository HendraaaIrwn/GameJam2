import Foundation

struct RejectAutoRoutineLevelConfig {
    static let levelId = "chapter1.level2.reject-auto-routine"
    static let title = "Reject Auto Routine"
    static let command = "Accept today’s perfect routine."

    static let totalTimeLimit: TimeInterval = 8.0
    static let noInputTimeout: TimeInterval = 4.0

    static let successMessage = "Routine rejected."
    static let failureMessage = "Compliance Detected."

    static let successObedienceDelta = -3
    static let successHumanityDelta = 2

    static let failureObedienceDelta = 3
    static let failureHumanityDelta = 0
}
