import Foundation
import Observation
import StoreKit

@MainActor
@Observable
final class PurchaseService {
    private let defaults = UserDefaults.standard
    private let productId = "com.idreamstudios.astroglass.removeads"

    var product: Product?
    var isPurchased: Bool
    var isLoading = false

    init() {
        isPurchased = defaults.bool(forKey: DefaultsKeys.removeAdsPurchased)
        Task {
            await observeTransactions()
        }
    }

    func bootstrap() async {
        await loadProducts()
        await refreshEntitlements()
    }

    func loadProducts() async {
        do {
            product = try await Product.products(for: [productId]).first
        } catch {
            product = nil
        }
    }

    func purchase() async {
        guard let product else { return }

        isLoading = true
        defer { isLoading = false }

        do {
            let result = try await product.purchase()
            if case .success(let verification) = result,
               case .verified(let transaction) = verification {
                await transaction.finish()
                await refreshEntitlements()
            }
        } catch {
            return
        }
    }

    func restore() async {
        await refreshEntitlements()
    }

    func refreshEntitlements() async {
        var hasRemoveAds = false

        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result,
               transaction.productID == productId,
               transaction.revocationDate == nil {
                hasRemoveAds = true
            }
        }

        isPurchased = hasRemoveAds
        defaults.set(hasRemoveAds, forKey: DefaultsKeys.removeAdsPurchased)
    }

    private func observeTransactions() async {
        for await update in Transaction.updates {
            if case .verified(let transaction) = update,
               transaction.productID == productId {
                await transaction.finish()
                await refreshEntitlements()
            }
        }
    }
}
