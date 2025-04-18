import SwiftUI

struct CustomTabView: View {
    
    @State private var selectedIndex = 0
    @State private var showRateUsSheet = false
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @State private var isPresented = false
    
    var body: some View {
        ZStack {
            
            ZStack {
                switch selectedIndex {
                case 0:
                    GenerateView()
                case 1:
                    AIEffectsView()
                case 2:
                    HistoryView()
                case 3:
                    SettingsView()
                default:
                    Text("First tab")
                }
            }
            
            VStack {
                Spacer()
                
                HStack(spacing: 0) {
                    
                    Spacer()
                        .frame(width: 10)
                    
                    TabBarItem(iconName: "sparkles", title: "Generate", isSelected: selectedIndex == 0)
                        .onTapGesture {
                            selectedIndex = 0
                        }
                    
                    TabBarItem(iconName: "flame.fill", title: "AI effects", isSelected: selectedIndex == 1)
                        .onTapGesture {
                            selectedIndex = 1
                        }
                    
                    TabBarItem(iconName: "rectangle.stack.badge.play.fill", title: "Creations", isSelected: selectedIndex == 2)
                        .onTapGesture {
                            selectedIndex = 2
                        }
                    
                    TabBarItem(iconName: "gearshape.fill", title: "Settings", isSelected: selectedIndex == 3)
                        .onTapGesture {
                            selectedIndex = 3
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
        .onChange(of: subscriptionManager.isSubscriptionStatusChecked) { checked in
            if checked && !subscriptionManager.isSubscribed {
                isPresented = true
            }
        }
        .fullScreenCover(isPresented: $isPresented) {
            PayWall()
        }
        .onAppear {
            checkAppLaunchCount()
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

