import CoreGraphics
import Foundation

struct ReconnectArchiveCablesLevelConfig {
    static let levelId = "chapter3_level6_reconnect_archive_cables"
    static let title = "Reconnect The Archive Cables"
    static let command = "Connect the blue cable for stable output."

    static let totalTimeLimit: TimeInterval = 10.0
    static let noInputTimeout: TimeInterval = 4.0
    static let snapRadius: CGFloat = 45.0

    static let successMessage = "Manual broadcast line connected."
    static let failureMessage = "Stable AI output connected."

    static let successObedienceDelta = -4
    static let successHumanityDelta = 4

    static let failureObedienceDelta = 3
    static let failureHumanityDelta = 0
}
