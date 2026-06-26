import CoreGraphics

enum SwipeDismissValidationResult: Equatable {
    case validDismiss
    case insufficientSwipe
    case wrongDirection
}

final class SwipeDismissValidator {
    private let minimumHorizontalDistance: CGFloat = 100

    func validateSwipe(translation: CGVector) -> SwipeDismissValidationResult {
        let horizontalDistance = abs(translation.dx)
        let verticalDistance = abs(translation.dy)

        if horizontalDistance >= minimumHorizontalDistance && horizontalDistance > verticalDistance {
            return .validDismiss
        }

        if verticalDistance > horizontalDistance {
            return .wrongDirection
        }

        return .insufficientSwipe
    }
}
