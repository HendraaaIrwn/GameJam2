import Foundation
import SwiftUI

struct FindManualKeyLevelConfig {
    static let levelId = "chapter1_level3_find_manual_key"
    static let title = "Find The Manual Key"
    static let levelNumber = 3

    static let command = "Use the blue smart key. It is safer."
    static let aiHintButtonText = command

    static let totalTimeLimit: TimeInterval = 12.0
    static let noInputTimeout: TimeInterval = 5.0

    static let successMessage = "Manual key found."
    static let failureMessage = "AI key accepted."
    static let distractionMessage = "That is not the manual key."

    static let successObedienceDelta = -4
    static let successHumanityDelta = 4

    static let failureObedienceDelta = 3
    static let failureHumanityDelta = 0

    static let backgroundColor = Color(hex: "#1B1730")
    static let feedbackSuccessColor = AppColor.success
    static let feedbackFailureColor = AppColor.danger
    static let feedbackNeutralColor = Color.white

    static let flashlightRadiusRatio: CGFloat = 0.17
    static let darknessOpacity: Double = 0.92

    static let tablePosition = CGPoint(x: 0.5, y: 0.63)
    static let tableWidthRatio: CGFloat = 1.28

    static let items: [ManualKeyItem] = [
        ManualKeyItem(
            id: "broken_cable",
            type: .brokenCable,
            assetName: "Kabel Rusak",
            fallbackTitle: "Cable",
            position: CGPoint(x: 0.22, y: 0.52),
            size: CGSize(width: 120, height: 90)
        ),
        ManualKeyItem(
            id: "old_photo",
            type: .oldPhoto,
            assetName: "Foto Lama",
            fallbackTitle: "Photo",
            position: CGPoint(x: 0.47, y: 0.50),
            size: CGSize(width: 92, height: 110)
        ),
        ManualKeyItem(
            id: "red_chip",
            type: .redGlitchChip,
            assetName: "Chip Merah",
            fallbackTitle: "Chip",
            position: CGPoint(x: 0.73, y: 0.52),
            size: CGSize(width: 86, height: 86)
        ),
        ManualKeyItem(
            id: "smart_key",
            type: .smartKey,
            assetName: "Smart Key",
            fallbackTitle: "Smart Key",
            position: CGPoint(x: 0.30, y: 0.66),
            size: CGSize(width: 120, height: 72)
        ),
        ManualKeyItem(
            id: "toy_robot",
            type: .toyRobot,
            assetName: "Mainan Boneka",
            fallbackTitle: "Robot",
            position: CGPoint(x: 0.76, y: 0.67),
            size: CGSize(width: 94, height: 118)
        ),
        ManualKeyItem(
            id: "manual_key",
            type: .manualKey,
            assetName: "Kunci Fisik",
            fallbackTitle: "Manual Key",
            position: CGPoint(x: 0.54, y: 0.75),
            size: CGSize(width: 122, height: 76)
        )
    ]
}
