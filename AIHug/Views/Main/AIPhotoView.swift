import SwiftUI
import AVKit

struct AIPhotoView: View {
    
    @StateObject private var viewModelEffectsFotbudka = EffectsViewModel()
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    
    @State private var isPresented = false

    var body: some View {
        
        NavigationView {
            ZStack {
                Color.backgroundPrimary
                    .edgesIgnoringSafeArea(.all)
                
                ScrollView(.vertical, showsIndicators: false) {

                        ForEach(viewModelEffectsFotbudka.groups) { group in
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Text(group.title)
                                        .font(.title3Emphasized)
                                        .foregroundColor(.labelPrimary)
                                    
                                    Spacer()
                                    
                                    NavigationLink(destination: AllTemplatesView(items: group.effects, type: "photo")) {
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
                }
            }
            .navigationBarBackButtonHidden(true)
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
        }
    }
}
