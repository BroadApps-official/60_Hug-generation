import SwiftUI

struct AllAvatarsView: View {
    
    @FetchRequest(sortDescriptors: []) var textGeneretionItems: FetchedResults<TextGenerations>
    @Environment(\.managedObjectContext) var moc
    @State private var generatedItem: TextGenerations?
    
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var sessionViewModel: UserSessionViewModel
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    
    @State private var selectedImages: [UIImage] = []
    @State private var avatars: [Avatar] = []
    @State private var avatarPaywallIsPresented = false
    @State private var creditsPaywallIsPresented = false
    @State private var showActionSheet = false
    @State private var imageSource: UIImagePickerController.SourceType?
    @State private var isImagePickerPresented = false
    @State private var isLoading = false
    @State private var navigateToTextGeneratedView = false
    @State private var generatedURL: String?
    
    @State private var showAlert = false
    @State private var alertType: AlertType?
    
    let templateID: String
    
    private var placeholderImage: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.1))
                .frame(width: 80, height: 80)
            
            Image(systemName: "photo")
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)
                .foregroundColor(.gray)
        }
    }
    
    
    enum AlertType {
        case successDownloading
        case failedDownloading
    }
    
    var body: some View {
        
        ZStack {
            Color.backgroundPrimary
                .edgesIgnoringSafeArea(.all)
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack {
                    
                    NavigationLink(destination: AvatarView()) {
                        Text("New avatar")
                            .font(.headlineRegular)
                            .foregroundColor(.labelSecondary)
                            .frame(height: 80)
                            .frame(maxWidth: .infinity)
                            .background(Color.backgroundTertiary)
                            .cornerRadius(12)
                            .padding()
                    }
                    
                    
                    if avatars.isEmpty {
                        VStack(alignment: .center, spacing: 6) {
                            
                            
                            Text("No active avatars")
                                .font(.title3Emphasized)
                                .foregroundColor(.labelPrimary)
                            
                            Text("Create your first avatar to get started")
                                .font(.footnoteRegular)
                                .foregroundColor(.labelSecondary)
                            
                            NavigationLink(destination: AvatarView()) {
                                Text("Create avatar")
                                    .foregroundColor(.labelPrimary)
                                    .font(.bodyEmphasized)
                                    .frame(width: 280, height: 48)
                                    .background(Color.accentPrimary)
                                    .cornerRadius(12)
                                    .padding(.top)
                            }
                            
                        }
                        .frame(height: 500)
                    } else {
                        ForEach(avatars) { avatar in
                            HStack(spacing: 16) {
                                if let previewURLString = avatar.preview,
                                   let url = URL(string: previewURLString) {
                                    
                                    AsyncImage(url: url) { phase in
                                        switch phase {
                                        case .empty:
                                            ProgressView()
                                                .frame(width: 80, height: 80)
                                        case .success(let image):
                                            image
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 80, height: 80)
                                                .cornerRadius(12)
                                                .clipped()
                                        case .failure:
                                            placeholderImage
                                        @unknown default:
                                            placeholderImage
                                        }
                                    }
                                } else {
                                    placeholderImage
                                }
                                
                                
                                
                                Text("# \(avatar.id)")
                                    .font(.headline)
                                    .foregroundColor(.labelPrimary)
                                
                                Spacer()
                            }
                            .background(Color.backgroundTertiary)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(avatar.isActive ? Color.accentPrimary : Color.clear, lineWidth: 2)
                            )
                            .cornerRadius(12)
                            .padding(.horizontal)
                        }
                        
                        
                        
                        
                        Button {
                            
                            isLoading = true
                            
                            if let activeAvatarID = avatars.first(where: { $0.isActive })?.id {
                                NetworkManager.shared.photoStylesGenerate(templateID: templateID, avatarID: "\(activeAvatarID)") { result in
                                    switch result {
                                    case .success(let generationId):
                                        print("✅ ID получен: \(generationId)")
                                        checkGenerationStatusPeriodicallyFotobudka(jobId: generationId)
                                    case .failure(let error):
                                        print("❌ Ошибка генерации: \(error.localizedDescription)")
                                        isLoading = false
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                            alertType = .failedDownloading
                                            showAlert = true
                                        }
                                    }
                                }
                            }
                            
                        } label: {
                            Text("Create (1 credit)")
                                .font(.bodyEmphasized)
                                .foregroundColor(.labelPrimary)
                                .frame(height: 48)
                                .frame(maxWidth: .infinity)
                                .background(avatars.isEmpty ? Color.accentGrey : Color.accentPrimary)
                                .cornerRadius(12)
                                .padding(.horizontal)
                        }
                        .padding(.top)
                        .opacity(avatars.isEmpty ? 0.12 : 1)
                        .disabled(avatars.isEmpty)
                        
                        NavigationLink(destination: AvatarView()) {
                            Text("Create anew")
                                .font(.calloutRegular)
                                .foregroundColor(selectedImages.isEmpty ? Color.labelQuintuple : Color.labelTertiary)
                                .padding(.top, 10)
                        }
                    }
                    
                    
                    
                    
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
                
                
                Spacer()
                    .frame(height: 150)
            }
            
            
        }
        .alert(isPresented: $showAlert) {
            switch alertType {
            case .successDownloading:
                return Alert(
                    title: Text("Video saved to gallery"),
                    dismissButton: .default(Text("OK"))
                )
            case .failedDownloading:
                return Alert(
                    title: Text("Error"),
                    message: Text("Something went wrong or the server is not responding. Try again or do it later."),
                    primaryButton: .default(Text("Try Again"), action: {
                        showAlert = false
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            alertType = .failedDownloading
                            showAlert = true
                        }
                    }),
                    secondaryButton: .cancel()
                )
            case .none:
                return Alert(title: Text("Ошибка"))
            }
        }
        .fullScreenCover(isPresented: $avatarPaywallIsPresented) {
            AvatarPayWall()
        }
        .fullScreenCover(isPresented: $isLoading) {
            GenerationView()
        }
        .fullScreenCover(isPresented: $navigateToTextGeneratedView) {
            TextGeneratedView(item: $generatedItem, type: "photo")
        }
        .onAppear {
            
            NetworkManager.shared.getAvatars { result in
                switch result {
                case .success(let avatars):
                    self.avatars = avatars
                    print("✅ Полученные аватары:")
                    for avatar in avatars {
                        print("- ID: \(avatar.id), Gender: \(avatar.gender), Active: \(avatar.isActive)")
                    }
                case .failure(let error):
                    print("❌ Ошибка получения аватаров: \(error.localizedDescription)")
                }
            }
        }
        
    }
    
    func checkGenerationStatusPeriodicallyFotobudka(jobId: String) {
        var retryCount = 0
        let maxRetries = 60
        let retryInterval: TimeInterval = 5.0
        
        
        let newTextGenerations = TextGenerations(context: moc)
        newTextGenerations.id = UUID()
        newTextGenerations.date = Date()
        newTextGenerations.url = nil
        newTextGenerations.type = "photo"
        
        do {
            try moc.save()
            self.generatedItem = newTextGenerations
        } catch {
            print("❌ Ошибка сохранения в CoreData: \(error.localizedDescription)")
        }
        
        
        let objectID = newTextGenerations.objectID
        
        func checkStatus() {
            if retryCount >= maxRetries {
                print("❌ Превышено количество попыток")
                isLoading = false
                showAlert = true
                return
            }
            
            NetworkManager.shared.getGenerationStatusFotobudka(jobId: jobId) { result in
                switch result {
                case .success(let generationData):
                    print("✅ Фото готово: \(generationData.resultUrl)")
                    DispatchQueue.main.async {
                        self.generatedURL = generationData.resultUrl
                        
                        moc.perform {
                            if let existingTextGenerations = try? moc.existingObject(with: objectID) as? TextGenerations {
                                existingTextGenerations.url = generationData.resultUrl
                                do {
                                    try moc.save()
                                    DispatchQueue.main.async {
                                        self.generatedItem = existingTextGenerations
                                        print("✅ URL сохранён в CoreData")
                                        
                                        isLoading = false
                                        sessionViewModel.refreshUserData()
                                        self.navigateToTextGeneratedView = true
                                    }
                                } catch {
                                    print("❌ Ошибка обновления URL в CoreData: \(error.localizedDescription)")
                                }
                            }
                        }
                    }
                    
                case .failure(let error):
                    print("❌ Ошибка получения статуса: \(error.localizedDescription)")
                    retryCount += 1
                    DispatchQueue.main.asyncAfter(deadline: .now() + retryInterval) {
                        checkStatus()
                    }
                }
            }
        }
        
        checkStatus()
    }
    
    
}
