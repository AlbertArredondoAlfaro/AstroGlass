# AstroGlass Design

Date: 2026-02-10
Target: iOS 26+ only
Tech: 100% SwiftUI, Liquid Glass native APIs

## Summary
AstroGlass is a premium, highly visual horoscope app with a mystical dark aesthetic and strong glassmorphism. The app includes onboarding, weekly horoscope, all signs explorer, and profile with monetization (AdMob + StoreKit 2 remove-ads). Content is localized in five languages and rotates weekly.

## Goals
- Deliver a visually distinctive, production-ready iOS 26+ app with native Liquid Glass.
- Provide accurate-enough solar and rising sign calculations without external ephemeris.
- Support five localizations with prewritten poetic weekly horoscopes for all signs.
- Monetize via AdMob (banner + interstitial) and StoreKit 2 remove-ads.
- Schedule a weekly local notification every Monday at 10:00.

## Non-Goals
- No iOS 17–25 support.
- No external ephemeris SDKs.
- No backend services.

## Architecture
- SwiftUI app with `@Observable` app state and `@AppStorage` persistence.
- Modular structure: Models, Services, Views, Resources.
- Glass UI built with native `glassEffect` and `GlassEffectContainer`.

### Proposed Structure
- `AstroGlassApp.swift` (app entry)
- `AppState.swift` (global state and routing)
- `Models/` (UserProfile, ZodiacSign, City, Horoscope)
- `Services/`
  - `ZodiacCalculator` (sun sign)
  - `AscendantCalculator` (rising sign; LST + latitude)
  - `HoroscopeService` (weekly content lookup)
  - `NotificationScheduler` (weekly local notifications)
  - `PurchaseService` (StoreKit 2 entitlements)
  - `AdService` (AdMob banner + interstitial gating)
- `Views/` (Onboarding, Tabs, Weekly, Signs, Profile, components)
- `Resources/` (cities.json, Localizable.strings, assets)

## Data Flow
- Onboarding collects name, birth date, optional birth time, city.
- Profile encoded to JSON and saved via `@AppStorage`.
- Calculations performed on save and cached in profile.
- Weekly horoscope selected by `weekOfYear` and locale.

## Calculations
### Sun Sign
- Standard date range boundaries.

### Ascendant (Approximate)
1. Convert local birth time to UTC.
2. Compute GMST with standard formula.
3. Convert to local sidereal time by adding longitude.
4. Estimate ascendant from LST + latitude using a trigonometric approximation.

## UI/UX
- Dark mystical gradients (indigo/magenta/violet), starfield background.
- Heavy glassmorphism: rounded corners 24–36pt, blur, vibrancy.
- Smooth spring animations and `matchedGeometryEffect` transitions.
- Zodiac symbol as center focus with glow + subtle motion.
- Particle bursts on weekly horoscope open via `Canvas` + `TimelineView`.

### Tabs
1. **Esta semana**: hero glass card with sun+ascendant and weekly horoscope.
2. **Todos los signos**: grid of 12 glass cards and detail views.
3. **Perfil**: edit profile, notifications, remove-ads purchase.

## Monetization
- AdMob: adaptive banner fixed at bottom + interstitial once per day.
- ATT consent requested before loading ads.
- StoreKit 2 non-consumable `remove_ads` product.
- Entitlements drive ad visibility.

## Localization
- English, Spanish (es), Catalan (ca), French (fr), German (de).
- `String(localized:)` and `Localizable.strings`.
- Horoscope texts: prewritten poetic paragraphs per sign/language.

## Notifications
- Weekly local notification every Monday 10:00 local time.
- Language-specific body variants.

## Testing
- Unit tests for sign calculations and weekly horoscope rotation.
- UI snapshot checks for glass cards and onboarding.

## Risks
- AdMob requires UIKit wrappers for banner/interstitial.
- Ascendant is approximate without ephemeris SDK.

## Open Items
- Final asset pack (symbols/nebula textures).
- Final AdMob/IAP production IDs.
