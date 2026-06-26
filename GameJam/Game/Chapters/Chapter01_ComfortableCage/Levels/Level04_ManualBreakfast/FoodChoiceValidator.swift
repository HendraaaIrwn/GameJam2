enum FoodChoice: String, Codable, Equatable {
    case nutritionCube
    case perfectSmoothie
    case autoPillMeal
    case handmadeToast
    case suspiciousCandy
    case wrong
}

enum FoodChoiceValidationResult: Equatable {
    case correct(choice: FoodChoice)
    case wrong(choice: FoodChoice)
}

final class FoodChoiceValidator {
    func validate(choice: FoodChoice) -> FoodChoiceValidationResult {
        if choice == .handmadeToast {
            .correct(choice: choice)
        } else {
            .wrong(choice: choice)
        }
    }
}
