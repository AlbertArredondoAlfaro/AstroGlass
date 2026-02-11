import SwiftUI

struct AdBannerContainerView: View {
    let adUnitId: String

    var body: some View {
        VStack(spacing: 0) {
            Divider().opacity(0.2)
            AdBannerView(adUnitId: adUnitId)
                .frame(height: 60)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(.thinMaterial)
        }
    }
}
