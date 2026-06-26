enum ActiveLevel {
    case wakeUpManually
    case rejectAutoRoutine
    case openSmartCurtain
    case manualBreakfast
    case holdWristDevice

    var title: String {
        switch self {
        case .wakeUpManually:
            "Level 1 — Wake Up Manually"
        case .rejectAutoRoutine:
            "Level 2 — Reject Auto Routine"
        case .openSmartCurtain:
            "Level 3 — Open The Smart Curtain"
        case .manualBreakfast:
            "Level 4 — Manual Breakfast"
        case .holdWristDevice:
            "Level 5 — Hold The Wrist Device"
        }
    }

    var instruction: String {
        switch self {
        case .wakeUpManually:
            "Tap body → head → body → wrist"
        case .rejectAutoRoutine:
            "Swipe the routine card left or right"
        case .openSmartCurtain:
            "Drag the curtain open sideways"
        case .manualBreakfast:
            "Choose the handmade toast"
        case .holdWristDevice:
            "Hold the yellow wrist device"
        }
    }
}
