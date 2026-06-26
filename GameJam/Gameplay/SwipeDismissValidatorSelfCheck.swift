#if DEBUG
func runSwipeDismissValidatorSelfCheck() {
    let validator = SwipeDismissValidator()
    assert(validator.validateSwipe(translation: .init(dx: 128, dy: 12)) == .validDismiss)
    assert(validator.validateSwipe(translation: .init(dx: 40, dy: 8)) == .insufficientSwipe)
    assert(validator.validateSwipe(translation: .init(dx: 40, dy: 120)) == .wrongDirection)
}
#endif
