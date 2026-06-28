import SpriteKit

extension SKColor {
    convenience init(hex: Int, alpha: CGFloat = 1.0) {
        let red = CGFloat((hex & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((hex & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(hex & 0x0000FF) / 255.0

        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }

    convenience init?(hexString: String, alpha: CGFloat = 1.0) {
        var cleanString = hexString.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if cleanString.hasPrefix("#") {
            cleanString.remove(at: cleanString.startIndex)
        }

        var rgbValue: UInt64 = 0
        let scanner = Scanner(string: cleanString)

        guard scanner.scanHexInt64(&rgbValue) else { return nil }
        guard cleanString.count == 6 else { return nil }

        self.init(hex: Int(rgbValue), alpha: alpha)
    }

    static func Parse(_ hexString: String, alpha: CGFloat = 1.0) -> SKColor {
        SKColor(hexString: hexString, alpha: alpha) ?? .clear
    }

    static let pastelCyan = SKColor(red: 0.71, green: 0.93, blue: 0.96, alpha: 1)
    static let mint = SKColor(red: 0.67, green: 0.91, blue: 0.78, alpha: 1)
    static let cream = SKColor(red: 1.0, green: 0.94, blue: 0.78, alpha: 1)
    static let happyBlue = SKColor(red: 0.24, green: 0.58, blue: 0.92, alpha: 1)
    static let manualYellow = SKColor(red: 1.0, green: 0.82, blue: 0.23, alpha: 1)
    static let warningRed = SKColor(red: 0.95, green: 0.31, blue: 0.34, alpha: 1)
    static let glitchPurple = SKColor(red: 0.62, green: 0.42, blue: 0.92, alpha: 1)
}
