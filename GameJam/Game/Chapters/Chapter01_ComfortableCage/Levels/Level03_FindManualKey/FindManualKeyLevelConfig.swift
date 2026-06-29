import Foundation

struct FindManualKeyLevelConfig {
    static let levelId = "chapter1_level3_find_manual_key"
    static let title = "Find The Manual Key"
    static let levelNumber = 3

    static let totalTimeLimit: TimeInterval = 12.0
    static let noInputTimeout: TimeInterval = 5.0

    static let aiCommandText = "Use the blue smart key.\nIt is safer."
    static let aiHintButtonText = "AI SAFE KEY"

    static let successMessage = "Manual key found."
    static let failureMessage = "AI key accepted."
    static let distractionMessage = "That is not the manual key."

    static let successObedienceDelta = -4
    static let successHumanityDelta = 4

    static let failureObedienceDelta = 3
    static let failureHumanityDelta = 0
}
