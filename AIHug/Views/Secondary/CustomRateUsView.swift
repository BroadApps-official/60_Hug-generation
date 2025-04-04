import SwiftUI
import StoreKit

struct CustomRateUsView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
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
                        if let url = URL(string: "https://apps.apple.com/app/id6742832953?action=write-review") {
                            UIApplication.shared.open(url)
                        }
                        
                        UserDefaults.standard.set(true, forKey: "HasRatedApp")
                        
                        presentationMode.wrappedValue.dismiss()
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
                        presentationMode.wrappedValue.dismiss()
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
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(Color.accentPrimary)
                    }
                
            )
        }
    }
}
