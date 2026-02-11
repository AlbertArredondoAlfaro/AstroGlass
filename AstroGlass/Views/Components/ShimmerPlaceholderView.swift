import SwiftUI

struct ShimmerPlaceholderView: View {
    @State private var moveX: CGFloat = -220

    var body: some View {
        RoundedRectangle(cornerRadius: 24)
            .fill(.white.opacity(0.1))
            .overlay(
                LinearGradient(colors: [.clear, .white.opacity(0.4), .clear], startPoint: .top, endPoint: .bottom)
                    .rotationEffect(.degrees(24))
                    .offset(x: moveX)
            )
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .onAppear {
                withAnimation(.linear(duration: 1.8).repeatForever(autoreverses: false)) {
                    moveX = 240
                }
            }
    }
}
