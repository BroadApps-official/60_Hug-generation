import SwiftUI

struct CustomTabView: View {
    
    @State private var selectedTabIndex = 0
    @State private var showRateUsSheet = false
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @EnvironmentObject var sessionViewModel: UserSessionViewModel
    @State private var isPresented = false
    @StateObject private var networkMonitor = NetworkMonitor()
    @State private var showAlert = false
    
    var body: some View {
        ZStack {
            
                ZStack {
                    switch selectedTabIndex {
                    case 0:
                        AIVideoView(selectedTabIndex: $selectedTabIndex)
                    case 1:
                        AIPhotoView(selectedTabIndex: $selectedTabIndex)
                    case 2:
                        HistoryView(selectedTabIndex: $selectedTabIndex)
                    case 3:
                        SettingsView(selectedTabIndex: $selectedTabIndex)
                    default:
                        Text("First tab")
                    }
                }
            

                VStack {
                    Spacer()
                    
                    HStack(spacing: 0) {
                        
                        Spacer()
                            .frame(width: 10)
                        
                        TabBarItem(iconName: "sparkles", title: "AI Video", isSelected: selectedTabIndex == 0)
                            .onTapGesture {
                                selectedTabIndex = 0
                            }
                        
                        TabBarItem(iconName: "photo.tv", title: "AI Photo", isSelected: selectedTabIndex == 1)
                            .onTapGesture {
                                selectedTabIndex = 1
                            }
                        
                        TabBarItem(iconName: "doc.on.doc.fill", title: "History", isSelected: selectedTabIndex == 2)
                            .onTapGesture {
                                selectedTabIndex = 2
                            }
                        
                        TabBarItem(iconName: "gearshape.fill", title: "Settings", isSelected: selectedTabIndex == 3)
                            .onTapGesture {
                                selectedTabIndex = 3
                            }
                        
                        Spacer()
                            .frame(width: 10)
                    }
                    .frame(height: 80)
                    .background(BlurView(style: .systemUltraThinMaterial))
                    .cornerRadius(20)
                    .padding(.horizontal)
                    .padding(.bottom, 30)

                }
                .edgesIgnoringSafeArea(.bottom)
            
            
        }
        .fullScreenCover(isPresented: $isPresented) {
            PayWall()
        }
        .onAppear {
            checkAppLaunchCount()
            sessionViewModel.loadUserDataIfNeeded()
        }
        .onReceive(networkMonitor.$isConnected) { isConnected in
            if !isConnected {
                showAlert = true
            }
        }
        .alert("No Internet Connection", isPresented: $showAlert) {
            Button("ОК", role: .cancel) {
                showAlert = false
            }
        }
        .fullScreenCover(isPresented: $showRateUsSheet) {
            CustomRateUsView()
        }
        
    }
    
    private func checkAppLaunchCount() {
        let launchKey = "appLaunchCount"
        let hasRatedKey = "HasRatedApp"
        let userDefaults = UserDefaults.standard
        
        var launchCount = userDefaults.integer(forKey: launchKey)
        launchCount += 1
        
        userDefaults.set(launchCount, forKey: launchKey)
        
        if launchCount % 3 == 0 && userDefaults.bool(forKey: hasRatedKey) == false {
            showRateUsSheet = true
        }
        
    }
}

struct TabBarItem: View {
    let iconName: String
    let title: String
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            Image(systemName: iconName)
                .font(.bodyRegular)
                .frame(width: 32, height: 32, alignment: .center)
                .foregroundColor(isSelected ? Color.labelPrimary : Color.labelQuaternary)
            
            Text(title)
                .font(.caption2Emphasized)
                .foregroundColor(isSelected ? Color.labelPrimary : Color.labelQuaternary)
                .padding(.bottom, 5)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 60)
        .background(isSelected ? Color.backgroundQuaternary : Color.clear)
        .cornerRadius(12)
        .contentShape(Rectangle())
    }
}

struct BlurView: UIViewRepresentable {
    let style: UIBlurEffect.Style
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: style))
        return blurView
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        
    }
}

