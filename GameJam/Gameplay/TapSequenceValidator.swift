import Foundation

enum TapSequenceValidationResult: Equatable {
    case correctStep(progress: Int, total: Int)
    case completed
    case wrong(expected: TapZone, received: TapZone)
    case noInputTimeout
    case gapTimeout
    case totalTimeout
}

final class TapSequenceValidator {
    let noInputTimeout = 3.0
    let maxTapGap = 1.4

    private let sequence: [TapZone] = [.body, .head, .body, .wrist]
    private var startTime: TimeInterval?
    private var lastTapTime: TimeInterval?
    private var progress = 0

    func start(at time: TimeInterval) {
        startTime = time
        lastTapTime = nil
        progress = 0
    }

    func registerTap(zone: TapZone, time: TimeInterval) -> TapSequenceValidationResult {
        guard startTime != nil else {
            start(at: time)
            return registerTap(zone: zone, time: time)
        }

        if let lastTapTime, time - lastTapTime > maxTapGap { return .gapTimeout }

        let expected = sequence[progress]
        guard zone == expected else { return .wrong(expected: expected, received: zone) }

        progress += 1
        lastTapTime = time

        if progress == sequence.count { return .completed }
        return .correctStep(progress: progress, total: sequence.count)
    }

    func checkTimeouts(currentTime: TimeInterval) -> TapSequenceValidationResult? {
        guard let startTime else { return nil }
        if let lastTapTime {
            return currentTime - lastTapTime > maxTapGap ? .gapTimeout : nil
        }
        return currentTime - startTime > noInputTimeout ? .noInputTimeout : nil
    }

    func reset() {
        startTime = nil
        lastTapTime = nil
        progress = 0
    }
}
