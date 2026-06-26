#if DEBUG
import CoreGraphics
import SpriteKit

func runManualTunnelEntryValidatorSelfCheck() {
    let validator = ManualTunnelEntryValidator()
    validator.startLevel(at: 0)
    assert(validator.beginHold(target: .raka, startPoint: .zero, time: 0.1) == .holdStarted)
    assert(validator.beginHold(target: .empty, startPoint: .zero, time: 0.2) == nil)
    assert(validator.beginHold(target: .manualTunnelZone, startPoint: .zero, time: 0.3) == nil)
    assert(validator.beginHold(target: .cityReturnZone, startPoint: .zero, time: 0.4) == nil)
    assert(validator.beginHold(target: .oldTransitDoor, startPoint: .zero, time: 0.5) == nil)

    assert(validator.validateTap(target: .returnToSafetyButton, time: 0.6) == .trapSelected(target: .returnToSafetyButton))
    assert(validator.validateTap(target: .blueCityRoute, time: 0.7) == .trapSelected(target: .blueCityRoute))
    assert(validator.validateTap(target: .comfortPod, time: 0.8) == .trapSelected(target: .comfortPod))
    assert(validator.validateTap(target: .aiWallScreen, time: 0.9) == .trapSelected(target: .aiWallScreen))

    if case let .dragging(progress) = validator.updateDrag(currentPoint: CGPoint(x: 120, y: 0), time: 1.0) {
        assert(progress > 0)
    } else {
        assertionFailure("Expected drag progress")
    }

    let scene = SKScene(size: CGSize(width: 300, height: 300))
    let tunnel = SKShapeNode(rectOf: CGSize(width: 90, height: 90))
    tunnel.position = CGPoint(x: 50, y: 150)
    let city = SKShapeNode(rectOf: CGSize(width: 90, height: 90))
    city.position = CGPoint(x: 230, y: 150)
    scene.addChild(tunnel)
    scene.addChild(city)

    let early = ManualTunnelEntryValidator()
    early.startLevel(at: 0)
    _ = early.beginHold(target: .raka, startPoint: .zero, time: 0)
    assert(early.endDrag(endPoint: CGPoint(x: 50, y: 150), rakaStartPoint: .zero, tunnelZoneNode: tunnel, cityReturnZoneNode: city, time: 0.1) == .releasedTooEarly)

    let short = ManualTunnelEntryValidator()
    short.startLevel(at: 0)
    _ = short.beginHold(target: .raka, startPoint: .zero, time: 0)
    assert(short.endDrag(endPoint: CGPoint(x: 20, y: 0), rakaStartPoint: .zero, tunnelZoneNode: tunnel, cityReturnZoneNode: city, time: 0.4) == .releasedTooEarly)

    let success = ManualTunnelEntryValidator()
    success.startLevel(at: 0)
    _ = success.beginHold(target: .raka, startPoint: CGPoint(x: 160, y: 150), time: 0)
    assert(success.endDrag(endPoint: CGPoint(x: 50, y: 150), rakaStartPoint: CGPoint(x: 160, y: 150), tunnelZoneNode: tunnel, cityReturnZoneNode: city, time: 0.4) == .enteredTunnel)

    let returned = ManualTunnelEntryValidator()
    returned.startLevel(at: 0)
    _ = returned.beginHold(target: .raka, startPoint: CGPoint(x: 80, y: 150), time: 0)
    assert(returned.endDrag(endPoint: CGPoint(x: 230, y: 150), rakaStartPoint: CGPoint(x: 80, y: 150), tunnelZoneNode: tunnel, cityReturnZoneNode: city, time: 0.4) == .returnedToCity)

    let outside = ManualTunnelEntryValidator()
    outside.startLevel(at: 0)
    _ = outside.beginHold(target: .raka, startPoint: .zero, time: 0)
    assert(outside.endDrag(endPoint: CGPoint(x: 150, y: 280), rakaStartPoint: .zero, tunnelZoneNode: tunnel, cityReturnZoneNode: city, time: 0.4) == .droppedOutsideTunnel)

    let noInput = ManualTunnelEntryValidator()
    noInput.startLevel(at: 0)
    assert(noInput.checkTimeouts(currentTime: 4.1) == .noInputTimeout)

    let total = ManualTunnelEntryValidator()
    total.startLevel(at: 0)
    assert(total.checkTimeouts(currentTime: 10.1) == .totalTimeout)

    validator.reset()
    assert(!validator.hasReceivedInput)
    assert(!validator.isDraggingRaka)
}
#endif
