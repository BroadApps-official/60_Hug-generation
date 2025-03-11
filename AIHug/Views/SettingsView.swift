import SwiftUI
import UserNotifications
import StoreKit
import ApphudSDK

struct SettingsView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @State private var isNotificationEnabled: Bool = false
    @State private var isSwitchDisabled: Bool = false
    @State private var isPresented = false
    @State private var scrollOffset: CGFloat = 0
    
    var body: some View {
        
        NavigationView {
            ZStack {
                Color.backgroundPrimary
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    
                    if #available(iOS 16.0, *) {
                        List {
                            Section(header:
                                        Text("Support us")
                                .font(.headline)
                                .foregroundColor(.labelSecondary)
                            ) {
                                
                                SettingsRowView(iconName: "star", title: "Rate app", value: "", action: {showRateAlert()})
                                
                                SettingsRowView(iconName: "square.and.arrow.up", title: "Share with friends", value: "", action: {shareApp()})
                            }
                            
                            Section(header:
                                        Text("Purchases & Actions")
                                .font(.headline)
                                .foregroundColor(.labelSecondary)
                            ) {
                                
                                
                                SettingsRowView(iconName: "sparkles", title: "Upgrade plan", value: "", action: {isPresented = true})
                                    .sheet(isPresented: $isPresented) {
                                        PayWall()
                                    }
                                
                                HStack {
                                    Image(systemName: "bell.badge")
                                        .frame(width: 36, alignment: .center)
                                        .foregroundColor(.accentPrimary)
                                    
                                    Text("Notifications")
                                        .foregroundColor(Color.labelPrimary)
                                    
                                    Spacer()
                                    
                                    Toggle("", isOn: $isNotificationEnabled)
                                        .tint(.accentPrimary)
                                }
                                .listRowBackground(Color.backgroundTertiary)
                                
                                SettingsRowView(iconName: "trash", title: "Clear cache", value: "5 MB", action: {})
                                
                                SettingsRowView(iconName: "arrow.clockwise.icloud", title: "Restore purchases", value: "", action: {restorePurchases()})
                                
                            }
                            
                            Section(header:
                                        Text("Info & legal")
                                .font(.headline)
                                .foregroundColor(.labelSecondary)
                            ) {
                                
                                SettingsRowView(iconName: "text.bubble", title: "Contact us", value: "", action: {sendEmail()})
                                
                                SettingsRowView(iconName: "folder.badge.person.crop", title: "Privacy Policy", value: "", action: {openURL("https://docs.google.com/document/d/17pLhC6Wj7PeDZLwdCTLwgljnmfFBf55YWzqbRRa2DCA/edit?usp=sharing")})
                                
                                SettingsRowView(iconName: "doc.text", title: "Usage Policy", value: "", action: {openURL("https://docs.google.com/document/d/12FPPVshMhVRK9L2wyfeU1eAUNqTA6A8K8smulJGIZy4/edit?usp=sharing")})
                            }
                            
                            HStack() {
                                Spacer()
                                Text("App Version: 1.0.0")
                                    .font(.footnoteRegular)
                                    .foregroundColor(Color.labelTertiary)
                                Spacer()
                            }
                            .padding(.bottom, 100)
                            .listRowBackground(Color.backgroundPrimary)
                            
                            
                        }
                        .background(GeometryReader { geometry in
                            Color.clear.onAppear {
                                self.scrollOffset = geometry.frame(in: .global).minY
                            }
                            .onChange(of: geometry.frame(in: .global).minY) { value in
                                self.scrollOffset = value
                            }
                        })
                        .listStyle(InsetGroupedListStyle())
                        .background(Color.backgroundPrimary)
                        .scrollContentBackground(.hidden)
                    } else {
                        List {
                            
                            Section(header:
                                        Text("Support us")
                                .font(.headline)
                                .foregroundColor(.labelSecondary)
                            ) {
                                
                                SettingsRowView(iconName: "star", title: "Rate app", value: "", action: {showRateAlert()})
                                
                                SettingsRowView(iconName: "square.and.arrow.up", title: "Share with friends", value: "", action: {shareApp()})
                            }
                            
                            Section(header:
                                        Text("Purchases & Actions")
                                .font(.headline)
                                .foregroundColor(.labelSecondary)
                            ) {
                                SettingsRowView(iconName: "sparkles", title: "Upgrade plan", value: "", action: {isPresented = true})
                                    .sheet(isPresented: $isPresented) {
                                        PayWall()
                                    }
                                
                                HStack {
                                    Image(systemName: "bell.badge")
                                        .frame(width: 36, alignment: .center)
                                        .foregroundColor(.accentPrimary)
                                    
                                    Text("Notifications")
                                        .foregroundColor(Color.labelPrimary)
                                    
                                    Spacer()
                                    
                                    Toggle("", isOn: $isNotificationEnabled)
                                }
                                .listRowBackground(Color.backgroundTertiary)
                                
                                SettingsRowView(iconName: "trash", title: "Clear cache", value: "5 MB", action: {})
                                
                                SettingsRowView(iconName: "arrow.clockwise.icloud", title: "Restore purchases", value: "", action: {restorePurchases()})                            }
                            
                            Section(header:
                                        Text("Info & legal")
                                .font(.headline)
                                .foregroundColor(.labelSecondary)
                            ) {
                                
                                SettingsRowView(iconName: "text.bubble", title: "Contact us", value: "", action: {sendEmail()})
                                
                                SettingsRowView(iconName: "folder.badge.person.crop", title: "Privacy Policy", value: "", action: {openURL("https://docs.google.com/document/d/17pLhC6Wj7PeDZLwdCTLwgljnmfFBf55YWzqbRRa2DCA/edit?usp=sharing")})
                                
                                SettingsRowView(iconName: "doc.text", title: "Usage Policy", value: "", action: {openURL("https://docs.google.com/document/d/12FPPVshMhVRK9L2wyfeU1eAUNqTA6A8K8smulJGIZy4/edit?usp=sharing")})
                            }
                            
                            HStack() {
                                Spacer()
                                Text("App Version: 1.0.0")
                                    .font(.footnoteRegular)
                                    .foregroundColor(Color.labelTertiary)
                                Spacer()
                            }
                            .padding(.bottom, 100)
                            .listRowBackground(Color.backgroundPrimary)
                            
                        }
                        .background(GeometryReader { geometry in
                            Color.clear.onAppear {
                                self.scrollOffset = geometry.frame(in: .global).minY
                            }
                            .onChange(of: geometry.frame(in: .global).minY) { value in
                                self.scrollOffset = value
                            }
                        })
                        .listStyle(InsetGroupedListStyle())
                    }
                    
                    Spacer()
                    
                }
                .navigationBarBackButtonHidden(true)
                .navigationTitle(
                    Text("Settings")
                )
                .navigationBarTitleDisplayMode(scrollOffset < -100 ? .inline : .large)
                .navigationBarItems(
                    trailing:
                        Button(action: {
                            isPresented = true
                        }, label: {
                            HStack(spacing: 0) {
                                Text("PRO")
                                    .font(.subheadlineEmphasized)
                                    .foregroundColor(.labelPrimary)
                                    .padding(.leading, 10)
                                Image(systemName: "sparkles")
                                    .frame(width: 32, height: 32)
                                    .foregroundColor(.labelPrimary)
                                    .font(.system(size: 14))
                            }
                            .frame(height: 32)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.accentPrimary, Color.accentSecondary]),
                                startPoint: .leading,
                                endPoint: .trailing
                            ))
                            .cornerRadius(8)
                        })
                        .sheet(isPresented: $isPresented) {
                            PayWall()
                        }

                )
            }
        }
    }
    
    private func showRateAlert() {
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
        } else {
            openAppStore()
        }
    }
    
    private func openAppStore() {
        if let url = URL(string: "https://apps.apple.com/us/app/id\(6742832953)?action=write-review") {
            UIApplication.shared.open(url)
        }
    }
    
    private func sendEmail() {
        let email = "magnatamanju@gmail.com"
        let mailtoString = "mailto:\(email)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        if let url = URL(string: mailtoString) {
            UIApplication.shared.open(url)
        }
    }
    
    private func shareApp() {
        let appURL = URL(string: "https://apps.apple.com/us/app/hug-generation/id6742832953")!
        let activityVC = UIActivityViewController(activityItems: [appURL], applicationActivities: nil)
        UIApplication.shared.windows.first?.rootViewController?.present(activityVC, animated: true)
    }
    
    private func restorePurchases() {
        Apphud.restorePurchases { subscriptions, nonRenewingPurchases, error in
            if let subscriptions = subscriptions, !subscriptions.isEmpty {
                
            } else if let nonRenewingPurchases = nonRenewingPurchases, !nonRenewingPurchases.isEmpty {
                
            } else {
                print("No active subscriptions found or error: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
    
    private func openURL(_ urlString: String) {
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
    
}

#Preview {
    SettingsView()
}

struct SettingsRowView: View {
    let iconName: String
    let title: String
    let value: String?
    var action: () -> Void
    
    var body: some View {
        
        Button(action: action) {
            HStack {
                Image(systemName: iconName)
                    .frame(width: 36, alignment: .center)
                    .foregroundColor(.accentPrimary)
                
                Text(title)
                    .foregroundColor(Color.labelPrimary)
                
                Spacer()
                
                if let value = value {
                    Text(value)
                        .foregroundColor(.labelQuaternary)
                }
                
                Image(systemName: "chevron.right")
                    .foregroundColor(Color.accentPrimary)
            }
        }
        .listRowBackground(Color.backgroundTertiary)
    }
}
