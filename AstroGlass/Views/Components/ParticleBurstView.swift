import SwiftUI

struct ParticleBurstView: View {
    let trigger: Int
    @State private var start = Date().timeIntervalSinceReferenceDate
    private let particles = Burst.make(count: 72)

    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let elapsed = timeline.date.timeIntervalSinceReferenceDate - start
                guard elapsed < 1.6 else { return }

                for p in particles {
                    let progress = min(elapsed / p.duration, 1)
                    let distance = p.speed * progress
                    let x = size.width / 2 + cos(p.angle) * distance
                    let y = size.height / 2 + sin(p.angle) * distance
                    let alpha = (1 - progress) * p.opacity
                    context.opacity = alpha
                    context.fill(Path(ellipseIn: CGRect(x: x, y: y, width: p.size, height: p.size)), with: .color(.white))
                }
            }
        }
        .onChange(of: trigger) { _, _ in
            start = Date().timeIntervalSinceReferenceDate
        }
        .allowsHitTesting(false)
    }
}

private struct Burst {
    let angle: Double
    let speed: Double
    let size: CGFloat
    let opacity: Double
    let duration: Double

    static func make(count: Int) -> [Burst] {
        (0..<count).map { _ in
            Burst(
                angle: Double.random(in: 0...(.pi * 2)),
                speed: Double.random(in: 30...170),
                size: Double.random(in: 1.5...4.5),
                opacity: Double.random(in: 0.35...1),
                duration: Double.random(in: 0.75...1.45)
            )
        }
    }
}
