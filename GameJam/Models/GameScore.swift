struct GameScore: Codable {
    var obedience: Int
    var humanity: Int

    static let initial = GameScore(obedience: 100, humanity: 0)

    mutating func apply(_ result: LevelResult) {
        obedience = (obedience + result.obedienceDelta).clamped(to: 0...100)
        humanity = (humanity + result.humanityDelta).clamped(to: 0...100)
    }
}

private extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}
