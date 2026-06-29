import Foundation

public enum ManualKeyItemType: String, Codable {
    case manualKey
    case smartKey
    case redGlitchChip
    case toyRobot
    case oldPhoto
    case brokenCable
}

struct ManualKeyItem: Identifiable, Equatable {
    let id: String
    let type: ManualKeyItemType
    let assetName: String
    let fallbackTitle: String
    let position: CGPoint
    let size: CGSize

    var target: ManualKeyTableTarget {
        switch type {
        case .manualKey: .manualKey
        case .smartKey: .smartKey
        case .redGlitchChip: .redChip
        case .toyRobot: .toyDoll
        case .oldPhoto: .oldPhoto
        case .brokenCable: .brokenCable
        }
    }

    var hitboxSize: CGSize {
        CGSize(width: size.width / 390, height: size.height / 844)
    }
}
