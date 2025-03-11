import SwiftUI
import ApphudSDK
import AppTrackingTransparency
import AdSupport

@main
struct AIHugApp: App {
    
    @State private var isFirstLaunch: Bool = UserDefaults.standard.bool(forKey: "isFirstLaunch") == false
    @State private var showTabView = false
    @StateObject private var dataController = DataController()
    
    init() {
       Apphud.start(apiKey: "app_tPd8B4MB7HqryPnqmePvYcN3CbKqPc")
       Apphud.setDeviceIdentifiers(idfa: nil, idfv: UIDevice.current.identifierForVendor?.uuidString)
       fetchIDFA()
     }
    
    var body: some Scene {
        WindowGroup {
          if isFirstLaunch && !showTabView {
              OnboardingView(showTabView: $showTabView)
                  .onDisappear {
                      UserDefaults.standard.set(true, forKey: "isFirstLaunch")
                  }
          } else {
              CustomTabView()
                  .environment(\.managedObjectContext, dataController.container.viewContext)
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
}
