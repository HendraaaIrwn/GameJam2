import CoreGraphics
import CoreMotion

final class MotionBalanceInput {
    private nonisolated(unsafe) let motionManager = CMMotionManager()
    private(set) var latestTiltX: CGFloat = 0
    private(set) var isMotionAvailable = false

    deinit {
        motionManager.stopDeviceMotionUpdates()
        motionManager.stopAccelerometerUpdates()
    }

    func start() {
        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 1.0 / 60.0
            motionManager.startDeviceMotionUpdates()
            isMotionAvailable = true
        } else if motionManager.isAccelerometerAvailable {
            motionManager.accelerometerUpdateInterval = 1.0 / 60.0
            motionManager.startAccelerometerUpdates()
            isMotionAvailable = true
        } else {
            isMotionAvailable = false
        }
    }

    func update() {
        let rawTilt: CGFloat?
        if let motion = motionManager.deviceMotion {
            rawTilt = CGFloat(motion.attitude.roll)
        } else if let acceleration = motionManager.accelerometerData?.acceleration {
            rawTilt = CGFloat(acceleration.x)
        } else {
            rawTilt = nil
        }

        guard let rawTilt else { return }
        let nextTilt = rawTilt.clamped(to: -1...1)
        latestTiltX = latestTiltX * 0.85 + nextTilt * 0.15
    }

    func stop() {
        motionManager.stopDeviceMotionUpdates()
        motionManager.stopAccelerometerUpdates()
        latestTiltX = 0
    }
}

private extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}
