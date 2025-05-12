import SwiftUI
import ApphudSDK
import AppTrackingTransparency
import AdSupport

@main
struct AIHugApp: App {
    
    @State private var onboardingCompleted = UserDefaults.standard.bool(forKey: "onboardingCompleted")
    @State private var genderSelected = UserDefaults.standard.bool(forKey: "genderSelected")

    @State private var showTabView = false
    @State private var showGenderView = false
    @StateObject private var dataController = DataController()
    
    init() {
        Apphud.start(apiKey: "app_tPd8B4MB7HqryPnqmePvYcN3CbKqPc")
        Apphud.setDeviceIdentifiers(idfa: nil, idfv: UIDevice.current.identifierForVendor?.uuidString)
        fetchIDFA()
        setupCache()
    }
    
    var body: some Scene {
        
        WindowGroup {
            if !onboardingCompleted {
                OnboardingView(onFinish: {
                    UserDefaults.standard.set(true, forKey: "onboardingCompleted")
                    onboardingCompleted = true
                })
            } else if !genderSelected {
                GenderSelectionView(onFinish: {
                    UserDefaults.standard.set(true, forKey: "genderSelected")
                    genderSelected = true
                })
            } else {
                CustomTabView()
                    .environment(\.managedObjectContext, dataController.container.viewContext)
                    .environmentObject(SubscriptionManager.shared)
            }
        }

    }
    
    func fetchIDFA() {
        if #available(iOS 14.5, *) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                ATTrackingManager.requestTrackingAuthorization { status in
                    guard status == .authorized else { return }
                    
                    let idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
                    Apphud.setDeviceIdentifiers(idfa: idfa, idfv: UIDevice.current.identifierForVendor?.uuidString)
                }
            }
        }
    }
    
    private func setupCache() {
        let memoryCapacity = 50 * 1024 * 1024
        let diskCapacity = 500 * 1024 * 1024
        let cache = URLCache(memoryCapacity: memoryCapacity, diskCapacity: diskCapacity, diskPath: "videoCache")
        URLCache.shared = cache
    }
}
