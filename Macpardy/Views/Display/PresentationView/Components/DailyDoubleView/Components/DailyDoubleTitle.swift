import SwiftUI

extension DailyDoubleView {
    @ViewBuilder
    func dailyDoubleTitle() -> some View {
        let title = Text("display.daily_double.title")
            .font(MacpardyTheme.dailyDoubleFont)
            .foregroundStyle(MacpardyTheme.gold)
            .multilineTextAlignment(.center)

        if animationsEnabled {
            title
                .keyframeAnimator(initialValue: DailyDoubleMotion(), content: { view, motion in
                    view
                        .scaleEffect(motion.scale)
                        .rotationEffect(.degrees(motion.tilt))
                        .shadow(color: MacpardyTheme.gold.opacity(motion.glow), radius: 40)
                }, keyframes: { _ in
                    KeyframeTrack(\.scale) {
                        SpringKeyframe(1.25, duration: 0.6, spring: .bouncy)
                        SpringKeyframe(1, duration: 0.5, spring: .smooth)
                    }
                    KeyframeTrack(\.tilt) {
                        CubicKeyframe(-6, duration: 0.3)
                        CubicKeyframe(4, duration: 0.4)
                        CubicKeyframe(0, duration: 0.4)
                    }
                    KeyframeTrack(\.glow) {
                        LinearKeyframe(1, duration: 0.6)
                        LinearKeyframe(0.3, duration: 0.9)
                    }
                })
        } else {
            title
        }
    }
}

/// Values the Daily Double title is animated through.
struct DailyDoubleMotion {
    var scale = 0.1
    var tilt = 0.0
    var glow = 0.0
}
