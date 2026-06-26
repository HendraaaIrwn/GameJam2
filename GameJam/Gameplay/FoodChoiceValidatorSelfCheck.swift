#if DEBUG
func runFoodChoiceValidatorSelfCheck() {
    let validator = FoodChoiceValidator()
    assert(validator.validate(choice: .handmadeToast) == .correct(choice: .handmadeToast))
    assert(validator.validate(choice: .nutritionCube) == .wrong(choice: .nutritionCube))
    assert(validator.validate(choice: .perfectSmoothie) == .wrong(choice: .perfectSmoothie))
    assert(validator.validate(choice: .autoPillMeal) == .wrong(choice: .autoPillMeal))
    assert(validator.validate(choice: .suspiciousCandy) == .wrong(choice: .suspiciousCandy))
    assert(validator.validate(choice: .wrong) == .wrong(choice: .wrong))
}
#endif
