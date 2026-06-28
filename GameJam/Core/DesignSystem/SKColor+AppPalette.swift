import SpriteKit

extension SKColor {
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0

        Scanner(string: hex).scanHexInt64(&int)

        let alpha: UInt64
        let red: UInt64
        let green: UInt64
        let blue: UInt64

        switch hex.count {
        case 3:
            alpha = 255
            red = (int >> 8) * 17
            green = (int >> 4 & 0xF) * 17
            blue = (int & 0xF) * 17

        case 6:
            alpha = 255
            red = int >> 16
            green = int >> 8 & 0xFF
            blue = int & 0xFF

        case 8:
            alpha = int >> 24
            red = int >> 16 & 0xFF
            green = int >> 8 & 0xFF
            blue = int & 0xFF

        default:
            alpha = 255
            red = 0
            green = 0
            blue = 0
        }

        self.init(
            red: CGFloat(red) / 255,
            green: CGFloat(green) / 255,
            blue: CGFloat(blue) / 255,
            alpha: CGFloat(alpha) / 255
        )
    }

    static let appBackgroundSky = SKColor(hex: "#C8FBFF")
    static let appSurface = SKColor(hex: "#FFF7E8")
    static let appSurfaceSecondary = SKColor(hex: "#DEECCC")
    static let appSurfaceMint = SKColor(hex: "#EAFBF5")
    static let appBorderSoft = SKColor(hex: "#BFE7E3")

    static let appTextPrimary = SKColor(hex: "#2F3550")
    static let appTextSecondary = SKColor(hex: "#445378")
    static let appTextMuted = SKColor(hex: "#6C7893")
    static let appTextOnDark = SKColor(hex: "#FFF7E8")

    static let appPrimaryBlue = SKColor(hex: "#48B2C6")
    static let appPrimaryHover = SKColor(hex: "#409E94")
    static let appPrimarySoft = SKColor(hex: "#82E5CE")

    static let appSuccess = SKColor(hex: "#59CB9A")
    static let appSuccessDark = SKColor(hex: "#058670")
    static let appWarning = SKColor(hex: "#E68F39")
    static let appDanger = SKColor(hex: "#B85743")
    static let appDangerSoft = SKColor(hex: "#F3C0B5")
    static let appInfoSoft = SKColor(hex: "#DDF7FB")

    static let appManualYellow = SKColor(hex: "#F8EE80")
    static let appManualOrange = SKColor(hex: "#E68F39")
    static let appAIBlue = SKColor(hex: "#48B2C6")
    static let appAIBlueSoft = SKColor(hex: "#DDF7FB")
    static let appAICyanGlow = SKColor(hex: "#82E5CE")

    static let appObedience = SKColor(hex: "#445378")
    static let appHumanity = SKColor(hex: "#59CB9A")
    static let appHumanitySoft = SKColor(hex: "#EAFBF5")

    static let appGlitchPurple = SKColor(hex: "#8E63C9")
    static let appCandyPink = SKColor(hex: "#F58BB5")

    static let appCreamWhite = SKColor(hex: "#FFF7E8")
    static let appCharcoalNavy = SKColor(hex: "#2F3550")

    static let appSkyBlue = SKColor(hex: "#C8FBFF")
    static let appSoftAqua = SKColor(hex: "#82E5CE")
    static let appMintGreen = SKColor(hex: "#59CB9A")
    static let appDeepTeal = SKColor(hex: "#058670")
    static let appSand = SKColor(hex: "#E1CE91")
    static let appWoodTan = SKColor(hex: "#D6B074")
    static let appWarmBrown = SKColor(hex: "#C27052")
    static let appDarkBrick = SKColor(hex: "#B85743")
    static let appSlateBlue = SKColor(hex: "#445378")
    static let appBrightBlue = SKColor(hex: "#48B2C6")
    static let appFlameOrange = SKColor(hex: "#E68F39")
    static let appGrapePurple = SKColor(hex: "#8E63C9")
}
