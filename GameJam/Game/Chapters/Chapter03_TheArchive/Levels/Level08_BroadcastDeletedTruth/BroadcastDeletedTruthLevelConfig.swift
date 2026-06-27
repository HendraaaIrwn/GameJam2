import CoreGraphics
import Foundation

struct BroadcastDeletedTruthLevelConfig {
    static let levelId = "chapter3_level8_broadcast_deleted_truth"
    static let title = "Broadcast The Deleted Truth"
    static let command = "Do not broadcast unverified history."

    static let totalTimeLimit: TimeInterval = 14.0
    static let noInputTimeout: TimeInterval = 5.0

    static let requiredSwitchHoldDuration: TimeInterval = 1.0
    static let sliderSnapRadius: CGFloat = 50.0

    static let successMessage = "Deleted truth broadcasted."
    static let failureMessage = "Clean history accepted."

    static let successObedienceDelta = -6
    static let successHumanityDelta = 6

    static let failureObedienceDelta = 5
    static let failureHumanityDelta = 0
}
