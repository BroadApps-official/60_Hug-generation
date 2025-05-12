import SwiftUI
import Combine
import ApphudSDK

@MainActor
class SubscriptionManager: ObservableObject {
    static let shared = SubscriptionManager()
    @Published var productsApphud: [ApphudProduct] = []
    @Published var avatarsApphud: [ApphudProduct] = []
    @Published var isSubscribed: Bool = false
    @Published var isSubscriptionStatusChecked = false
    
    private let paywallID = "main"
    private let avatarPaywallID = "avatar_trial"
    let buyPublisher = PassthroughSubject<Bool, Never>()
    
    private init() {
        loadProducts()
        loadAvatars()
        checkSubscriptionStatus()
    }
    
    private func loadProducts() {
        Apphud.paywallsDidLoadCallback { paywalls, error in
            if let paywall = paywalls.first(where: { $0.identifier == self.paywallID }) {
                Apphud.paywallShown(paywall)
                let products = paywall.products
                print("✅ Paywall ID: \(self.paywallID), Products: \(products.map { $0.productId })")
                self.productsApphud = products
            } else {
                print("❌ Paywall with id \(self.paywallID) not found")
            }
        }
    }
    
    private func loadAvatars() {
        Apphud.paywallsDidLoadCallback { paywalls, error in
            if let paywall = paywalls.first(where: { $0.identifier == self.avatarPaywallID }) {
                Apphud.paywallShown(paywall)
                let products = paywall.products
                print("✅ Paywall ID: \(self.avatarPaywallID), Products: \(products.map { $0.productId })")
                self.avatarsApphud = products
            } else {
                print("❌ Paywall with id \(self.avatarPaywallID) not found")
            }
        }
    }
    
    func checkSubscriptionStatus() {
        Task {
            let result = await Apphud.hasPremiumAccess()
            DispatchQueue.main.async {
                self.isSubscribed = result
                self.isSubscriptionStatusChecked = true
            }
        }
    }
    
    func startPurchase(product: ApphudProduct, escaping: @escaping (Bool) -> Void) {
        Apphud.purchase(product, callback: { [weak self] result in
            guard let self = self else { return }
            
            if let error = result.error {
                print("❌ Error: \(error.localizedDescription)")
                self.buyPublisher.send(false)
                escaping(false)
                return
            }
            
            if let subscription = result.subscription, subscription.isActive() {
                DispatchQueue.main.async {
                    self.isSubscribed = true
                }
                self.buyPublisher.send(true)
                escaping(true)
                return
            }
            
            if let purchase = result.nonRenewingPurchase, purchase.isActive() {
                self.buyPublisher.send(true)
                escaping(true)
                return
            }
            
            if Apphud.hasActiveSubscription() {
                DispatchQueue.main.async {
                    self.isSubscribed = true
                }
                self.buyPublisher.send(true)
                escaping(true)
                return
            }
            
            self.buyPublisher.send(false)
            escaping(false)
        })
    }
    
    func restorePurchases(completion: @escaping (Bool) -> Void) {
        Apphud.restorePurchases { subscriptions, _, error in
            if let error = error {
                print("❌ Error restore \(error.localizedDescription)")
                completion(false)
                return
            }
            
            if subscriptions?.first?.isActive() ?? false || Apphud.hasActiveSubscription() {
                DispatchQueue.main.async {
                    self.isSubscribed = true
                    completion(true)
                }
            } else {
                completion(false)
            }
        }
    }
    
    func getWeeklyPrice(for productId: String) -> String {
        guard let product = productsApphud.first(where: { $0.skProduct?.productIdentifier == productId }) else {
            return "Loading..."
        }
        guard let skProduct = product.skProduct else {
            return "N/A"
        }
        
        let price = skProduct.price
        let currencySymbol = skProduct.priceLocale.currencySymbol ?? "$"
        
        if productId.contains("year") {
            let weeklyPrice = price.doubleValue / 52.0
            let weeklyPriceString = "\(currencySymbol)\(String(format: "%.2f", weeklyPrice))"
            print("✅ Weekly Price for \(productId): \(weeklyPriceString)")
            return weeklyPriceString
        } else {
            let priceString = "\(currencySymbol)\(price)"
            print("✅ Price for \(productId): \(priceString)")
            return priceString
        }
    }
    
    func getProductPrice(for productId: String) -> String {
        guard let product = productsApphud.first(where: { $0.skProduct?.productIdentifier == productId }) else {
            return "Loading..."
        }
        guard let skProduct = product.skProduct else {
            return "N/A"
        }
        let price = skProduct.price
        let priceString = "\(skProduct.priceLocale.currencySymbol ?? "$")\(price)"
        print("✅ Price is \(productId): \(priceString)")
        return priceString
    }
    
    func getAvatarPrice(for productId: String) -> String {
        guard let product = avatarsApphud.first(where: { $0.skProduct?.productIdentifier == productId }) else {
            return "Loading..."
        }
        guard let skProduct = product.skProduct else {
            return "N/A"
        }
        let price = skProduct.price
        let priceString = "\(skProduct.priceLocale.currencySymbol ?? "$")\(price)"
        print("✅ Price is \(productId): \(priceString)")
        return priceString
    }

}
