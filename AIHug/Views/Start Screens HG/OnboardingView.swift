import SwiftUI
import UserNotifications
import StoreKit

struct itemModel {
    let title: String
    let subtitle: String
    let image: String
}

struct OnboardingView: View {
    
    @State private var currentStep: Int = 0
    @Binding var showTabView: Bool
    
    private let vm: [itemModel] = [
        itemModel(
            title: "Use popular Effects",
            subtitle: "",
            image: "onboardingImage-1"),
        itemModel(
            title: "Try a new one",
            subtitle: "",
            image: "onboardingImage-2"),
        itemModel(
            title: "Create your own world using app",
            subtitle: "",
            image: "onboardingImage-3"),
        itemModel(
            title: "Rate our app in the AppStore",
            subtitle: "Lots of satisfied users",
            image: "onboardingImage-4"),
        itemModel(
            title: "Don't miss new trends",
            subtitle: "Allow notifications",
            image: "onboardingImage-5")
    ]
    
    var body: some View {
        ZStack {
            
            Color.backgroundPrimary
            
            VStack {
                TabView(selection: $currentStep) {
                    ForEach(0..<vm.count, id: \.self) { index in
                        ZStack {
                            
                            VStack {
                                Image(vm[index].image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxWidth: .infinity)
                                    .edgesIgnoringSafeArea(.all)
                                
                                Spacer()
                            }
                            
                            VStack {
                                Spacer()
                                
                                VStack {
                                    Text(vm[index].title)
                                        .font(.largeTitleEmphasized)
                                        .foregroundColor(.labelPrimary)
                                        .padding(.horizontal)
                                        .multilineTextAlignment(.center)
                                    
                                    if !vm[index].subtitle.isEmpty {
                                        Spacer()
                                            .frame(height: 6)
                                        Text(vm[index].subtitle)
                                            .font(.bodyRegular)
                                            .foregroundColor(.labelTertiary)
                                            .padding(.horizontal)
                                            .multilineTextAlignment(.center)
                                    }
                                }
                                .frame(height: 166)
                            }
                        }
                        .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentStep)
                
                Button {
                    if self.currentStep == 3 {
                        rateApp()
                        self.currentStep += 1
                    } else if self.currentStep < self.vm.count - 1 {
                        self.currentStep += 1
                    } else {
                        requestNotificationPermission()
                    }
                } label: {
                    Text("Next")
                        .foregroundColor(.labelPrimary)
                        .font(.bodyEmphasized)
                        .frame(height: 48)
                        .frame(maxWidth: .infinity)
                        .background(Color.accentPrimary)
                        .cornerRadius(12)
                        .padding(.horizontal)
                }
                
                if currentStep == 4 {
                    Button {
                        showTabView = true
                    } label: {
                        Text("Maybe Later")
                            .foregroundColor(.labelTertiary)
                            .font(.subheadlineRegular)
                            .frame(height: 44)
                            .padding(.bottom, 34)
                    }

                } else {
                    HStack {
                        ForEach(0 ..< vm.count, id: \.self) { index in
                            if index == currentStep {
                                Rectangle()
                                    .frame(width: 16, height: 8)
                                    .cornerRadius(8)
                                    .foregroundColor(Color.white)
                            } else {
                                Circle()
                                    .frame(width: 8, height: 8)
                                    .foregroundColor(Color.white.opacity(0.3))
                            }
                        }
                    }
                    .frame(height: 44)
                    .padding(.bottom, 34)
                }
                
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification permission granted")
            } else if let error = error {
                print("Notification permission request failed: \(error.localizedDescription)")
            } else {
                print("Notification permission denied")
            }
            
            DispatchQueue.main.async {
                showTabView = true
            }
        }
    }
    
    private func rateApp() {
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
        }
    }
    
}
