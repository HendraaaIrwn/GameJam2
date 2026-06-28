import SwiftUI

struct HomeView: View {
    let startGame: () -> Void

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Image("titleScreenBackground")
                    .resizable()
                    .scaledToFill()
                    .frame(
                        width: geometry.size.width,
                        height: geometry.size.height,
                        alignment: .center
                    )
                    .clipped()
                    .ignoresSafeArea()

                HomeCloudLayer(size: geometry.size)

                VStack {
                    Spacer()
                        .frame(maxHeight: 148)

                    Image("homeTitle")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: min(geometry.size.width - 120, 420))
                        .padding(.bottom, 84)

                    AppButton("Start", action: startGame)
                        .frame(maxWidth: 180)
                        .padding(.horizontal, 32)
//                        .padding(.bottom, 200)

                    Spacer()
                }
                .zIndex(1)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .ignoresSafeArea()
    }
}

private struct HomeCloudLayer: View {
    let size: CGSize

    var body: some View {
        ZStack {
            MovingCloud(screenWidth: size.width, width: 150, y: size.height * 0.08, duration: 22, movesRight: true, delay: 0)
            MovingCloud(screenWidth: size.width, width: 230, y: size.height * 0.17, duration: 30, movesRight: false, delay: -8)
            MovingCloud(screenWidth: size.width, width: 120, y: size.height * 0.28, duration: 20, movesRight: false, delay: -3)
            MovingCloud(screenWidth: size.width, width: 190, y: size.height * 0.36, duration: 26, movesRight: true, delay: -12)
        }
        .frame(width: size.width, height: size.height, alignment: .topLeading)
        .clipped()
        .allowsHitTesting(false)
    }
}

private struct MovingCloud: View {
    let screenWidth: CGFloat
    let width: CGFloat
    let y: CGFloat
    let duration: TimeInterval
    let movesRight: Bool
    let delay: TimeInterval

    var body: some View {
        TimelineView(.animation) { timeline in
            let progress = Self.progress(at: timeline.date, duration: duration, delay: delay)
            let startX = movesRight ? -width : screenWidth + width
            let endX = movesRight ? screenWidth + width : -width
            let x = startX + (endX - startX) * progress

            Image("homeCloud")
                .resizable()
                .frame(width: width, height: width * 0.37)
                .opacity(0.9)
                .position(x: x, y: y)
        }
    }

    private static func progress(at date: Date, duration: TimeInterval, delay: TimeInterval) -> CGFloat {
        let shiftedTime = date.timeIntervalSinceReferenceDate + delay
        let cycleTime = shiftedTime.truncatingRemainder(dividingBy: duration)
        return CGFloat(cycleTime / duration)
    }
}

#Preview {
    HomeView(startGame: {})
}
