import SwiftUI
import UserNotifications
import StoreKit
import ApphudSDK

struct SettingsView: View {
    
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @EnvironmentObject var sessionViewModel: UserSessionViewModel
    
    @Environment(\.presentationMode) var presentationMode
    
    @State private var isNotificationEnabled: Bool = false
    @State private var isPresented = false
    @State private var avatarPaywallIsPresented = false
    @State private var scrollOffset: CGFloat = 0
    @State private var cacheSize = VideoCacheManager.shared.formattedCacheSize()
    @State private var showAlert = false
    @State private var alertType: AlertType?
    @State private var selectedSegment: Int = UserDefaults.standard.integer(forKey: "selectedGender")
    @State private var restoreAlert: Bool = false
    @State private var restoreMessage: String = ""
    
    @Binding var selectedTabIndex: Int
    
    enum AlertType {
        case clearCache
    }
    
    var body: some View {
        
        NavigationView {
            ZStack {
                Color.backgroundPrimary
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 10) {
                            
                            //MARK: - Gender selection
                            
                            HStack {
                                Text("Gender")
                                    .font(.title3Emphasized)
                                    .foregroundColor(.labelPrimary)
                                
                                Spacer()
                            }
                            
                            HStack {
                                
                                Button {
                                    selectedSegment = 0
                                    UserDefaults.standard.set(0, forKey: "selectedGender")
                                } label: {
                                    
                                    HStack{
                                        
                                        Image("wAvatar")
                                            .resizable()
                                            .frame(width: 32, height: 32)
                                        
                                        Text("Women")
                                            .foregroundColor(.labelPrimary)
                                            .font(.headline)
                                        
                                    }
                                    .frame(height: 64)
                                    .frame(maxWidth: .infinity)
                                    .background(selectedSegment == 0 ? Color.accentPrimary : Color.backgroundSecondary)
                                    .cornerRadius(16)
                                }
                                
                                Button {
                                    selectedSegment = 1
                                    UserDefaults.standard.set(1, forKey: "selectedGender")
                                } label: {
                                    
                                    HStack{
                                        
                                        Image("mAvatar")
                                            .resizable()
                                            .frame(width: 32, height: 32)
                                        
                                        Text("Men")
                                            .foregroundColor(.labelPrimary)
                                            .font(.headline)
                                        
                                    }
                                    .frame(height: 64)
                                    .frame(maxWidth: .infinity)
                                    .background(selectedSegment == 1 ? Color.accentPrimary : Color.backgroundSecondary)
                                    .cornerRadius(16)
                                }
                            }
                            
                            
                            //MARK: - Avatar section
                            
                            VStack {
                                HStack {
                                    Text("My Avatars")
                                        .foregroundColor(Color.labelPrimary)
                                        .font(.title3Emphasized)
                                    
                                    Spacer()
                                }
                                .padding(.horizontal)
                                .padding(.top)
                                .padding(.bottom, 4)
                                
                                HStack {
                                    Image(systemName: "face.smiling")
                                        .font(.bodyRegular)
                                        .foregroundColor(.accentSecondary)
                                    
                                    Text("Created by:")
                                        .font(.bodyRegular)
                                        .foregroundColor(.labelPrimary)
                                    
                                    Spacer()
                                    
                                    Text(sessionViewModel.userData != nil ? "\(sessionViewModel.userData!.stat.availableModels)" : "-")
                                        .font(.calloutRegular)
                                        .foregroundColor(.labelTertiary)
                                    
                                    Text("/")
                                        .font(.bodyEmphasized)
                                        .foregroundColor(.labelPrimary)
                                    
                                    Text(sessionViewModel.userData != nil ? "\(sessionViewModel.userData!.stat.maxModels)" : "-")
                                        .font(.bodyEmphasized)
                                        .foregroundColor(.labelPrimary)
                                    
                                }
                                .padding()
                                .background(Color.backgroundTertiary)
                                .cornerRadius(12)
                                .padding(.horizontal)
                                
                                HStack(spacing: 10) {
                                    
                                    NavigationLink(destination: AvatarView()) {
                                        Text("Create avatar")
                                            .foregroundColor(.accentPrimary)
                                            .font(.bodyEmphasized)
                                            .frame(height: 48)
                                            .frame(maxWidth: .infinity)
                                            .background(Color.accentPrimaryAlpha)
                                            .cornerRadius(12)
                                    }
                                    
                                    
                                    Button {
                                        avatarPaywallIsPresented = true
                                    } label: {
                                        Text("Buy avatar")
                                            .foregroundColor(.labelPrimary)
                                            .font(.bodyEmphasized)
                                            .frame(height: 48)
                                            .frame(maxWidth: .infinity)
                                            .background(Color.accentPrimary)
                                            .cornerRadius(12)
                                    }
                                }
                                .padding(.horizontal)
                                .padding(.bottom)
                                
                            }
                            .background(Color.backgroundTertiary)
                            .cornerRadius(12)
                            
                            
                            //MARK: - Suppot us section
                            
                            HStack {
                                Text("Support us")
                                    .font(.headline)
                                    .foregroundColor(.labelSecondary)
                                
                                Spacer()
                            }
                            .padding(.top)
                            
                            SettingsRowView(iconName: "star", title: "Rate app", value: "", action: { showRateAlert() })
                            SettingsRowView(iconName: "square.and.arrow.up", title: "Share with friends", value: "", action: { shareApp() })
                            
                            
                            //MARK: - Purchases & Actions section
                            
                            HStack {
                                Text("Purchases & Actions")
                                    .font(.headline)
                                    .foregroundColor(.labelSecondary)
                                
                                Spacer()
                            }
                            .padding(.top)
                            
                            if !subscriptionManager.isSubscribed {
                                SettingsRowView(iconName: "sparkles", title: "Upgrade plan", value: "", action: {isPresented = true})
                            }
                            HStack {
                                Image(systemName: "bell.badge")
                                    .frame(width: 36, alignment: .center)
                                    .foregroundColor(.accentPrimary)
                                    .padding(.leading, 10)
                                
                                Text("Notifications")
                                    .foregroundColor(Color.labelPrimary)
                                
                                Spacer()
                                
                                Toggle("", isOn: Binding(
                                    get: { isNotificationEnabled },
                                    set: { newValue in
                                        if newValue {
                                            requestNotificationPermission()
                                        } else {
                                            openSystemSettings()
                                        }
                                    }
                                ))
                                .tint(.accentPrimary)
                                .padding(.trailing)
                            }
                            .frame(height: 44)
                            .background(Color.backgroundTertiary)
                            .cornerRadius(10)
                            SettingsRowView(iconName: "trash", title: "Clear cache", value: cacheSize, action: {
                                alertType = .clearCache
                                showAlert = true
                            })
                            if !subscriptionManager.isSubscribed{
                                SettingsRowView(iconName: "arrow.clockwise.icloud", title: "Restore purchases", value: "", action: {restorePurchases()})
                            }
                            
                            
                            //MARK: - Info & legal section
                            
                            HStack {
                                Text("Info & legal")
                                    .font(.headline)
                                    .foregroundColor(.labelSecondary)
                                
                                Spacer()
                            }
                            .padding(.top)
                            
                            SettingsRowView(iconName: "text.bubble", title: "Contact us", value: "", action: { sendEmail() })
                            SettingsRowView(iconName: "folder.badge.person.crop", title: "Privacy Policy", value: "", action: {
                                openURL("https://docs.google.com/document/d/17pLhC6Wj7PeDZLwdCTLwgljnmfFBf55YWzqbRRa2DCA/edit?usp=sharing")
                            })
                            SettingsRowView(iconName: "doc.text", title: "Usage Policy", value: "", action: {
                                openURL("https://docs.google.com/document/d/12FPPVshMhVRK9L2wyfeU1eAUNqTA6A8K8smulJGIZy4/edit?usp=sharing")
                            })
                            
                            
                            //MARK: - Version section
                            
                            HStack() {
                                Spacer()
                                Text("App Version: 1.3.1")
                                    .font(.footnoteRegular)
                                    .foregroundColor(Color.labelTertiary)
                                Spacer()
                            }
                            .padding(.bottom, 100)
                            .padding(.top, 20)
                            
                            
                        }
                        .padding()
                    }
                    
                }
                .navigationBarBackButtonHidden(true)
                .navigationTitle(
                    Text("Settings")
                )
                .navigationBarItems(
                    trailing:
                        HStack {
                            if !subscriptionManager.isSubscribed {
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
                                .fullScreenCover(isPresented: $isPresented) {
                                    PayWall()
                                }
                            }
                        }
                    
                )
                .onAppear {
                    updateNotificationPermissionStatus()
                }
                .fullScreenCover(isPresented: $avatarPaywallIsPresented) {
                    AvatarPayWall()
                }
                .alert(isPresented: $showAlert) {
                    switch alertType {
                    case .clearCache:
                        return Alert(
                            title: Text("Clear cache?"),
                            message: Text("The cached files of your videos will be deleted from your phone's memory. But your download history will be retained."),
                            primaryButton: .destructive(Text("Clear"), action: {
                                VideoCacheManager.shared.clearCache()
                            }),
                            secondaryButton: .cancel()
                        )
                    case .none:
                        return Alert(title: Text("Error"))
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: .cacheDidClear)) { _ in
                    cacheSize = VideoCacheManager.shared.formattedCacheSize()
                }
                .alert(isPresented: $restoreAlert) {
                    Alert(title: Text("Restore Purchases"), message: Text(restoreMessage), dismissButton: .default(Text("OK")))
                }
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
        if let url = URL(string: "https://apps.apple.com/app/id6742832953?action=write-review") {
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
    
    func updateNotificationPermissionStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.isNotificationEnabled = settings.authorizationStatus == .authorized
            }
        }
    }

    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            DispatchQueue.main.async {
                self.isNotificationEnabled = granted
            }
        }
    }
    
    func openSystemSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
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
    
    private func openURL(_ urlString: String) {
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
    
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
                    .padding(.leading, 10)
                
                Text(title)
                    .foregroundColor(Color.labelPrimary)
                
                Spacer()
                
                if let value = value {
                    Text(value)
                        .foregroundColor(.labelQuaternary)
                }
                
                Image(systemName: "chevron.right")
                    .foregroundColor(Color.accentPrimary)
                    .padding(.trailing)
            }
        }
        .frame(height: 44)
        .background(Color.backgroundTertiary)
        .cornerRadius(10)
    }
}
