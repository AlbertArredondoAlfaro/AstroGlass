import SwiftUI

struct CosmicBackgroundView: View {
    var body: some View {
        ZStack {
            Image("CosmicBackground")
                .resizable()
                .scaledToFill()

            RadialGradient(
                colors: [AppTheme.Colors.nebulaViolet.opacity(0.35), .clear],
                center: .topTrailing,
                startRadius: 20,
                endRadius: 480
            )

            Circle()
                .fill(AppTheme.Colors.nebulaIndigo.opacity(0.22))
                .frame(width: 540, height: 540)
                .blur(radius: 90)
                .offset(x: 180, y: -250)

            Circle()
                .fill(AppTheme.Colors.nebulaBlue.opacity(0.18))
                .frame(width: 460, height: 460)
                .blur(radius: 80)
                .offset(x: -160, y: 260)

            StarfieldCanvasView()
        }
        .ignoresSafeArea()
    }
}
