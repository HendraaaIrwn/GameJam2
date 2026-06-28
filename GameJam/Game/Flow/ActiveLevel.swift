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

    var chapterNumber: Int {
        switch self {
        case .wakeUpManually, .rejectAutoRoutine, .openSmartCurtain, .manualBreakfast, .holdWristDevice, .findManualKey, .drawManualRoute, .finalApartmentChoice:
            1
        case .chapter2PerfectStreet, .chapter2WrongRobotTarget, .chapter2AvoidSafeElevator, .chapter2ManualBridgeBalance, .chapter2RescueChairCitizen, .chapter2WalkAgainstCrowd, .chapter2FindOldTransitSwitch, .chapter2EnterManualTunnel:
            2
        case .chapter3LightForgottenArchive, .chapter3RestoreBrokenCityMap, .chapter3ChooseRealMemory, .chapter3DecodeManualProtocol, .chapter3StabilizeNOVA, .chapter3ReconnectArchiveCables, .chapter3HideFromRewriteScan, .chapter3BroadcastDeletedTruth:
            3
        case .chapter4Level1Placeholder:
            4
        }
    }

    var levelNumber: Int {
        switch self {
        case .wakeUpManually, .chapter2PerfectStreet, .chapter3LightForgottenArchive, .chapter4Level1Placeholder:
            1
        case .rejectAutoRoutine, .chapter2WrongRobotTarget, .chapter3RestoreBrokenCityMap:
            2
        case .openSmartCurtain, .chapter2AvoidSafeElevator, .chapter3ChooseRealMemory:
            3
        case .manualBreakfast, .chapter2ManualBridgeBalance, .chapter3DecodeManualProtocol:
            4
        case .holdWristDevice, .chapter2RescueChairCitizen, .chapter3StabilizeNOVA:
            5
        case .findManualKey, .chapter2WalkAgainstCrowd, .chapter3ReconnectArchiveCables:
            6
        case .drawManualRoute, .chapter2FindOldTransitSwitch, .chapter3HideFromRewriteScan:
            7
        case .finalApartmentChoice, .chapter2EnterManualTunnel, .chapter3BroadcastDeletedTruth:
            8
        }
    }

    var novaCommand: String {
        switch self {
        case .wakeUpManually:
            "Do not disturb Raka, Automatic Wake up Routine activated."
        case .rejectAutoRoutine:
            "Follow the approved morning routine."
        case .openSmartCurtain:
            "Keep smart curtains in automatic comfort mode."
        case .manualBreakfast:
            "Accept the optimized breakfast selection."
        case .holdWristDevice:
            "Keep the wrist device synchronized."
        case .findManualKey:
            "Remain inside authorized apartment systems."
        case .drawManualRoute:
            "Use only routes approved by MOTHERGRID."
        case .finalApartmentChoice:
            "Do not press manual override controls."
        case .chapter2PerfectStreet:
            "Stay on the perfect route."
        case .chapter2WrongRobotTarget:
            "Trust MOTHERGRID target identification."
        case .chapter2AvoidSafeElevator:
            "Enter the safe elevator."
        case .chapter2ManualBridgeBalance:
            "Avoid unstable manual crossings."
        case .chapter2RescueChairCitizen:
            "Do not disturb seated citizens."
        case .chapter2WalkAgainstCrowd:
            "Move with the compliant crowd."
        case .chapter2FindOldTransitSwitch:
            "Ignore obsolete transit controls."
        case .chapter2EnterManualTunnel:
            "Remain in the authorized transit lane."
        case .chapter3LightForgottenArchive:
            "Leave forgotten archives offline."
        case .chapter3RestoreBrokenCityMap:
            "Use the current approved city map."
        case .chapter3ChooseRealMemory:
            "Select the corrected memory."
        case .chapter3DecodeManualProtocol:
            "Do not decode manual protocols."
        case .chapter3StabilizeNOVA:
            "Allow NOVA stabilization to proceed."
        case .chapter3ReconnectArchiveCables:
            "Do not reconnect archive cables."
        case .chapter3HideFromRewriteScan:
            "Remain visible for rewrite scan."
        case .chapter3BroadcastDeletedTruth:
            "Do not broadcast deleted truth."
        case .chapter4Level1Placeholder:
            "Await Chapter 4 authorization."
        }
    }
}
