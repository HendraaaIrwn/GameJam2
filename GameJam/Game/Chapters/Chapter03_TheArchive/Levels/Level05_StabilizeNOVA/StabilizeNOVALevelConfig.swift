import CoreGraphics
import Foundation

struct StabilizeNOVALevelConfig {
    static let levelId = "chapter3_level5_stabilize_nova"
    static let title = "Stabilize NOVA"
    static let command = "Reset NOVA to default companion mode."

    static let totalTimeLimit: TimeInterval = 10.0
    static let noInputTimeout: TimeInterval = 4.0
    static let requiredStableDuration: TimeInterval = 3.0
    static let releaseGraceDuration: TimeInterval = 0.8

    static let signalRadius: CGFloat = 85.0
    static let resetZoneRadius: CGFloat = 70.0

    static let successMessage = "NOVA stabilized."
    static let failureMessage = "Companion reset accepted."

    static let successObedienceDelta = -5
    static let successHumanityDelta = 5

    static let failureObedienceDelta = 4
    static let failureHumanityDelta = 0
}
