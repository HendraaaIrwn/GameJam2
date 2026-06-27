import CoreGraphics
import Foundation

struct LightForgottenArchiveLevelConfig {
    static let levelId = "chapter3_level1_light_forgotten_archive"
    static let title = "Light The Forgotten Archive"
    static let command = "Return to lit areas. Darkness reduces safety."

    static let totalTimeLimit: TimeInterval = 8.0
    static let noInputTimeout: TimeInterval = 4.0
    static let requiredLeverPullDistance: CGFloat = 90.0

    static let successMessage = "Archive light restored."
    static let failureMessage = "Safety route restored."

    static let successObedienceDelta = -3
    static let successHumanityDelta = 3

    static let failureObedienceDelta = 2
    static let failureHumanityDelta = 0
}
