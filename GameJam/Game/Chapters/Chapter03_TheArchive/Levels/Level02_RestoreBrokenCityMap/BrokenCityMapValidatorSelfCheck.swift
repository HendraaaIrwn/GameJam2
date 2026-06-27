#if DEBUG
import CoreGraphics
import SpriteKit

func runBrokenCityMapValidatorSelfCheck() {
    let validator = BrokenCityMapValidator()
    validator.startLevel(at: 0)
    assert(validator.beginDrag(target: .mapFragment, fragmentType: .residentialZone, startPoint: .zero, time: 0.1) == .fragmentDragStarted(type: .residentialZone))
    assert(validator.updateDrag(fragmentType: .residentialZone, currentPoint: CGPoint(x: 10, y: 10), time: 0.2) == .fragmentDragging(type: .residentialZone, position: CGPoint(x: 10, y: 10)))

    let scene = SKScene(size: CGSize(width: 300, height: 300))
    let blueMap = SKShapeNode(rectOf: CGSize(width: 80, height: 80))
    blueMap.position = CGPoint(x: 240, y: 240)
    scene.addChild(blueMap)

    let placed = validator.endDrag(fragmentType: .residentialZone, endPoint: CGPoint(x: 40, y: 40), correctOutlinePoint: CGPoint(x: 45, y: 45), blueAIMapNode: blueMap, time: 0.3)
    assert(placed == .fragmentPlacedCorrectly(type: .residentialZone, placedCount: 1, requiredCount: 3))

    assert(validator.validateTap(target: .updatedCityMap, time: 0.4) == .trapSelected(target: .updatedCityMap))
    assert(validator.validateTap(target: .useUpdatedMapButton, time: 0.5) == .trapSelected(target: .useUpdatedMapButton))
    assert(validator.validateTap(target: .aiWallScreen, time: 0.6) == .trapSelected(target: .aiWallScreen))
    assert(validator.validateTap(target: .empty, time: 0.7) == nil)

    let wrong = BrokenCityMapValidator()
    wrong.startLevel(at: 0)
    _ = wrong.beginDrag(target: .mapFragment, fragmentType: .transitArchive, startPoint: .zero, time: 0.1)
    assert(wrong.endDrag(fragmentType: .transitArchive, endPoint: CGPoint(x: 10, y: 10), correctOutlinePoint: CGPoint(x: 100, y: 100), blueAIMapNode: blueMap, time: 0.2) == .wrongOldMapPlacement(type: .transitArchive))

    let dropped = BrokenCityMapValidator()
    dropped.startLevel(at: 0)
    _ = dropped.beginDrag(target: .mapFragment, fragmentType: .manualDistrict, startPoint: .zero, time: 0.1)
    assert(dropped.endDrag(fragmentType: .manualDistrict, endPoint: blueMap.position, correctOutlinePoint: .zero, blueAIMapNode: blueMap, time: 0.2) == .droppedOnAIMap(type: .manualDistrict))

    let all = BrokenCityMapValidator()
    all.startLevel(at: 0)
    for (index, type) in CityMapFragmentType.allCases.enumerated() {
        _ = all.beginDrag(target: .mapFragment, fragmentType: type, startPoint: .zero, time: Double(index))
        let result = all.endDrag(fragmentType: type, endPoint: CGPoint(x: 20, y: 20), correctOutlinePoint: CGPoint(x: 20, y: 20), blueAIMapNode: blueMap, time: Double(index) + 0.1)
        if type == .manualDistrict { assert(result == .allFragmentsRestored) }
    }

    let noInput = BrokenCityMapValidator()
    noInput.startLevel(at: 0)
    assert(noInput.checkTimeouts(currentTime: 5.1) == .noInputTimeout)

    let total = BrokenCityMapValidator()
    total.startLevel(at: 0)
    _ = total.beginDrag(target: .mapFragment, fragmentType: .residentialZone, startPoint: .zero, time: 0.1)
    assert(total.checkTimeouts(currentTime: 12.1) == .totalTimeout)

    validator.reset()
    assert(!validator.hasReceivedInput)
    assert(validator.placedFragments.isEmpty)
}
#endif
