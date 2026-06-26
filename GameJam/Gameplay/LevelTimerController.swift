import CoreGraphics
import Foundation

struct LevelTimerState: Equatable {
    let elapsed: TimeInterval
    let remaining: TimeInterval
    let progress: CGFloat
    let hasExpired: Bool
    let isWarning: Bool
}

final class LevelTimerController {
    private let totalDuration: TimeInterval
    private var startTime: TimeInterval?
    private(set) var hasStarted = false
    private(set) var hasExpired = false

    init(totalDuration: TimeInterval) {
        self.totalDuration = totalDuration
    }

    func start(at currentTime: TimeInterval) {
        startTime = currentTime
        hasStarted = true
        hasExpired = false
    }

    func update(currentTime: TimeInterval) -> LevelTimerState {
        guard let startTime else {
            return LevelTimerState(elapsed: 0, remaining: totalDuration, progress: 1, hasExpired: false, isWarning: false)
        }

        let elapsed = max(currentTime - startTime, 0)
        let remaining = max(totalDuration - elapsed, 0)
        let progress = CGFloat(remaining / totalDuration).clamped(to: 0...1)
        if remaining <= 0 { hasExpired = true }

        return LevelTimerState(
            elapsed: elapsed,
            remaining: remaining,
            progress: progress,
            hasExpired: hasExpired,
            isWarning: remaining <= 3
        )
    }

    func reset() {
        startTime = nil
        hasStarted = false
        hasExpired = false
    }
}

private extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}
