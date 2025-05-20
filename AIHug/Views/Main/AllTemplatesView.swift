import SwiftUI

struct AllTemplatesView<T: Identifiable & PreviewPlayable>: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @EnvironmentObject var sessionViewModel: UserSessionViewModel
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    
    @State private var avatarPaywallIsPresented = false
    @State private var creditsPaywallIsPresented = false
    
    let items: [T]
    let type: String
    
    private let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                    if type == "style" {
                        NavigationLink(destination: AvatarView()) {
                            if type == "video" {
                                VideoCardView(item: item)
                            } else {
                                ImageCardView(item: item)
                            }
                        }
                    } else {
                        NavigationLink(destination: AddPhotoView(items: items, selectedIndex: index, aiModel: "", type: type)) {
                            if type == "video" {
                                VideoCardView(item: item)
                            } else {
                                ImageCardView(item: item)
                            }
                        }
                    }
                    
                }

            }
            .padding()
            
            Spacer().frame(height: 150)
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(
            leading:
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }, label: {
                    HStack(spacing: 10) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.accentPrimary)
                    }
                }),
            trailing:
                HStack(spacing: 5) {
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
