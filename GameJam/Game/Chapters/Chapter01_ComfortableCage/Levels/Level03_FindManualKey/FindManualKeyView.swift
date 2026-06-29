import SwiftUI
import UIKit

struct FindManualKeyView: View {
    @State private var viewModel = FindManualKeyViewModel()
    let onComplete: (LevelResult) -> Void

    var body: some View {
        GeometryReader { geo in
            ZStack {
                FindManualKeyLevelConfig.backgroundColor

                tableLayer(in: geo)

                itemsLayer(in: geo)

                FlashlightOverlayView(
                    center: CGPoint(
                        x: geo.size.width * viewModel.flashlightPosition.x,
                        y: geo.size.height * viewModel.flashlightPosition.y
                    ),
                    radius: min(geo.size.width, geo.size.height) * FindManualKeyLevelConfig.flashlightRadiusRatio,
                    opacity: FindManualKeyLevelConfig.darknessOpacity
                )
                .allowsHitTesting(false)

                feedbackLabel(in: geo)

                timerBar(in: geo)
            }
            .gesture(gameGesture(in: geo))
            .onAppear {
                viewModel.onComplete = onComplete
                viewModel.startLevel()
            }
            .onDisappear {
                viewModel.stopLevel()
            }
        }
        .ignoresSafeArea()
    }

    private func tableLayer(in geo: GeometryProxy) -> some View {
        Group {
            if UIImage(named: "Meja") != nil {
                Image("Meja")
                    .resizable()
                    .scaledToFit()
            } else {
                RoundedRectangle(cornerRadius: 28)
                    .fill(Color.brown.opacity(0.8))
                    .overlay(Text("TABLE").font(.custom(GameFont.heavy, size: 24)).foregroundColor(.white))
            }
        }
        .frame(width: geo.size.width * FindManualKeyLevelConfig.tableWidthRatio)
        .position(
            x: geo.size.width * FindManualKeyLevelConfig.tablePosition.x,
            y: geo.size.height * FindManualKeyLevelConfig.tablePosition.y
        )
        .accessibilityLabel("Table")
    }

    private func itemsLayer(in geo: GeometryProxy) -> some View {
        ForEach(viewModel.items) { item in
            itemView(item, in: geo)
        }
    }

    private func itemView(_ item: ManualKeyItem, in geo: GeometryProxy) -> some View {
        ZStack {
            if item.type == .smartKey {
                BlueKeySonarView()
                    .frame(width: item.size.width * 1.9, height: item.size.width * 1.9)
            }

            Group {
                if UIImage(named: item.assetName) != nil {
                    Image(item.assetName)
                        .resizable()
                        .scaledToFit()
                } else {
                    Text(item.fallbackTitle)
                        .font(.custom(GameFont.heavy, size: 13))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.6)
                        .padding(6)
                        .background(AppColor.appGrapePurple)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
            .frame(width: item.size.width, height: item.size.height)
        }
        .position(x: geo.size.width * item.position.x, y: geo.size.height * item.position.y)
        .opacity(viewModel.opacity(for: item))
        .animation(.easeOut(duration: 0.12), value: viewModel.flashlightPosition)
        .accessibilityLabel(item.fallbackTitle)
    }

    private func feedbackLabel(in geo: GeometryProxy) -> some View {
        Text(viewModel.feedbackMessage)
            .font(.custom(GameFont.heavy, size: 21))
            .foregroundColor(viewModel.feedbackColor)
            .multilineTextAlignment(.center)
            .lineLimit(2)
            .minimumScaleFactor(0.7)
            .frame(maxWidth: geo.size.width * 0.9)
            .position(x: geo.size.width / 2, y: geo.size.height * 0.56)
    }

    private func timerBar(in geo: GeometryProxy) -> some View {
        let width = geo.size.width * 0.92
        let height: CGFloat = 24

        return ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: height / 2)
                .fill(Color.white.opacity(0.3))

            RoundedRectangle(cornerRadius: height / 2)
                .fill(viewModel.isWarning ? AppColor.danger : AppColor.success)
                .frame(width: width * max(0, min(1, viewModel.timerProgress)))
                .animation(.linear(duration: 0.05), value: viewModel.timerProgress)
        }
        .frame(width: width, height: height)
        .position(x: geo.size.width / 2, y: geo.size.height - 54)
    }

    private func gameGesture(in geo: GeometryProxy) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                viewModel.moveFlashlight(to: normalized(value.location, in: geo))
            }
            .onEnded { value in
                let distance = hypot(value.translation.width, value.translation.height)
                if distance < 8 {
                    viewModel.confirmSelection()
                }
            }
    }

    private func normalized(_ point: CGPoint, in geo: GeometryProxy) -> CGPoint {
        CGPoint(x: point.x / geo.size.width, y: point.y / geo.size.height)
    }
}

private struct BlueKeySonarView: View {
    @State private var pulse = false

    var body: some View {
        ZStack {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .stroke(Color.cyan.opacity(pulse ? 0 : 0.75), lineWidth: 3)
                    .scaleEffect(pulse ? 1.15 + CGFloat(index) * 0.26 : 0.35 + CGFloat(index) * 0.12)
                    .animation(
                        .easeOut(duration: 1.15)
                        .repeatForever(autoreverses: false)
                        .delay(Double(index) * 0.22),
                        value: pulse
                    )
            }
        }
        .onAppear { pulse = true }
    }
}

#Preview("Find Manual Key") {
    FindManualKeyView { result in
        print("Level completed:", result)
    }
}
