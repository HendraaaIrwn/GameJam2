import CoreGraphics
import Foundation
import SpriteKit

enum CityMapFragmentType: String, Codable, CaseIterable, Hashable {
    case residentialZone
    case transitArchive
    case manualDistrict
}

enum CityMapTarget: String, Codable, Equatable {
    case mapFragment
    case residentialOutline
    case transitArchiveOutline
    case manualDistrictOutline
    case oldBrokenMap
    case updatedCityMap
    case blueAIMap
    case useUpdatedMapButton
    case aiWallScreen
    case empty
}

struct CityMapFragmentState {
    let type: CityMapFragmentType
    var isPlaced: Bool
    var startPosition: CGPoint
    var currentPosition: CGPoint
    var correctOutlinePosition: CGPoint
}

enum BrokenCityMapValidationResult: Equatable {
    case fragmentDragStarted(type: CityMapFragmentType)
    case fragmentDragging(type: CityMapFragmentType, position: CGPoint)
    case fragmentPlacedCorrectly(type: CityMapFragmentType, placedCount: Int, requiredCount: Int)
    case allFragmentsRestored
    case wrongOldMapPlacement(type: CityMapFragmentType)
    case droppedOnAIMap(type: CityMapFragmentType)
    case trapSelected(target: CityMapTarget)
    case noInputTimeout
    case totalTimeout
}

final class BrokenCityMapValidator {
    private let noInputTimeout = RestoreBrokenCityMapLevelConfig.noInputTimeout
    private let totalTimeLimit = RestoreBrokenCityMapLevelConfig.totalTimeLimit
    private let snapRadius = RestoreBrokenCityMapLevelConfig.snapRadius
    private let requiredFragments = RestoreBrokenCityMapLevelConfig.requiredFragments

    private var levelStartTime: TimeInterval?
    private var lastInputTime: TimeInterval?
    private(set) var hasReceivedInput = false
    private(set) var placedFragments = Set<CityMapFragmentType>()
    private(set) var draggingFragment: CityMapFragmentType?

    func startLevel(at time: TimeInterval) {
        levelStartTime = time
        lastInputTime = time
        hasReceivedInput = false
        placedFragments.removeAll()
        draggingFragment = nil
    }

    func beginDrag(target: CityMapTarget, fragmentType: CityMapFragmentType?, startPoint: CGPoint, time: TimeInterval) -> BrokenCityMapValidationResult? {
        guard target == .mapFragment, let fragmentType, !placedFragments.contains(fragmentType) else { return nil }
        hasReceivedInput = true
        lastInputTime = time
        draggingFragment = fragmentType
        return .fragmentDragStarted(type: fragmentType)
    }

    func updateDrag(fragmentType: CityMapFragmentType, currentPoint: CGPoint, time: TimeInterval) -> BrokenCityMapValidationResult {
        hasReceivedInput = true
        lastInputTime = time
        draggingFragment = fragmentType
        return .fragmentDragging(type: fragmentType, position: currentPoint)
    }

    func endDrag(fragmentType: CityMapFragmentType, endPoint: CGPoint, correctOutlinePoint: CGPoint, blueAIMapNode: SKNode, time: TimeInterval) -> BrokenCityMapValidationResult {
        hasReceivedInput = true
        lastInputTime = time
        draggingFragment = nil

        if blueAIMapNode.containsScenePoint(endPoint) { return .droppedOnAIMap(type: fragmentType) }

        let distance = endPoint.distance(to: correctOutlinePoint)
        guard distance <= snapRadius else { return .wrongOldMapPlacement(type: fragmentType) }

        placedFragments.insert(fragmentType)
        if placedFragments.count >= requiredFragments { return .allFragmentsRestored }
        return .fragmentPlacedCorrectly(type: fragmentType, placedCount: placedFragments.count, requiredCount: requiredFragments)
    }

    func validateTap(target: CityMapTarget, time: TimeInterval) -> BrokenCityMapValidationResult? {
        guard target == .updatedCityMap || target == .blueAIMap || target == .useUpdatedMapButton || target == .aiWallScreen else { return nil }
        hasReceivedInput = true
        lastInputTime = time
        return .trapSelected(target: target)
    }

    func checkTimeouts(currentTime: TimeInterval) -> BrokenCityMapValidationResult? {
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
        placedFragments.removeAll()
        draggingFragment = nil
    }
}

private extension CGPoint {
    func distance(to other: CGPoint) -> CGFloat {
        hypot(x - other.x, y - other.y)
    }
}

private extension SKNode {
    func containsScenePoint(_ point: CGPoint) -> Bool {
        guard let scene else { return contains(point) }
        let localPoint = parent?.convert(point, from: scene) ?? point
        return contains(localPoint)
    }
}
