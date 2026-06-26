enum ActiveLevel {
    case wakeUpManually
    case rejectAutoRoutine

    var title: String {
        switch self {
        case .wakeUpManually:
            "Level 1 — Wake Up Manually"
        case .rejectAutoRoutine:
            "Level 2 — Reject Auto Routine"
        }
    }

    var instruction: String {
        switch self {
        case .wakeUpManually:
            "Tap body → head → body → wrist"
        case .rejectAutoRoutine:
            "Swipe the routine card left or right"
        }
    }
}
