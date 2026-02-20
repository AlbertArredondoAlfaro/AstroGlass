import Foundation
import Observation

@MainActor
@Observable
final class PurchaseService {
    var isPurchased = false
    var isLoading = false

    // IAP is intentionally disabled for this release.
    func bootstrap() async {}
    func loadProducts() async {}
    func purchase() async {}
    func restore() async {}
    func refreshEntitlements() async {}
}
