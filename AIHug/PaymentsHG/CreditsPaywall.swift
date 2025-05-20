import SwiftUI

struct CreditsPaywall: View {
    
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var subscriptionManager = SubscriptionManager.shared
    @EnvironmentObject var sessionViewModel: UserSessionViewModel

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
                                .frame(height: 20)

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
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    showCloseButton = true
                }
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
    
}
