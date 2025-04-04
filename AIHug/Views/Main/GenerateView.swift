import SwiftUI

struct StyleOption: Identifiable {
    let id = UUID()
    let name: String
    let imageName: String
    let hiddenPrompt: String
}

struct GenerateView: View {
    
    @FetchRequest(sortDescriptors: []) var textGeneretionItems: FetchedResults<TextGenerations>
    @Environment(\.managedObjectContext) var moc
    @State private var generatedItem: TextGenerations?
    
    @State private var isPresented = false
    @State private var isLoading: Bool = false
    @State private var scrollOffset: CGFloat = 0
    @State private var selectedSegment = 1
    @State private var isSheetPresented = false
    @State private var selectedButton: String? = nil
    @State private var navigateToTextGeneratedView = false
    @State private var videoURL: String?
    @State private var showAlert = false
    @State private var promptText: String = ""
    @State private var styleName: String = ""
    @State private var styleImageName: String = ""
    @State private var isImagePickerPresented = false
    @State private var selectedImage: UIImage? = nil
    
    let styles: [StyleOption] = [
        StyleOption(name: "No style", imageName: "noStyle", hiddenPrompt: ""),
        StyleOption(name: "Anime", imageName: "animeStyle", hiddenPrompt: "generate an anime-style video"),
        StyleOption(name: "Art", imageName: "artStyle", hiddenPrompt: "generate an art-style video"),
        StyleOption(name: "Realistic", imageName: "realisticStyle", hiddenPrompt: "generate an realistic-style video"),
        StyleOption(name: "Surreal", imageName: "surrealStyle", hiddenPrompt: "generate an surreal-style video"),
        StyleOption(name: "Fantasy", imageName: "fantasyStyle", hiddenPrompt: "generate an fantasy-style video"),
        StyleOption(name: "Abstract", imageName: "abstractStyle", hiddenPrompt: "generate an abstract-style video")
    ]
    
    @State private var selectedStyle: StyleOption?
    
    init() {
        _selectedStyle = State(initialValue: styles.first)
    }
    
    var body: some View {
        
        NavigationView {
            ZStack {
                Color.backgroundPrimary
                    .edgesIgnoringSafeArea(.all)
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack {
                        
                        HStack {
                            Button {
                                selectedSegment = 0
                            } label: {
                                Spacer()
                                Text("Photo")
                                    .foregroundColor(.labelPrimary)
                                    .font(.footnoteEmphasized)
                                Spacer()
                            }
                            .frame(height: 32)
                            .background(selectedSegment == 0 ? Color.accentPrimary : Color.clear)
                            .cornerRadius(8)
                            .padding(.horizontal, 2)
                            
                            Button {
                                selectedSegment = 1
                            } label: {
                                Spacer()
                                Text("Video")
                                    .foregroundColor(.labelPrimary)
                                    .font(.footnoteEmphasized)
                                Spacer()
                            }
                            .frame(height: 32)
                            .background(selectedSegment == 1 ? Color.accentPrimary : Color.clear)
                            .cornerRadius(8)
                            .padding(.horizontal, 2)
                            
                        }
                        .frame(height: 36)
                        .background(Color.backgroundTertiary)
                        .cornerRadius(9)
                        .padding(.horizontal)
                        .padding(.top, 10)
                        
                        if selectedSegment == 1 {
                            HStack {
                                Text("Enter prompt")
                                    .font(.title3Emphasized)
                                    .foregroundColor(.labelPrimary)
                                
                                Spacer()
                            }
                            .padding(.horizontal)
                            .padding(.top)
                            
                            
                            ZStack {
                                if promptText.isEmpty {
                                    
                                    VStack {
                                        HStack {
                                            Text("Enter any query to create your video using AI")
                                                .foregroundColor(.labelQuaternary)
                                                .font(.bodyRegular)
                                                .padding(8)
                                            
                                            Spacer()
                                        }
                                        .padding(.horizontal, 22)
                                        
                                        Spacer()
                                    }
                                    .frame(height: 120)
                                }
                                
                                TextEditor(text: $promptText)
                                    .transparentScrolling()
                                    .foregroundColor(.labelPrimary)
                                    .font(.bodyRegular)
                                    .frame(height: 120, alignment: .center)
                                    .padding(10)
                                    .background(RoundedRectangle(cornerRadius: 14)
                                        .fill(Color.backgroundTertiary))
                                    .padding(.horizontal, 16)
                            }
                            .overlay(
                                HStack {
                                    Spacer()
                                    if !promptText.isEmpty {
                                        Button(action: {
                                            promptText = ""
                                        }) {
                                            Image(systemName: "trash")
                                                .foregroundColor(.labelPrimary)
                                                .frame(width: 42, height: 42)
                                                .background(Color.backgroundDim)
                                                .cornerRadius(21)
                                        }
                                        .padding(10)
                                    }
                                    
                                }
                                    .padding(.horizontal)
                                , alignment: .bottomTrailing
                            )
                            
                            HStack {
                                Text("Choose style")
                                    .font(.title3Emphasized)
                                    .foregroundColor(.labelPrimary)
                                
                                Spacer()
                            }
                            .padding(.horizontal)
                            .padding(.top)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(styles) { style in
                                        VStack {
                                            ZStack {
                                                Circle()
                                                    .fill(Color.gray.opacity(0.3))
                                                    .frame(width: 56, height: 56)
                                                    .overlay(
                                                        Image(style.imageName)
                                                            .resizable()
                                                            .scaledToFill()
                                                            .clipShape(Circle())
                                                    )
                                                    .overlay(
                                                        Circle()
                                                            .stroke(selectedStyle?.id == style.id ? Color.accentPrimary : Color.clear, lineWidth: 2)
                                                    )
                                            }
                                            Text(style.name)
                                                .font(.caption)
                                                .foregroundColor(.white)
                                        }
                                        .onTapGesture {
                                            selectedStyle = style
                                            styleName = style.name
                                            styleImageName = style.imageName
                                        }
                                    }
                                }
                                .padding(.horizontal)
                                .padding(.top, 2)
                                
                            }
                            
                            HStack {
                                Text("Reference")
                                    .font(.title3Emphasized)
                                    .foregroundColor(.labelPrimary)
                                
                                Spacer()
                            }
                            .padding(.horizontal)
                            .padding(.top)
                            
                            Button {
                                if selectedImage == nil {
                                    isImagePickerPresented.toggle()
                                } else {
                                    selectedImage = nil
                                }
                            } label: {
                                HStack(spacing: 0) {
                                    if selectedImage == nil {
                                        Image(systemName: "plus")
                                            .foregroundColor(.labelPrimary)
                                            .frame(width: 32, height: 32)
                                        
                                        Text("Upload image")
                                            .font(.bodyEmphasized)
                                            .foregroundColor(.labelPrimary)
                                    } else {
                                        Image(uiImage: selectedImage!)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 32, height: 32)
                                            .cornerRadius(6)
                                            .padding(.trailing, 10)
                                        
                                        Text("Remove")
                                            .font(.bodyEmphasized)
                                            .foregroundColor(.labelPrimary)
                                    }
                                    
                                }
                                .frame(height: 48)
                                .frame(maxWidth: .infinity)
                                .background(Color.backgroundTertiary)
                                .cornerRadius(12)
                                .padding(.horizontal)
                            }
                            
                            Button {
                                isLoading = true
                                
                                if selectedImage == nil {
                                    NetworkManager.shared.generateVideo(promptText: ("\(promptText). \(selectedStyle?.hiddenPrompt ?? "")")) { result in
                                        switch result {
                                        case .success(let generationId):
                                            print("✅ Generation ID: \(generationId)")
                                            checkGenerationStatusPeriodically(generationId: ("\(generationId)"))
                                        case .failure(let error):
                                            print("❌ Ошибка: \(error.localizedDescription)")
                                            isLoading = false
                                        }
                                    }
                                } else {
                                    NetworkManager.shared.generateVideoWithPhotoRef(promptText: ("\(promptText). \(selectedStyle?.hiddenPrompt ?? "")"), image: selectedImage!) { result in
                                        switch result {
                                        case .success(let generationId):
                                            print("✅ Generation ID: \(generationId)")
                                            checkGenerationStatusPeriodically(generationId: ("\(generationId)"))
                                        case .failure(let error):
                                            print("❌ Ошибка: \(error.localizedDescription)")
                                            isLoading = false
                                            showAlert = true
                                        }
                                    }
                                }
                                
                            } label: {
                                HStack {
                                    Image(systemName: "wand.and.stars")
                                        .foregroundColor(.labelPrimary)
                                        .frame(width: 32, height: 32)
                                    
                                    Text("Create a masterpiece")
                                        .font(.bodyEmphasized)
                                        .foregroundColor(.labelPrimary)
                                }
                                .frame(height: 48)
                                .frame(maxWidth: .infinity)
                                .background(promtButtonEnabled ? Color.accentPrimary : Color.accentGrey)
                                .cornerRadius(12)
                                .padding(.horizontal)
                                .padding(.top)
                            }
                            .opacity(promtButtonEnabled ? 1 : 0.12)
                            .disabled(!promtButtonEnabled)
                            
                        }
                        
                        Spacer()
                            .frame(height: 150)
                        
                    }
                    .background(GeometryReader { geometry in
                        Color.clear.onAppear {
                            self.scrollOffset = geometry.frame(in: .global).minY
                        }
                        .onChange(of: geometry.frame(in: .global).minY) { value in
                            self.scrollOffset = value
                        }
                    })
                    .navigationBarBackButtonHidden(true)
                    .navigationTitle(
                        Text("Generation")
                    )
                    .navigationBarTitleDisplayMode(scrollOffset < -100 ? .inline : .large)
                    .navigationBarItems(
                        trailing:
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
                            .sheet(isPresented: $isPresented) {
                                PayWall()
                            }
                        
                    )
                }
                
                
            }
        }
        .fullScreenCover(isPresented: $isImagePickerPresented) {
            ImagePickerView(sourceType: .photoLibrary, selectedImage: $selectedImage)
                .edgesIgnoringSafeArea(.all)
        }
        .fullScreenCover(isPresented: $isLoading) {
            GenerationView()
        }
        .fullScreenCover(isPresented: $navigateToTextGeneratedView) {
            TextGeneratedView(item: $generatedItem)
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Video generation error"),
                message: Text("Something went wrong or the server is not responding. Try again or do it later."),
                primaryButton: .default(Text("Try Again"), action: {
                    showAlert = false
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        if selectedImage == nil {
                            NetworkManager.shared.generateVideo(promptText: ("\(promptText). \(selectedStyle?.hiddenPrompt ?? "")")) { result in
                                switch result {
                                case .success(let generationId):
                                    print("✅ Generation ID: \(generationId)")
                                    checkGenerationStatusPeriodically(generationId: ("\(generationId)"))
                                case .failure(let error):
                                    print("❌ Ошибка: \(error.localizedDescription)")
                                    isLoading = false
                                }
                            }
                        } else {
                            NetworkManager.shared.generateVideoWithPhotoRef(promptText: ("\(promptText). \(selectedStyle?.hiddenPrompt ?? "")"), image: selectedImage!) { result in
                                switch result {
                                case .success(let generationId):
                                    print("✅ Generation ID: \(generationId)")
                                    checkGenerationStatusPeriodically(generationId: ("\(generationId)"))
                                case .failure(let error):
                                    print("❌ Ошибка: \(error.localizedDescription)")
                                    isLoading = false
                                    showAlert = true
                                }
                            }
                        }
                    }
                }),
                secondaryButton: .cancel()
            )
        }
    }
    
    private var promtButtonEnabled: Bool {
        !promptText.isEmpty
    }
    
    func checkGenerationStatusPeriodically(generationId: String) {
        var retryCount = 0
        let maxRetries = 30
        let retryInterval: TimeInterval = 5.0
        
        let newTextGenerations = TextGenerations(context: moc)
        newTextGenerations.id = UUID()
        newTextGenerations.date = Date()
        newTextGenerations.prompt = promptText
        newTextGenerations.url = nil
        newTextGenerations.styleName = selectedStyle?.name
        newTextGenerations.styleImageName = selectedStyle?.imageName
        
        self.generatedItem = newTextGenerations
        
        do {
            try moc.save()
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
            
            NetworkManager.shared.getGenerationStatus(generationId: generationId) { result in
                switch result {
                case .success(let videoURL):
                    print("✅ Видео готово: \(videoURL)")
                    DispatchQueue.main.async {
                        self.videoURL = videoURL
                        
                        moc.perform {
                            if let existingTextGenerations = try? moc.existingObject(with: objectID) as? TextGenerations {
                                existingTextGenerations.url = videoURL
                                do {
                                    try moc.save()
                                    DispatchQueue.main.async {
                                        self.generatedItem = existingTextGenerations
                                        print("✅ URL сохранён в CoreData")
                                        
                                        isLoading = false
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
