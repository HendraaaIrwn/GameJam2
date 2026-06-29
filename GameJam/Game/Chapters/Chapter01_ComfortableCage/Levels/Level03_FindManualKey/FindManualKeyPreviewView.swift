import SwiftUI
import SpriteKit

@available(iOS 17.0, *)
struct FindManualKeyPreviewView: View {
    @State private var sceneID = UUID()
    @State private var showHitboxes = false
    @State private var showNames = true
    @State private var showSafeArea = false
    @State private var lastTap: String = "—"

    private let sceneSize = CGSize(width: 390, height: 844)

    var body: some View {
        ZStack(alignment: .bottom) {
            backgroundFill

            GeometryReader { geo in
                let scale = min(geo.size.width / sceneSize.width, geo.size.height / sceneSize.height) * 0.95
                let renderWidth = sceneSize.width * scale
                let renderHeight = sceneSize.height * scale

                ZStack(alignment: .top) {
                    SpriteView(scene: makeScene())
                        .id(sceneID)
                        .frame(width: sceneSize.width, height: sceneSize.height)
                        .scaleEffect(scale, anchor: .center)
                        .frame(width: renderWidth, height: renderHeight)

                    debugOverlay
                        .frame(width: sceneSize.width, height: sceneSize.height)
                        .scaleEffect(scale, anchor: .center)
                        .frame(width: renderWidth, height: renderHeight)
                }
                .frame(width: renderWidth, height: renderHeight)
                .position(x: geo.size.width / 2, y: (geo.size.height - 220) / 2 + 20)
                .overlay(alignment: .center) {
                    Color.clear
                        .contentShape(Rectangle())
                        .gesture(
                            SpatialTapGesture()
                                .onEnded { value in
                                    let localX = value.location.x
                                    let localY = value.location.y
                                    lastTap = String(format: "(%.0f, %.0f)", localX, localY)
                                }
                        )
                }
            }

            bottomSheet
        }
        .ignoresSafeArea(edges: .bottom)
    }

    private var backgroundFill: some View {
        LinearGradient(
            colors: [Color(white: 0.18), Color(white: 0.08)],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    private var debugOverlay: some View {
        ZStack(alignment: .topLeading) {
            if showHitboxes {
                ForEach(itemLabels, id: \.name) { item in
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(item.color, lineWidth: 2)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(item.color.opacity(0.12))
                        )
                        .frame(width: item.hitboxSize.width, height: item.hitboxSize.height)
                        .position(item.position)
                }
                ForEach(zoneLabels, id: \.name) { zone in
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(zone.color, style: StrokeStyle(lineWidth: 2, dash: [4, 4]))
                        .frame(width: zone.size.width, height: zone.size.height)
                        .position(zone.position)
                }
            }

            if showNames {
                ForEach(itemLabels, id: \.name) { item in
                    Text("\(item.emoji) \(item.name)")
                        .font(.system(size: 8, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .background(
                            Capsule().fill(item.color.opacity(0.85))
                        )
                        .position(x: item.position.x, y: item.position.y - 36)
                }
                ForEach(zoneLabels, id: \.name) { zone in
                    Text(zone.name)
                        .font(.system(size: 7, weight: .heavy, design: .monospaced))
                        .foregroundColor(.white)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .background(
                            Capsule().fill(zone.color.opacity(0.85))
                        )
                        .position(x: zone.position.x, y: zone.position.y - (zone.size.height / 2 + 14))
                }
            }

            if showSafeArea {
                VStack(spacing: 0) {
                    Rectangle()
                        .fill(Color.red.opacity(0.18))
                        .frame(height: 50)
                        .overlay(
                            Text("STATUS BAR")
                                .font(.system(size: 8, weight: .bold, design: .monospaced))
                                .foregroundColor(.red)
                        )
                    Spacer()
                    Rectangle()
                        .fill(Color.red.opacity(0.18))
                        .frame(height: 34)
                        .overlay(
                            Text("HOME")
                                .font(.system(size: 8, weight: .bold, design: .monospaced))
                                .foregroundColor(.red)
                        )
                }
            }
        }
        .allowsHitTesting(false)
    }

    private var bottomSheet: some View {
        VStack(spacing: 8) {
            HStack {
                Text("CH 1 · LV 3 · Find The Manual Key")
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                Spacer()
                Text("Last tap: \(lastTap)")
                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                    .foregroundColor(.white.opacity(0.7))
            }

            HStack(spacing: 8) {
                toggleChip("Hitboxes", $showHitboxes, color: .green)
                toggleChip("Names", $showNames, color: .blue)
                toggleChip("Safe Area", $showSafeArea, color: .red)
                Spacer()
                Button {
                    sceneID = UUID()
                    lastTap = "—"
                } label: {
                    Text("RESET")
                        .font(.system(size: 11, weight: .heavy, design: .monospaced))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.orange)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }

            HStack(spacing: 6) {
                ForEach(itemLegend, id: \.name) { entry in
                    HStack(spacing: 4) {
                        Circle()
                            .fill(entry.color)
                            .frame(width: 8, height: 8)
                        Text(entry.name)
                            .font(.system(size: 9, weight: .semibold, design: .monospaced))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(
                        Capsule().fill(Color.white.opacity(0.08))
                    )
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 0)
                .fill(Color(white: 0.05))
                .opacity(0.95)
        )
        .overlay(alignment: .top) {
            Rectangle()
                .fill(Color.white.opacity(0.2))
                .frame(height: 0.5)
        }
    }

    private func toggleChip(_ title: String, _ binding: Binding<Bool>, color: Color) -> some View {
        Button {
            binding.wrappedValue.toggle()
        } label: {
            Text(title)
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundColor(binding.wrappedValue ? .black : .white)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(
                    Capsule().fill(binding.wrappedValue ? color : Color.white.opacity(0.15))
                )
        }
        .buttonStyle(.plain)
    }

    private func makeScene() -> FindManualKeyScene {
        let scene = FindManualKeyScene(size: sceneSize)
        scene.scaleMode = .resizeFill
        return scene
    }

    private struct ItemLabel {
        let name: String
        let emoji: String
        let position: CGPoint
        let color: Color
        let hitboxSize: CGSize
    }

    private struct ZoneLabel {
        let name: String
        let position: CGPoint
        let size: CGSize
        let color: Color
    }

    private struct ItemLegend {
        let name: String
        let color: Color
    }

    private let itemLabels: [ItemLabel] = {
        let mejaCenterX: CGFloat = 390 * 0.5
        let mejaCenterY: CGFloat = 844 * 0.28
        let mejaSize: CGFloat = 253
        let mejaOriginX = mejaCenterX - mejaSize / 2
        let mejaOriginY = mejaCenterY - mejaSize / 2
        let surfaceOriginY = mejaOriginY + mejaSize * 0.16
        let surfaceHeight = mejaSize * 0.66
        let sceneHeight: CGFloat = 844

        func toSwiftUI(_ spriteKitPoint: CGPoint) -> CGPoint {
            CGPoint(
                x: spriteKitPoint.x,
                y: sceneHeight - spriteKitPoint.y
            )
        }

        func spritePos(_ relX: CGFloat, _ relY: CGFloat) -> CGPoint {
            CGPoint(
                x: mejaOriginX + mejaSize * (relX + 0.5),
                y: surfaceOriginY + surfaceHeight * (relY + 0.5) + 4
            )
        }

        func pos(_ relX: CGFloat, _ relY: CGFloat) -> CGPoint {
            toSwiftUI(spritePos(relX, relY))
        }

        func hitbox(_ baseW: CGFloat, _ baseH: CGFloat) -> CGSize {
            CGSize(width: max(baseW + 20, 88), height: max(baseH + 20, 88))
        }

        return [
            ItemLabel(name: "Kabel Rusak", emoji: "🔌", position: pos(-0.32, 0.55), color: .gray, hitboxSize: hitbox(78, 54)),
            ItemLabel(name: "Foto Lama", emoji: "🖼️", position: pos(-0.04, 0.62), color: .cyan, hitboxSize: hitbox(60, 72)),
            ItemLabel(name: "Chip Merah", emoji: "🔴", position: pos(0.32, 0.50), color: .red, hitboxSize: hitbox(56, 56)),
            ItemLabel(name: "Smart Key", emoji: "💳", position: pos(-0.30, 0.10), color: .blue, hitboxSize: hitbox(78, 56)),
            ItemLabel(name: "Mainan Boneka", emoji: "🤖", position: pos(0.30, 0.12), color: .purple, hitboxSize: hitbox(66, 78)),
            ItemLabel(name: "Kunci Fisik", emoji: "🗝️", position: pos(0.10, -0.15), color: .yellow, hitboxSize: hitbox(70, 70))
        ]
    }()

    private let zoneLabels: [ZoneLabel] = {
        let sceneHeight: CGFloat = 844
        func sky(_ y: CGFloat) -> CGPoint {
            CGPoint(x: 195, y: sceneHeight - y)
        }
        return [
            ZoneLabel(name: "AI SCREEN", position: sky(844 * 0.78), size: CGSize(width: 140, height: 64), color: .blue),
            ZoneLabel(name: "AI HINT BTN", position: sky(844 * 0.68), size: CGSize(width: 168, height: 48), color: .indigo),
            ZoneLabel(name: "FEEDBACK", position: sky(844 * 0.56), size: CGSize(width: 320, height: 30), color: .purple)
        ]
    }()

    private let itemLegend: [ItemLegend] = [
        ItemLegend(name: "Kabel Rusak", color: .gray),
        ItemLegend(name: "Foto Lama", color: .cyan),
        ItemLegend(name: "Chip Merah", color: .red),
        ItemLegend(name: "Smart Key", color: .blue),
        ItemLegend(name: "Mainan Boneka", color: .purple),
        ItemLegend(name: "Kunci Fisik", color: .yellow)
    ]
}

@available(iOS 17.0, *)
#Preview("Chapter 1 · Level 3 · Find The Manual Key") {
    FindManualKeyPreviewView()
        .preferredColorScheme(.dark)
}
