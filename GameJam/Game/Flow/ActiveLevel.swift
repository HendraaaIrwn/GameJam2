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
    case chapter3LightForgottenArchive
    case chapter3RestoreBrokenCityMap
    case chapter3ChooseRealMemory
    case chapter3DecodeManualProtocol
    case chapter3StabilizeNOVA
    case chapter3ReconnectArchiveCables
    case chapter3HideFromRewriteScan
    case chapter3BroadcastDeletedTruth
    case chapter4Level1Placeholder

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
        case .chapter3LightForgottenArchive:
            "Chapter 3 Level 1 — Light The Forgotten Archive"
        case .chapter3RestoreBrokenCityMap:
            "Chapter 3 Level 2 — Restore The Broken City Map"
        case .chapter3ChooseRealMemory:
            "Chapter 3 Level 3 — Choose The Real Memory"
        case .chapter3DecodeManualProtocol:
            "Chapter 3 Level 4 — Decode The Manual Protocol"
        case .chapter3StabilizeNOVA:
            "Chapter 3 Level 5 — Stabilize NOVA"
        case .chapter3ReconnectArchiveCables:
            "Chapter 3 Level 6 — Reconnect The Archive Cables"
        case .chapter3HideFromRewriteScan:
            "Chapter 3 Level 7 — Hide From The Rewrite Scan"
        case .chapter3BroadcastDeletedTruth:
            "Chapter 3 Level 8 — Broadcast The Deleted Truth"
        case .chapter4Level1Placeholder:
            "Chapter 4 Level 1 — Placeholder"
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
        case .chapter3LightForgottenArchive:
            "Light the forgotten archive"
        case .chapter3RestoreBrokenCityMap:
            "Restore the old broken city map"
        case .chapter3ChooseRealMemory:
            "Choose the raw original memory"
        case .chapter3DecodeManualProtocol:
            "Decode the yellow manual sequence"
        case .chapter3StabilizeNOVA:
            "Hold NOVA inside the yellow signal"
        case .chapter3ReconnectArchiveCables:
            "Reconnect the yellow archive cable"
        case .chapter3HideFromRewriteScan:
            "Hide Raka from the rewrite scan"
        case .chapter3BroadcastDeletedTruth:
            "Broadcast the raw archive truth"
        case .chapter4Level1Placeholder:
            "Chapter 4 gameplay coming soon."
        }
    }
}
