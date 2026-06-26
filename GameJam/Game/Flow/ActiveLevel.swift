enum ActiveLevel {
    case wakeUpManually
    case rejectAutoRoutine
    case openSmartCurtain
    case manualBreakfast
    case holdWristDevice
    case findManualKey
    case drawManualRoute
    case finalApartmentChoice
    case chapter2PerfectStreet
    case chapter2WrongRobotTarget
    case chapter2AvoidSafeElevator
    case chapter2ManualBridgeBalance
    case chapter2RescueChairCitizen
    case chapter2WalkAgainstCrowd
    case chapter2FindOldTransitSwitch
    case chapter2EnterManualTunnel

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
        case .chapter2PerfectStreet:
            "Chapter 2 Level 1 — The Perfect Street"
        case .chapter2WrongRobotTarget:
            "Chapter 2 Level 2 — Do Not Shoot The Wrong Robot"
        case .chapter2AvoidSafeElevator:
            "Chapter 2 Level 3 — Avoid The Safe Elevator"
        case .chapter2ManualBridgeBalance:
            "Chapter 2 Level 4 — Balance On The Manual Bridge"
        case .chapter2RescueChairCitizen:
            "Chapter 2 Level 5 — Rescue The Chair Citizen"
        case .chapter2WalkAgainstCrowd:
            "Chapter 2 Level 6 — Walk Against The Crowd"
        case .chapter2FindOldTransitSwitch:
            "Chapter 2 Level 7 — Find The Old Transit Switch"
        case .chapter2EnterManualTunnel:
            "Chapter 2 Level 8 — Enter The Manual Tunnel"
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
        case .chapter2PerfectStreet:
            "Swipe up-left toward the yellow manual path"
        case .chapter2WrongRobotTarget:
            "Tap the surveillance drone"
        case .chapter2AvoidSafeElevator:
            "Swipe left toward the manual stairs"
        case .chapter2ManualBridgeBalance:
            "Tilt to keep Raka centered"
        case .chapter2RescueChairCitizen:
            "Drag the citizen to the yellow safe zone"
        case .chapter2WalkAgainstCrowd:
            "Swipe left against the crowd 3 times"
        case .chapter2FindOldTransitSwitch:
            "Drag the scanner → reveal the yellow switch"
        case .chapter2EnterManualTunnel:
            "Hold Raka → drag into the yellow tunnel"
        }
    }
}
