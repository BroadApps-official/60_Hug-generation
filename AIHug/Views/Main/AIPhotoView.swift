import SwiftUI
import AVKit

struct AIPhotoView: View {
    
    @StateObject private var viewModelEffectsFotbudka = EffectsViewModel()
    @StateObject private var viewModelStylesFotbudka = StylesViewModel()
    @EnvironmentObject var sessionViewModel: UserSessionViewModel
    
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    
    @State private var avatarPaywallIsPresented = false
    @State private var creditsPaywallIsPresented = false
    @State private var isPresented = false
    
    @Binding var selectedTabIndex: Int
    
    var body: some View {
        
        NavigationView {
            ZStack {
                Color.backgroundPrimary
                    .edgesIgnoringSafeArea(.all)
                
                ScrollView(.vertical, showsIndicators: false) {
                    
                    ForEach(viewModelStylesFotbudka.styles) { group in
                        if !group.templates.isEmpty {
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Text(group.title)
                                        .font(.title3Emphasized)
                                        .foregroundColor(.labelPrimary)
                                    
                                    Spacer()
                                    
                                    NavigationLink(destination: AllTemplatesView(items: group.templates, type: "photo", aiModel: "photoStyles")) {
                                        HStack(spacing: 5) {
                                            Text("See all")
                                                .font(.footnoteRegular)
                                                .foregroundColor(.labelPrimary)
                                            
                                            Image(systemName: "chevron.forward")
                                                .font(.system(size: 12))
                                                .foregroundColor(.labelPrimary)
                                        }
                                        .padding(8)
                                        .background(Color.backgroundPrimary)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color.separatorSecondary, lineWidth: 1)
                                        )
                                    }
                                }
                                .padding(.horizontal)
                                .padding(.top, 10)
                                
                                let templates = group.templates.prefix(2)
                                
                                HStack(spacing: 10) {
                                    ForEach(templates) { template in
                                        //NavigationLink(destination: AddPhotoView(items: group.templates, selectedIndex: 0, aiModel: //"photoStyles", type: "photo")) {
                                        //    ImageCardView(item: template)
                                        //}
                                        NavigationLink(destination: AvatarView()) {
                                            ImageCardView(item: template)
                                        }
                                    }
                                    
                                    if templates.count == 1 {
                                        Spacer()
                                            .frame(width: (UIScreen.main.bounds.width - 16 * 2 - 10) / 2, height: 250)
                                    }
                                }
                                .padding(.horizontal)
                                .frame(height: 250)
                                
                            }
                        }
                    }
                    
                    ForEach(viewModelEffectsFotbudka.groups) { group in
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text(group.title)
                                    .font(.title3Emphasized)
                                    .foregroundColor(.labelPrimary)
                                
                                Spacer()
                                
                                NavigationLink(destination: AllTemplatesView(items: group.effects, type: "photo", aiModel: "photoEffects")) {
                                    HStack(spacing: 5) {
                                        Text("See all")
                                            .font(.footnoteRegular)
                                            .foregroundColor(.labelPrimary)
                                        
                                        Image(systemName: "chevron.forward")
                                            .font(.system(size: 12))
                                            .foregroundColor(.labelPrimary)
                                    }
                                    .padding(8)
                                    .background(Color.backgroundPrimary)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.separatorSecondary, lineWidth: 1)
                                    )
                                }
                            }
                            .padding(.horizontal)
                            .padding(.top, 10)
                            
                            let effects = group.effects.prefix(2)
                            
                            HStack(spacing: 10) {
                                ForEach(group.effects.prefix(2)) { effect in
                                    NavigationLink(destination: AddPhotoView(items: group.effects, selectedIndex: 0, aiModel: "photoEffects", type: "photo")) {
                                        ImageCardView(item: effect)
                                    }
                                }
                                
                                if effects.count == 1 {
                                    Spacer()
                                        .frame(width: (UIScreen.main.bounds.width - 16 * 2 - 10) / 2, height: 250)
                                }
                            }
                            .padding(.horizontal)
                            .frame(height: 250)
                            
                        }
                    }
                    
                    
                    Spacer()
                        .frame(height: 150)
                    
                }
                .padding(.top)
                .onAppear {
                    viewModelEffectsFotbudka.fetchEffectsFotobudka()
                    viewModelStylesFotbudka.fetchStylesFotobudka()
                }
            }
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(
                
                trailing:
                    HStack(spacing: 5) {
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
                        
                        if subscriptionManager.isSubscribed {
                            Button(action: {
                                avatarPaywallIsPresented = true
                            }, label: {
                                Text(sessionViewModel.userData != nil ?
                                     "\(sessionViewModel.userData!.stat.availableModels)/\(sessionViewModel.userData!.stat.maxModels) avatars"
                                     : "-/-")
                                .font(.subheadlineEmphasized)
                                .foregroundColor(.labelPrimary)
                                .padding(.horizontal, 10)
                                .frame(height: 32)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(
                                            LinearGradient(
                                                gradient: Gradient(colors: [Color.accentPrimary, Color.accentSecondary]),
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            ),
                                            lineWidth: 2
                                        )
                                )
                                .cornerRadius(8)
                            })
                            .fullScreenCover(isPresented: $avatarPaywallIsPresented) {
                                AvatarPayWall()
                            }
                            
                            
                            Button(action: {
                                creditsPaywallIsPresented = true
                            }, label: {
                                Text(sessionViewModel.userData != nil ?
                                     "\(sessionViewModel.userData!.stat.availableGenerations) credits"
                                     : "- credits")
                                .font(.subheadlineEmphasized)
                                .foregroundColor(.labelPrimary)
                                .padding(.horizontal, 10)
                                .frame(height: 32)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(
                                            LinearGradient(
                                                gradient: Gradient(colors: [Color.accentPrimary, Color.accentSecondary]),
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            ),
                                            lineWidth: 2
                                        )
                                )
                                .cornerRadius(8)
                            })
                            .fullScreenCover(isPresented: $creditsPaywallIsPresented) {
                                CreditsPaywall()
                            }
                        }
                    }
                
            )
            
        }
    }
}
