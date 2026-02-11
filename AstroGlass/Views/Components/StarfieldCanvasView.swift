import SwiftUI

struct StarfieldCanvasView: View {
    private let stars = Star.make(count: 140)

    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let t = timeline.date.timeIntervalSinceReferenceDate

                for star in stars {
                    let x = star.point.x * size.width
                    let y = star.point.y * size.height + sin(t * star.speed + star.phase) * 6
                    let rect = CGRect(x: x, y: y, width: star.size, height: star.size)
                    context.opacity = star.opacity
                    context.fill(Path(ellipseIn: rect), with: .color(.white))
                }
            }
        }
        .allowsHitTesting(false)
    }
}

private struct Star {
    let point: CGPoint
    let size: CGFloat
    let opacity: Double
    let speed: Double
    let phase: Double

    static func make(count: Int) -> [Star] {
        (0..<count).map { _ in
            Star(
                point: CGPoint(x: Double.random(in: 0...1), y: Double.random(in: 0...1)),
                size: Double.random(in: 0.8...2.2),
                opacity: Double.random(in: 0.25...0.9),
                speed: Double.random(in: 0.15...0.65),
                phase: Double.random(in: 0...(.pi * 2))
            )
        }
    }
}
