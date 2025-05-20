import SwiftUI

class TabBarVisibilityManager: ObservableObject {
    @Published var isTabBarHidden: Bool = false
}

extension View {
    func withTabBarHidden(_ hidden: Bool) -> some View {
        modifier(TabBarHiddenModifier(hidden: hidden))
    }
}

struct TabBarHiddenModifier: ViewModifier {
    @EnvironmentObject var tabBarVisibility: TabBarVisibilityManager
    let hidden: Bool

    func body(content: Content) -> some View {
        content
            .onAppear { tabBarVisibility.isTabBarHidden = hidden }
            .onDisappear {
                if hidden {
                    tabBarVisibility.isTabBarHidden = false
                }
            }
    }
}


struct CustomTabView: View {
    
    @State private var selectedTabIndex = 0
    @State private var showRateUsSheet = false
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @StateObject private var tabBarVisibility = TabBarVisibilityManager()
    @EnvironmentObject var sessionViewModel: UserSessionViewModel
    @State private var isPresented = false
    
    var body: some View {
        ZStack {
            
            ZStack {
                switch selectedTabIndex {
                case 0:
                    AIVideoView(selectedTabIndex: $selectedTabIndex)
                        .environmentObject(tabBarVisibility)
                case 1:
                    AIPhotoView(selectedTabIndex: $selectedTabIndex)
                        .environmentObject(tabBarVisibility)
                case 2:
                    HistoryView(selectedTabIndex: $selectedTabIndex)
                        .environmentObject(tabBarVisibility)
                case 3:
                    SettingsView(selectedTabIndex: $selectedTabIndex)
                        .environmentObject(tabBarVisibility)
                default:
                    Text("First tab")
                }
            }
            
            if !tabBarVisibility.isTabBarHidden {
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
            
        }
        .onChange(of: subscriptionManager.isSubscriptionStatusChecked) { checked in
            if checked && !subscriptionManager.isSubscribed && !showRateUsSheet {
                isPresented = true
            }
        }
        .fullScreenCover(isPresented: $isPresented) {
            PayWall()
        }
        .onAppear {
            checkAppLaunchCount()
            sessionViewModel.loadUserDataIfNeeded()
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

