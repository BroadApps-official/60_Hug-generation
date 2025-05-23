import SwiftUI

struct CreditsPaywall: View {
    
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var subscriptionManager = SubscriptionManager.shared
    @EnvironmentObject var sessionViewModel: UserSessionViewModel
    
    @State private var showCloseButton = false
    @State private var isPurchasing = false
    
    @State private var subscriptionPlans: [CreditsPlan] = []
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.backgroundPrimary
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    
                    ZStack {
                        
                        VStack {
                            
                            Image("paywallImageAIHug")
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
                                    Text("My credits:")
                                        .font(.footnoteRegular)
                                        .foregroundColor(.labelSecondary)
                                    
                                    Text("\(sessionViewModel.userData!.stat.availableGenerations)")
                                        .font(.subheadlineEmphasized)
                                        .foregroundColor(.labelPrimary)
                                }
                                
                                
                                Text("Need more\ngenerations?")
                                    .font(.title1Emphasized)
                                    .foregroundColor(.labelPrimary)
                                    .padding(.vertical, 10)
                                    .multilineTextAlignment(.center)
                                
                                Text("Buy additional credits")
                                    .font(.footnoteRegular)
                                    .foregroundColor(.labelSecondary)
                                
                            }
                            .frame(height: 140)
                            
                            Spacer()
                                .frame(height: 30)
                            
                            VStack(spacing: 12) {
                                ForEach(subscriptionPlans, id: \.rawId) { plan in
                                    SubscriptionButtonCredits(plan: plan) { selected in
                                        purchase(plan: selected)
                                    }
                                }

                            }
                            
                            Spacer()
                                .frame(height: 30)
                            
                            
                        }
                    }
                    
                    
                        
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
                                //restorePurchases()
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
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    showCloseButton = true
                }
                
                let plans = CreditsPlan.from(productIds: subscriptionManager.creditsApphud.map(\.productId))
                subscriptionPlans = plans
                
            }
            .onChange(of: subscriptionManager.creditsApphud) { newProducts in
                let plans = CreditsPlan.from(productIds: newProducts.map(\.productId))
                subscriptionPlans = plans
            }
            .navigationBarItems(
                trailing:
                    closeButton
                    .opacity(showCloseButton ? 1 : 0)
                    .animation(.easeIn(duration: 1), value: showCloseButton)
            )
            
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
    
    private func purchase(plan: CreditsPlan) {
        isPurchasing = true
        guard let product = subscriptionManager.creditsApphud.first(where: { $0.skProduct?.productIdentifier == plan.rawId }) else {
            isPurchasing = false
            return
        }
        subscriptionManager.startPurchase(product: product) { success in
            isPurchasing = false
            if success {
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
    
}

struct SubscriptionButtonCredits: View {
    
    let plan: CreditsPlan
    var onTap: (CreditsPlan) -> Void
    @ObservedObject var subscriptionManager = SubscriptionManager.shared
    
    var body: some View {
        Button(action: {onTap(plan)}) {
            HStack(spacing: 0) {
                
                Text("\(plan.credits)")
                    .font(.bodyEmphasized)
                    .foregroundColor(.labelPrimary)
                    .padding(.trailing, 4)
                
                Text("Credits")
                    .font(.bodyRegular)
                    .foregroundColor(.labelTertiary)
                
                Spacer()
                
                Text(subscriptionManager.getCreditsPrice(for: plan.rawId))
                    .font(.bodyRegular)
                    .foregroundColor(.labelPrimary)
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.labelPrimary)
                    .padding(.leading, 10)
                
            }
            .padding(.horizontal)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(Color.backgroundTertiary)
            .cornerRadius(12)
            .padding(.horizontal)
        }
    }
    
}

struct CreditsPlan: Equatable {
    
    let credits: Int
    let rawId: String
    
    static func from(productIds: [String]) -> [CreditsPlan] {
        productIds.compactMap { id in
            let parts = id.components(separatedBy: "__")
            guard parts.count == 3,
                  let credits = Int(parts[0])
            else {
                return nil
            }
            return CreditsPlan(credits: credits,  rawId: id)
        }
    }
}
