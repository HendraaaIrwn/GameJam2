import CoreGraphics

enum CurtainDragValidationResult: Equatable {
    case validOpen
    case insufficientDrag
    case wrongDirection
}

final class CurtainDragValidator {
    private let minimumHorizontalDistance: CGFloat = 120

    func validateDrag(translation: CGVector) -> CurtainDragValidationResult {
        let horizontalDistance = abs(translation.dx)
        let verticalDistance = abs(translation.dy)

        if horizontalDistance >= minimumHorizontalDistance && horizontalDistance > verticalDistance {
            return .validOpen
        }

        if verticalDistance > horizontalDistance {
            return .wrongDirection
        }

        return .insufficientDrag
    }
}
