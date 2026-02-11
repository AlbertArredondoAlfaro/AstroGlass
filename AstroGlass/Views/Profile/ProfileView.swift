import SwiftUI

struct ProfileView: View {
    @Environment(AppModel.self) private var model
    @State private var showEdit = false

    var body: some View {
        ScrollView {
            VStack(spacing: AppTheme.Metrics.sectionSpacing) {
                if let profile = model.profile {
                    GlassCard(style: .profile) {
                        VStack(spacing: 10) {
                            Text(profile.name)
                                .font(AppTheme.Typography.title2)
                            Text(profile.cityName)
                                .foregroundStyle(.secondary)
                            HStack(spacing: 8) {
                                Text(String(localized: String.LocalizationValue(profile.sunSign.nameKey)))
                                Text("•")
                                Text(String(localized: String.LocalizationValue(profile.risingSign.nameKey)))
                            }
                            .foregroundStyle(.secondary)

                            Button(String(localized: "profile.edit")) {
                                showEdit = true
                            }
                            .buttonStyle(AstroGlassPrimaryButtonStyle())
                        }
                        .frame(maxWidth: .infinity)
                    }
                }

                GlassCard(style: .standard) {
                    VStack(alignment: .leading, spacing: 10) {
                        Toggle(String(localized: "profile.notifications"), isOn: Bindable(model).notificationsEnabled)
                        Text(String(localized: "profile.notifications.subtitle"))
                            .font(AppTheme.Typography.footnote)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                GlassCard(style: .standard) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text(String(localized: "profile.removeads.title"))
                            .font(AppTheme.Typography.headline)

                        if model.purchaseService.isPurchased {
                            Text(String(localized: "profile.removeads.active"))
                                .foregroundStyle(.secondary)
                        } else {
                            Text(String(localized: "profile.removeads.subtitle"))
                                .foregroundStyle(.secondary)
                            Button(String(localized: "profile.removeads.buy")) {
                                Task { await model.purchaseService.purchase() }
                            }
                            .buttonStyle(AstroGlassPrimaryButtonStyle())

                            Button(String(localized: "profile.removeads.restore")) {
                                Task { await model.purchaseService.restore() }
                            }
                            .buttonStyle(AstroGlassSecondaryButtonStyle())

                            Text((model.purchaseService.product?.displayPrice ?? String(localized: "profile.removeads.pricefallback")))
                                .font(AppTheme.Typography.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(AppTheme.Metrics.screenPadding)
        }
        .navigationTitle(String(localized: "profile.title"))
        .sheet(isPresented: $showEdit) {
            ProfileEditView()
                .environment(model)
        }
    }
}
