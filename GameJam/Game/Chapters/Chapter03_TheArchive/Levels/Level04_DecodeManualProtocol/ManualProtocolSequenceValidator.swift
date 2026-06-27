import Foundation

enum ManualProtocolSymbol: String, Codable, CaseIterable, Hashable {
    case hand
    case eye
    case door
    case spark
    case gear
    case shield
    case route
    case chair
}

enum ManualProtocolTarget: String, Codable, Equatable {
    case manualSymbol
    case aiSymbol
    case autoDecodeButton
    case useHighlightedButton
    case protocolTerminal
    case aiWallScreen
    case raka
    case nova
    case empty
}

struct ManualProtocolSymbolOption {
    let symbol: ManualProtocolSymbol
    let isManual: Bool
    let isAIHighlighted: Bool
    let displayName: String
}

enum ManualProtocolSequenceValidationResult: Equatable {
    case correctSymbolSelected(symbol: ManualProtocolSymbol, currentIndex: Int, requiredCount: Int)
    case manualProtocolDecoded
    case wrongSymbolSelected(symbol: ManualProtocolSymbol, expected: ManualProtocolSymbol)
    case aiSymbolSelected(symbol: ManualProtocolSymbol)
    case trapSelected(target: ManualProtocolTarget)
    case ignoredTarget(target: ManualProtocolTarget)
    case noInputTimeout
    case totalTimeout
}

final class ManualProtocolSequenceValidator {
    private let noInputTimeout = DecodeManualProtocolLevelConfig.noInputTimeout
    private let totalTimeLimit = DecodeManualProtocolLevelConfig.totalTimeLimit
    private let requiredSequence: [ManualProtocolSymbol] = [.hand, .eye, .door, .spark]

    private var levelStartTime: TimeInterval?
    private var lastInputTime: TimeInterval?
    private(set) var hasReceivedInput = false
    private(set) var currentSequenceIndex = 0

    var expectedSymbol: ManualProtocolSymbol? {
        guard currentSequenceIndex < requiredSequence.count else { return nil }
        return requiredSequence[currentSequenceIndex]
    }

    func startLevel(at time: TimeInterval) {
        levelStartTime = time
        lastInputTime = time
        hasReceivedInput = false
        currentSequenceIndex = 0
    }

    func validateTap(target: ManualProtocolTarget, symbol: ManualProtocolSymbol?, time: TimeInterval) -> ManualProtocolSequenceValidationResult? {
        switch target {
        case .autoDecodeButton, .useHighlightedButton, .aiWallScreen:
            hasReceivedInput = true
            lastInputTime = time
            return .trapSelected(target: target)
        case .aiSymbol:
            hasReceivedInput = true
            lastInputTime = time
            return .aiSymbolSelected(symbol: symbol ?? .gear)
        case .manualSymbol:
            guard let symbol, let expected = expectedSymbol else { return nil }
            hasReceivedInput = true
            lastInputTime = time
            guard symbol == expected else { return .wrongSymbolSelected(symbol: symbol, expected: expected) }
            currentSequenceIndex += 1
            if currentSequenceIndex >= requiredSequence.count { return .manualProtocolDecoded }
            return .correctSymbolSelected(symbol: symbol, currentIndex: currentSequenceIndex, requiredCount: requiredSequence.count)
        case .raka, .nova:
            hasReceivedInput = true
            lastInputTime = time
            return .ignoredTarget(target: target)
        case .protocolTerminal, .empty:
            return nil
        }
    }

    func checkTimeouts(currentTime: TimeInterval) -> ManualProtocolSequenceValidationResult? {
        guard let levelStartTime else { return nil }
        if currentTime - levelStartTime >= totalTimeLimit { return .totalTimeout }
        if !hasReceivedInput, currentTime - levelStartTime > noInputTimeout { return .noInputTimeout }
        if let lastInputTime, currentTime - lastInputTime > noInputTimeout { return .noInputTimeout }
        return nil
    }

    func reset() {
        levelStartTime = nil
        lastInputTime = nil
        hasReceivedInput = false
        currentSequenceIndex = 0
    }
}
