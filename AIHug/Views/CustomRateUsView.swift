import SwiftUI
import StoreKit

struct CustomRateUsView: View {

    @State private var isShowingAppStoreSheet = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.backgroundPrimary
                
                VStack(spacing: 0) {
                    
                    Text("Do you like our app?")
                        .font(.title3Emphasized)
                        .foregroundColor(.labelPrimary)
                        .padding(.bottom, 5)
                    
                    Text("Please rate our app so we can improve it for you and make it even cooler")
                        .font(.footnoteRegular)
                        .foregroundColor(.labelSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Image("customRateUsImage")
                        .resizable()
                        .frame(width: 258, height: 258)
                        .padding(.vertical)
                    
                    Button {
                        isShowingAppStoreSheet.toggle()
                    } label: {
                        Text("Yes")
                            .foregroundColor(.labelPrimary)
                            .font(.bodyEmphasized)
                            .frame(height: 48)
                            .frame(maxWidth: .infinity)
                            .background(Color.accentPrimary)
                            .cornerRadius(12)
                            .padding(.horizontal, 32)
                    }
                    .padding(.bottom, 10)
                    
                    Button {
                        
                    } label: {
                        Text("No")
                            .foregroundColor(.accentPrimary)
                            .font(.bodyEmphasized)
                            .frame(height: 48)
                            .frame(maxWidth: .infinity)
                            .background(Color.accentPrimaryAlpha)
                            .cornerRadius(12)
                            .padding(.horizontal, 32)
                    }
                }
                
            }
            .edgesIgnoringSafeArea(.all)
            .navigationBarItems(
                
                trailing:
                    
                    Button {
                        
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(Color.accentPrimary)
                    }
                
            )
            .sheet(isPresented: $isShowingAppStoreSheet) {
                            AppStoreReviewSheet()
                        }
        }
    }
}

#Preview {
    CustomRateUsView()
}

struct AppStoreReviewSheet: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> SKStoreProductViewController {
        let storeVC = SKStoreProductViewController()
        storeVC.delegate = context.coordinator

        let parameters = [SKStoreProductParameterITunesItemIdentifier: "6742832953"]
        storeVC.loadProduct(withParameters: parameters)

        return storeVC
    }

    func updateUIViewController(_ uiViewController: SKStoreProductViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator: NSObject, SKStoreProductViewControllerDelegate {
        func productViewControllerDidFinish(_ viewController: SKStoreProductViewController) {
            viewController.dismiss(animated: true)
        }
    }
}
