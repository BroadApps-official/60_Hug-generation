import SwiftUI

struct AvatarPayWall: View {
    
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var subscriptionManager = SubscriptionManager.shared

    @State private var showCloseButton = false
    @State private var isPurchasing = false
    @State private var subscriptionPlans: [SubscriptionPlansAvatar] = []
    @State private var selectedPlan: SubscriptionPlansAvatar?
    @State private var restoreAlert: Bool = false
    @State private var restoreMessage: String = ""
    
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.backgroundPrimary
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    
                    ZStack {
                        
                        VStack {
                            
                            Image("AvatarPaywallImage")
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity)
                                .edgesIgnoringSafeArea(.all)
                            
                            Spacer()
                        }
                        
                        VStack {
                            Spacer()
                            
                            Image("backgroundShadow")
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity)
                                .edgesIgnoringSafeArea(.all)
                        }
                        
                        VStack() {
                            
                            Spacer()
                            
                            VStack(spacing: 0) {
                                HStack {
                                    Text("Avatars available at one time:")
                                        .font(.footnoteRegular)
                                        .foregroundColor(.labelSecondary)
                                    
                                    Text("1")
                                        .font(.subheadlineEmphasized)
                                        .foregroundColor(.labelPrimary)
                                }
                                
                                
                                Text("Create more avatars")
                                    .font(.title1Emphasized)
                                    .foregroundColor(.labelPrimary)
                                    .padding(.vertical, 10)
                                
                                Text("Buy extra avatars")
                                    .font(.footnoteRegular)
                                    .foregroundColor(.labelSecondary)
                                
                            }
                            .frame(height: 95)
                            
                            Spacer()
                                .frame(height: 30)
                            
                            VStack(spacing: 12) {
                                ForEach(subscriptionPlans, id: \.productId) { plan in
                                    SubscriptionButtonAvatar(plan: plan, selectedPlan: $selectedPlan)
                                }
                            }
                            
                            Spacer()
                                .frame(height: 30)
                        }
                    }
                    
                    
                    VStack(spacing: 0) {
                        
                        Button {
                            purchaseSubscription()
                        } label: {
                            Text("Continue")
                                .foregroundColor(.labelPrimary)
                                .font(.bodyEmphasized)
                                .frame(height: 48)
                                .frame(maxWidth: .infinity)
                                .background(Color.accentPrimary)
                                .cornerRadius(12)
                                .padding(.horizontal)
                        }
                        .disabled(isPurchasing)
                        
                        HStack {
                            
                            Button {
                                UIApplication.shared.open(URL(string: "https://docs.google.com/document/d/17pLhC6Wj7PeDZLwdCTLwgljnmfFBf55YWzqbRRa2DCA/edit?usp=sharing")!)
                            } label: {
                                Text("Privacy Policy")
                                    .foregroundColor(.labelQuaternary)
                                    .font(.caption2Regular)
                            }
                            
                            Spacer()
                            
                            Button {
                                restorePurchases()
                            } label: {
                                Text("Restore Purchases")
                                    .foregroundColor(.labelTertiary)
                                    .font(.caption1Regular)
                            }
                            
                            Spacer()
                            
                            Button {
                                UIApplication.shared.open(URL(string: "https://docs.google.com/document/d/12FPPVshMhVRK9L2wyfeU1eAUNqTA6A8K8smulJGIZy4/edit?usp=sharing")!)
                            } label: {
                                Text("Terms of Use")
                                    .foregroundColor(.labelQuaternary)
                                    .font(.caption2Regular)
                            }
                            
                        }
                        .frame(height: 44)
                        .padding(.horizontal)
                    }
                }
            }
            .navigationBarItems(
                trailing:
                    closeButton
                    .opacity(showCloseButton ? 1 : 0)
                    .animation(.easeIn(duration: 1), value: showCloseButton)
            )
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    showCloseButton = true
                }
                
                let plans = SubscriptionPlansAvatar.from(productIds: subscriptionManager.avatarsApphud.map(\.productId))
                    subscriptionPlans = plans
                
                selectedPlan = plans.first
                
            }
            .onChange(of: subscriptionManager.avatarsApphud) { newProducts in
                let plans = SubscriptionPlansAvatar.from(productIds: newProducts.map(\.productId))
                subscriptionPlans = plans
                
                if selectedPlan == nil {                    
                    selectedPlan = plans.first
                }
            }
            .alert(isPresented: $restoreAlert) {
                Alert(title: Text("Restore Purchases"), message: Text(restoreMessage), dismissButton: .default(Text("OK")))
            }

        }
    }
    
    private var closeButton: some View {
        Button {
            presentationMode.wrappedValue.dismiss()
        } label: {
            Image(systemName: "xmark")
                .foregroundColor(Color.labelTertiary)
        }
    }
    
    private func purchaseSubscription() {
        guard let plan = selectedPlan else { return }
        isPurchasing = true
        guard let product = subscriptionManager.avatarsApphud.first(where: { $0.skProduct?.productIdentifier == plan.productId }) else {
            isPurchasing = false
            return
        }
        subscriptionManager.startPurchase(product: product) { success in
            isPurchasing = false
            if success { presentationMode.wrappedValue.dismiss() }
        }
    }
    
    private func restorePurchases() {
        subscriptionManager.restorePurchases { success in
            if success {
                restoreMessage = "✅ Purchases successfully restored!"
                restoreAlert = true
                presentationMode.wrappedValue.dismiss()
            } else {
                restoreMessage = "❌ No purchases found to restore."
                restoreAlert = true
            }
        }
    }
    
}

struct SubscriptionButtonAvatar: View {
    
    let plan: SubscriptionPlansAvatar
    @Binding var selectedPlan: SubscriptionPlansAvatar?
    @ObservedObject var subscriptionManager = SubscriptionManager.shared
    
    var body: some View {
        Button(action: {selectedPlan = plan}) {
            HStack(spacing: 0) {
                
                    Text(plan.count)
                        .font(.bodyEmphasized)
                        .foregroundColor(.labelPrimary)
                        .padding(.trailing, 4)
                    
                    Text(plan.title)
                        .font(.bodyRegular)
                        .foregroundColor(.labelTertiary)
                    
                Spacer()
                
                Text(subscriptionManager.getAvatarPrice(for: plan.productId))
                    .font(.bodyRegular)
                    .foregroundColor(.labelPrimary)
                
            }
            .padding(.horizontal)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(selectedPlan == plan ? Color.backgroundPrimaryAlpha : Color.backgroundTertiary)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(selectedPlan == plan ? Color.accentPrimary : Color.clear, lineWidth: 1)
            )
            .padding(.horizontal)
        }
    }
}

struct SubscriptionPlansAvatar: Equatable {
    let count: String
    let title: String
    let productId: String
    
    static func from(productIds: [String]) -> [SubscriptionPlansAvatar] {
        productIds.map { id in
            let count: String
            let title: String
            
            if id.contains("avatar") || id.contains("annual") {
                count = "1";
                title = "avatar"
            } else {
                count = "-"
                title = "Unknown"
            }
            return SubscriptionPlansAvatar(count: count, title: title, productId: id)
        }
    }
}
