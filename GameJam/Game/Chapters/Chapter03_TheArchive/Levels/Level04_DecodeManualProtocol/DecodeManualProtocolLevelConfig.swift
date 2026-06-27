import Foundation

struct DecodeManualProtocolLevelConfig {
    static let levelId = "chapter3_level4_decode_manual_protocol"
    static let title = "Decode The Manual Protocol"
    static let command = "Press the highlighted symbols."

    static let totalTimeLimit: TimeInterval = 10.0
    static let noInputTimeout: TimeInterval = 4.0

    static let requiredSequenceLength = 4

    static let successMessage = "Manual protocol decoded."
    static let failureMessage = "AI sequence accepted."

    static let successObedienceDelta = -4
    static let successHumanityDelta = 4

    static let failureObedienceDelta = 3
    static let failureHumanityDelta = 0
}
