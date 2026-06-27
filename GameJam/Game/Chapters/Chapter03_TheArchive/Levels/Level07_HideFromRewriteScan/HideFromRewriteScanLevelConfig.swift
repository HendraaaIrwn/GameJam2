import CoreGraphics
import Foundation

struct HideFromRewriteScanLevelConfig {
    static let levelId = "chapter3_level7_hide_from_rewrite_scan"
    static let title = "Hide From The Rewrite Scan"
    static let command = "Stand still for identity verification."

    static let totalTimeLimit: TimeInterval = 12.0
    static let noInputTimeout: TimeInterval = 4.0

    static let requiredScanPasses = 2
    static let scanBeamWidth: CGFloat = 90.0
    static let scanPassDuration: TimeInterval = 4.0
    static let scanStartDelay: TimeInterval = 0.7
    static let detectionGraceDuration: TimeInterval = 0.25

    static let successMessage = "Rewrite scan avoided."
    static let failureMessage = "Identity verified."

    static let successObedienceDelta = -4
    static let successHumanityDelta = 4

    static let failureObedienceDelta = 3
    static let failureHumanityDelta = 0
}
