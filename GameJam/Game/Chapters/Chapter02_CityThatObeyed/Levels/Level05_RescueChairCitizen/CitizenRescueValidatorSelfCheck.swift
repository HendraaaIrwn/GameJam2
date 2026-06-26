#if DEBUG
import CoreGraphics
import SpriteKit

func runCitizenRescueValidatorSelfCheck() {
    let validator = CitizenRescueValidator()
    validator.startLevel(at: 0)
    assert(validator.beginDrag(target: .citizen, startPoint: .zero, time: 0.1) == .dragStarted)
    assert(validator.beginDrag(target: .empty, startPoint: .zero, time: 0.2) == nil)
    assert(validator.beginDrag(target: .manualSafeZone, startPoint: .zero, time: 0.3) == nil)

    assert(validator.validateTap(target: .relaxButton, time: 0.4) == .trapSelected(target: .relaxButton))
    assert(validator.validateTap(target: .autonomousChair, time: 0.5) == .trapSelected(target: .autonomousChair))
    assert(validator.validateTap(target: .blueAIRoute, time: 0.6) == .trapSelected(target: .blueAIRoute))
    assert(validator.validateTap(target: .aiWallScreen, time: 0.7) == .trapSelected(target: .aiWallScreen))

    if case let .dragging(progress) = validator.updateDrag(currentPoint: CGPoint(x: 100, y: 0), chairCenter: .zero, time: 0.8) {
        assert(progress > 0)
    } else {
        assertionFailure("Expected drag progress")
    }

    let scene = SKScene(size: CGSize(width: 300, height: 300))
    let chair = SKShapeNode(rectOf: CGSize(width: 80, height: 80))
    chair.position = CGPoint(x: 200, y: 150)
    let safe = SKShapeNode(rectOf: CGSize(width: 90, height: 90))
    safe.position = CGPoint(x: 50, y: 150)
    let blue = SKShapeNode(rectOf: CGSize(width: 80, height: 80))
    blue.position = CGPoint(x: 200, y: 40)
    scene.addChild(chair)
    scene.addChild(safe)
    scene.addChild(blue)

    assert(validator.endDrag(endPoint: CGPoint(x: 50, y: 150), chairNode: chair, safeZoneNode: safe, blueRouteNode: blue, time: 1.0) == .rescued)
    assert(validator.endDrag(endPoint: CGPoint(x: 200, y: 40), chairNode: chair, safeZoneNode: safe, blueRouteNode: blue, time: 1.1) == .droppedOnBlueRoute)
    assert(validator.endDrag(endPoint: CGPoint(x: 200, y: 150), chairNode: chair, safeZoneNode: safe, blueRouteNode: blue, time: 1.2) == .returnedToChair)
    assert(validator.endDrag(endPoint: CGPoint(x: 140, y: 260), chairNode: chair, safeZoneNode: safe, blueRouteNode: blue, time: 1.3) == .releasedTooEarly)

    let noInput = CitizenRescueValidator()
    noInput.startLevel(at: 0)
    assert(noInput.checkTimeouts(currentTime: 4.1) == .noInputTimeout)

    let total = CitizenRescueValidator()
    total.startLevel(at: 0)
    assert(total.checkTimeouts(currentTime: 10.1) == .totalTimeout)

    validator.reset()
    assert(!validator.hasReceivedInput)
    assert(!validator.isDraggingCitizen)
}
#endif
