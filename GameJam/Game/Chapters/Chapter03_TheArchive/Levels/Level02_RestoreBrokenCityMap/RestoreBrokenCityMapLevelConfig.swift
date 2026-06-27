import CoreGraphics
import Foundation

struct RestoreBrokenCityMapLevelConfig {
    static let levelId = "chapter3_level2_restore_broken_city_map"
    static let title = "Restore The Broken City Map"
    static let command = "Use the updated city map."

    static let totalTimeLimit: TimeInterval = 12.0
    static let noInputTimeout: TimeInterval = 5.0

    static let requiredFragments = 3
    static let snapRadius: CGFloat = 45.0

    static let successMessage = "Deleted district restored."
    static let failureMessage = "Updated map accepted."

    static let successObedienceDelta = -4
    static let successHumanityDelta = 4

    static let failureObedienceDelta = 3
    static let failureHumanityDelta = 0
}
