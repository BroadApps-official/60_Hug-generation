import SwiftUI

struct PayWall: View {
    
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var subscriptionManager = SubscriptionManager.shared
    @State private var selectedPlan: SubscriptionPlan? = .weekly
    @State private var showCloseButton = false
    @State private var isPurchasing = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.backgroundPrimary
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    
                    ZStack {
                        
                        VStack {
                            Image("payWallImage")
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
                            
                            VStack {
                                Text("Unreal videos with PRO")
                                    .font(.title1Emphasized)
                                    .foregroundColor(.labelPrimary)
                                
                                Spacer()
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        Image(systemName: "sparkles")
                                            .font(.caption1Regular)
                                            .foregroundColor(.accentPrimary)
                                        
                                        Text("Access to all effects")
                                            .font(.subheadlineEmphasized)
                                            .foregroundColor(.labelSecondary)
                                    }
                                    .frame(height: 32)
                                    
                                    HStack {
                                        Image(systemName: "sparkles")
                                            .font(.caption1Regular)
                                            .foregroundColor(.accentPrimary)
                                        
                                        Text("Unlimited generation")
                                            .font(.subheadlineEmphasized)
                                            .foregroundColor(.labelSecondary)
                                    }
                                    .frame(height: 32)
                                    
                                    HStack {
                                        Image(systemName: "sparkles")
                                            .font(.caption1Regular)
                                            .foregroundColor(.accentPrimary)
                                        
                                        Text("Access to all functions")
                                            .font(.subheadlineEmphasized)
                                            .foregroundColor(.labelSecondary)
                                    }
                                    .frame(height: 32)
                                }
                            }
                            .frame(height: 154)
                            
                            Spacer()
                                .frame(height: 20)
                            
                            VStack(spacing: 12) {
                                ForEach(SubscriptionPlan.allCases, id: \ .self) { plan in
                                    SubscriptionButton(plan: plan, selectedPlan: $selectedPlan)
                                }
                            }
                            
                            Spacer()
                                .frame(height: 16)
                        }
                    }
                    
                    
                    VStack(spacing: 0) {
                        
                        HStack(alignment: .top) {
                            Image(systemName: "clock.arrow.circlepath")
                                .font(.caption1Regular)
                                .foregroundColor(.labelQuaternary)
                            
                            Text("Cancel Anytime")
                                .font(.caption1Regular)
                                .foregroundColor(.labelQuaternary)
                        }
                        .frame(height: 32)
                        
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
      guard let product = subscriptionManager.productsApphud.first(where: { $0.skProduct?.productIdentifier == plan.productId }) else {
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
        if success { presentationMode.wrappedValue.dismiss() }
      }
    }
    
}

struct SubscriptionButton: View {

    let plan: SubscriptionPlan
    @Binding var selectedPlan: SubscriptionPlan?
    @ObservedObject var subscriptionManager = SubscriptionManager.shared
    
    var body: some View {
        Button(action: {selectedPlan = plan}) {
            HStack(spacing: 0) {
                Image(systemName: selectedPlan == plan ? "button.programmable" : "circle")
                    .foregroundColor(selectedPlan == plan ? .accentPrimary : .labelQuintuple)
                    .frame(width: 32, height: 32)
                    .padding(.horizontal, 8)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Just \(subscriptionManager.getProductPrice(for: plan.productId)) / \(plan.title)")
                        .font(.bodyEmphasized)
                        .foregroundColor(.labelPrimary)
                    
                    Text(plan.subtitle)
                        .font(.caption1Regular)
                        .foregroundColor(.labelQuaternary)
                    
                }
                
                Spacer()
                
            }
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

enum SubscriptionPlan: String, CaseIterable {
    case yearly, weekly
    
    var title: String {
        switch self {
        case .yearly: return "Year"
        case .weekly: return "Week"
        }
    }
    
    var subtitle: String {
        switch self {
        case .yearly: return "Auto renewable. Cancel anytime."
        case .weekly: return "Auto renewable. Cancel anytime."
        }
    }
        
    var productId: String {
        switch self {
        case .yearly: return "yearly_39.99_nottrial."
        case .weekly: return "week_6.99_nottrial"
        }
    }
}
