import SwiftUI

struct ProfileEditView: View {
    @Environment(AppModel.self) private var model
    @Environment(\.dismiss) private var dismiss
    private let cityLookupService = CityLookupService()

    @State private var name = ""
    @State private var birthDate = Date()
    @State private var hasExactTime = false
    @State private var birthTime = Date()
    @State private var cityName = ""
    @State private var cityErrorKey: String?
    @State private var isResolvingCity = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.Metrics.cardStackSpacing) {
                    GlassCard(style: .standard) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(String(localized: "onboarding.title.name"))
                            TextField(String(localized: "onboarding.placeholder.name"), text: $name)
                                .padding(12)
                                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: AppTheme.Metrics.fieldCornerRadius))
                        }
                    }

                    GlassCard(style: .standard) {
                        DatePicker("", selection: $birthDate, displayedComponents: .date)
                            .datePickerStyle(.graphical)
                            .labelsHidden()
                    }

                    GlassCard(style: .standard) {
                        Toggle(String(localized: "onboarding.toggle.time"), isOn: $hasExactTime)
                        if hasExactTime {
                            DatePicker("", selection: $birthTime, displayedComponents: .hourAndMinute)
                                .datePickerStyle(.wheel)
                                .labelsHidden()
                                .frame(maxHeight: 150)
                        }
                    }

                    GlassCard(style: .standard) {
                        VStack(spacing: 10) {
                            TextField(String(localized: "onboarding.placeholder.city"), text: $cityName)
                                .padding(12)
                                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: AppTheme.Metrics.fieldCornerRadius))
                                .submitLabel(.done)
                                .onSubmit {
                                    Task { await save() }
                                }

                            Text(String(localized: "onboarding.city.helper"))
                                .font(AppTheme.Typography.footnote)
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)

                            if isResolvingCity {
                                HStack(spacing: 8) {
                                    ProgressView()
                                    Text(String(localized: "onboarding.city.loading"))
                                }
                                .font(AppTheme.Typography.footnote)
                                .foregroundStyle(.secondary)
                            }

                            if let cityErrorKey {
                                Text(String(localized: String.LocalizationValue(cityErrorKey)))
                                    .font(AppTheme.Typography.footnote)
                                    .foregroundStyle(.red.opacity(0.9))
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                }
                .padding(AppTheme.Metrics.screenPadding)
            }
            .navigationTitle(String(localized: "profile.edit"))
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(String(localized: "action.cancel")) { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(String(localized: "action.save")) {
                        Task { await save() }
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || cityName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isResolvingCity)
                }
            }
            .onAppear(perform: load)
        }
    }

    private func load() {
        guard let profile = model.profile else { return }
        name = profile.name
        birthDate = profile.birthDate
        if let bt = profile.birthTime {
            hasExactTime = true
            birthTime = Calendar.current.date(from: DateComponents(hour: bt.hour, minute: bt.minute)) ?? Date()
        }
        cityName = profile.cityName
    }

    private func save() async {
        guard !isResolvingCity else { return }
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        guard !cityName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        cityErrorKey = nil
        isResolvingCity = true
        defer { isResolvingCity = false }

        do {
            let city = try await cityLookupService.resolveCity(named: cityName)
            let bt = hasExactTime ? birthTime.toBirthTime : nil
            model.updateProfile(name: name, birthDate: birthDate, birthTime: bt, city: city)
            dismiss()
        } catch let error as CityLookupService.LookupError {
            cityErrorKey = error.localizedKey
        } catch {
            cityErrorKey = CityLookupService.LookupError.unknown.localizedKey
        }
    }
}
