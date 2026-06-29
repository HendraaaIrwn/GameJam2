#if DEBUG
import CoreGraphics

func runCurtainDragValidatorSelfCheck() {
    let validator = CurtainDragValidator()
    assert(validator.validateDrag(translation: .init(dx: 140, dy: 8)) == .validOpen)
    assert(validator.validateDrag(translation: .init(dx: 60, dy: 8)) == .insufficientDrag)
    assert(validator.validateDrag(translation: .init(dx: 40, dy: 130)) == .wrongDirection)
}
#endif
