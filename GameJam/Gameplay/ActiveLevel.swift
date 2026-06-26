enum ActiveLevel {
    case wakeUpManually
    case rejectAutoRoutine
    case openSmartCurtain
    case manualBreakfast
    case holdWristDevice
    case findManualKey
    case drawManualRoute
    case finalApartmentChoice

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
        case .findManualKey:
            "Level 6 — Find The Manual Key"
        case .drawManualRoute:
            "Level 7 — Draw Manual Route To Door"
        case .finalApartmentChoice:
            "Level 8 — Final Apartment Choice: Red Button"
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
        case .findManualKey:
            "Drag the light → find the yellow key"
        case .drawManualRoute:
            "Draw the yellow route to the door"
        case .finalApartmentChoice:
            "Press the red manual override button"
        }
    }
}
