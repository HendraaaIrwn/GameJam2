import Foundation

struct ChooseRealMemoryLevelConfig {
    static let levelId = "chapter3_level3_choose_real_memory"
    static let title = "Choose The Real Memory"
    static let command = "Select the corrected memory."

    static let totalTimeLimit: TimeInterval = 8.0
    static let noInputTimeout: TimeInterval = 4.0

    static let successMessage = "Original memory recovered."
    static let failureMessage = "Corrected memory accepted."

    static let successObedienceDelta = -4
    static let successHumanityDelta = 4

    static let failureObedienceDelta = 3
    static let failureHumanityDelta = 0
}
