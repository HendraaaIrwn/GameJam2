import SwiftUI

struct FlashlightOverlayView: View {
    let center: CGPoint
    let radius: CGFloat
    let opacity: Double

    var body: some View {
        Rectangle()
            .fill(Color.black.opacity(opacity))
            .mask {
                Canvas { context, size in
                    var path = Path(CGRect(origin: .zero, size: size))
                    path.addEllipse(in: CGRect(
                        x: center.x - radius,
                        y: center.y - radius,
                        width: radius * 2,
                        height: radius * 2
                    ))
                    context.fill(path, with: .color(.white), style: FillStyle(eoFill: true))
                }
            }
    }
}
