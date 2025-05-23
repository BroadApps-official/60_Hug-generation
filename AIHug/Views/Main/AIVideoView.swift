import SwiftUI

struct AIVideoView: View {
    
    @FetchRequest(sortDescriptors: []) var textGeneretionItems: FetchedResults<TextGenerations>
    @Environment(\.managedObjectContext) var moc
    @State private var generatedItem: TextGenerations?
    
    @StateObject private var viewModel = TemplatesViewModel()
    @StateObject private var viewModelHailuo = FiltersViewModel()
    @StateObject private var viewModelFotobudka = ScenariosViewModel()
    @EnvironmentObject var sessionViewModel: UserSessionViewModel
    
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    
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
    @State private var isImagePickerPresented = false
    @State private var selectedImage: UIImage? = nil
    @State private var isPhotoNeeded: Bool = false
    @FocusState private var isFocused: Bool
    @State private var type: String?
    @State private var creditsPaywallIsPresented = false
    
    @Binding var selectedTabIndex: Int
    
    private let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]
    
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
                                Image(systemName: "face.smiling")
                                    .foregroundColor(selectedSegment == 0 ? Color.labelPrimary : Color.labelTertiary)
                                    .font(.system(size: 14))
                                Text("Scenarios")
                                    .foregroundColor(selectedSegment == 0 ? Color.labelPrimary : Color.labelTertiary)
                                    .font(.footnoteEmphasized)
                                Spacer()
                            }
                            .frame(height: 40)
                            .background(selectedSegment == 0 ? Color.accentPrimaryAlpha : Color.backgroundTertiary)
                            .cornerRadius(20)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(selectedSegment == 0 ? Color.accentPrimary : Color.clear, lineWidth: 2)
                            )
                            .padding(.horizontal, 2)
                            
                            Button {
                                selectedSegment = 1
                            } label: {
                                Spacer()
                                Image(systemName: "highlighter")
                                    .foregroundColor(selectedSegment == 1 ? Color.labelPrimary : Color.labelTertiary)
                                    .font(.system(size: 14))
                                Text("Promt")
                                    .foregroundColor(selectedSegment == 1 ? Color.labelPrimary : Color.labelTertiary)
                                    .font(.footnoteEmphasized)
                                Spacer()
                            }
                            .frame(height: 40)
                            .background(selectedSegment == 1 ? Color.accentPrimaryAlpha : Color.backgroundTertiary)
                            .cornerRadius(20)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(selectedSegment == 1 ? Color.accentPrimary : Color.clear, lineWidth: 2)
                            )
                            .padding(.horizontal, 2)
                            
                            Button {
                                selectedSegment = 2
                            } label: {
                                Spacer()
                                Image(systemName: "sparkles")
                                    .foregroundColor(selectedSegment == 2 ? Color.labelPrimary : Color.labelTertiary)
                                    .font(.system(size: 14))
                                Text("Effects")
                                    .foregroundColor(selectedSegment == 2 ? Color.labelPrimary : Color.labelTertiary)
                                    .font(.footnoteEmphasized)
                                Spacer()
                            }
                            .frame(height: 40)
                            .background(selectedSegment == 2 ? Color.accentPrimaryAlpha : Color.backgroundTertiary)
                            .cornerRadius(20)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(selectedSegment == 2 ? Color.accentPrimary : Color.clear, lineWidth: 2)
                            )
                            .padding(.horizontal, 2)
                            
                        }
                        .padding(.horizontal)
                        .padding(.top)
                        
                        if selectedSegment == 0 {
                            
                            
                            //MARK: - Scenarios tab
                            
                            ScrollView(.vertical, showsIndicators: false) {
                                ForEach(viewModelFotobudka.groups) { group in
                                    LazyVGrid(columns: columns, spacing: 20) {
                                        ForEach(Array(group.scenarios.enumerated()), id: \.element.id) { index, scenario in
                                            NavigationLink(destination: AddPhotoView(items: group.scenarios, selectedIndex: index, aiModel: "scenario", type: "video")) {
                                                VideoCardView(item: scenario)
                                            }
                                        }
                                        
                                    }
                                    .padding()
                                }
                                
                                Spacer()
                                    .frame(height: 150)
                                
                            }
                            .padding(.top)
                            .onAppear {
                                viewModelFotobudka.fetchScenarios()
                            }
                            
                            
                            
                            
                        } else if selectedSegment == 1 {
                            
                            
                            //MARK: - Promt tab
                            
                            ZStack {
                                if promptText.isEmpty {
                                    
                                    VStack {
                                        HStack {
                                            Text("Enter your promt")
                                                .foregroundColor(.labelQuaternary)
                                                .font(.bodyRegular)
                                                .padding(8)
                                            
                                            Spacer()
                                        }
                                        .padding(.horizontal, 22)
                                        
                                        Spacer()
                                    }
                                    .frame(height: 160)
                                }
                                
                                
                                TextEditor(text: $promptText)
                                    .focused($isFocused)
                                    .transparentScrolling()
                                    .foregroundColor(.labelPrimary)
                                    .font(.bodyRegular)
                                    .frame(height: 160, alignment: .center)
                                    .padding(10)
                                    .background(RoundedRectangle(cornerRadius: 14)
                                        .fill(Color.backgroundTertiary))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14)
                                            .stroke(isFocused ? Color.accentPrimary : Color.clear, lineWidth: 1)
                                    )
                                    .padding(.horizontal)
                                    .onChange(of: promptText) { newValue in
                                        if newValue.count > 300 {
                                            promptText = String(newValue.prefix(300))
                                        }
                                    }
                                    .toolbar {
                                        ToolbarItemGroup(placement: .keyboard) {
                                            Spacer()
                                            Button("Done") {
                                                hideKeyboard()
                                            }
                                        }
                                    }
                                
                                
                                VStack {
                                    Spacer()
                                    
                                    HStack() {
                                        Text("\(promptText.count)/300")
                                            .font(.footnoteRegular)
                                            .foregroundColor(.labelQuaternary)
                                            .padding(.top)
                                        
                                        Spacer()
                                        
                                        if !promptText.isEmpty {
                                            
                                            Button(action: {
                                                UIPasteboard.general.string = promptText
                                            }) {
                                                HStack {
                                                    Image(systemName: "doc.on.doc.fill")
                                                        .font(.caption1Regular)
                                                        .foregroundColor(.labelPrimary)
                                                    
                                                    Spacer()
                                                        .frame(width: 4)
                                                    
                                                    Text("Copy")
                                                        .font(.footnoteRegular)
                                                        .foregroundColor(.labelPrimary)
                                                }
                                                .frame(width: 68, height: 32)
                                                .background(Color.backgroundDim)
                                                .cornerRadius(8)
                                            }
                                            
                                            Button(action: {
                                                promptText = ""
                                            }) {
                                                HStack {
                                                    Image(systemName: "trash")
                                                        .font(.caption1Regular)
                                                        .foregroundColor(.labelPrimary)
                                                    
                                                    Spacer()
                                                        .frame(width: 4)
                                                    
                                                    Text("Clear")
                                                        .font(.footnoteRegular)
                                                        .foregroundColor(.labelPrimary)
                                                }
                                                .frame(width: 64, height: 32)
                                                .background(Color.backgroundDim)
                                                .cornerRadius(8)
                                            }
                                            
                                        }
                                        
                                    }
                                    .padding(.horizontal)
                                    .frame(height: 32)
                                }
                                .padding()
                            }
                            .padding(.top)
                            
                            VStack {
                                HStack {
                                    Text("Use a photo")
                                        .foregroundColor(Color.labelSecondary)
                                        .padding(.leading)
                                    
                                    Spacer()
                                    
                                    Toggle("", isOn: $isPhotoNeeded.animation())
                                        .padding(.trailing)
                                        .toggleStyle(SwitchToggleStyle(tint: Color.accentSecondary))
                                }
                                .padding(.vertical, 10)
                                
                                if isPhotoNeeded {
                                    Button {
                                        if selectedImage == nil {
                                            isImagePickerPresented.toggle()
                                        } else {
                                            selectedImage = nil
                                        }
                                    } label: {
                                        Spacer()
                                        VStack(spacing: 0) {
                                            
                                            if let image = selectedImage {
                                                ZStack {
                                                    Image(uiImage: image)
                                                        .resizable()
                                                        .scaledToFill()
                                                        .frame(width: 100, height: 100)
                                                        .padding(0)
                                                        .cornerRadius(12)
                                                        .clipped()
                                                    
                                                    VStack {
                                                        HStack {
                                                            Spacer()
                                                            
                                                            Image(systemName: "xmark")
                                                                .foregroundColor(.labelPrimary)
                                                                .font(.caption1Regular)
                                                            
                                                                .frame(width: 32, height: 32)
                                                                .background(Color.backgroundQuaternary)
                                                                .cornerRadius(8)
                                                            
                                                        }
                                                        Spacer()
                                                    }
                                                }
                                            } else {
                                                Image(systemName: "plus")
                                                    .font(.bodyRegular)
                                                    .foregroundColor(.accentSecondary)
                                                    .padding(.bottom, 10)
                                                
                                                Text("Add a face")
                                                    .font(.footnoteEmphasized)
                                                    .foregroundColor(.accentSecondary)
                                            }
                                        }
                                        Spacer()
                                        
                                    }
                                    .frame(width: 100, height: 100)
                                    .background(Color.backgroundTertiary)
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .strokeBorder(
                                                style: StrokeStyle(lineWidth: 2, dash: [10])
                                            )
                                            .foregroundColor(selectedImage == nil ? .accentSecondary : .clear)
                                    )
                                    .padding(.bottom)
                                    .transition(.move(edge: .top).combined(with: .opacity))
                                    .animation(.easeInOut, value: isPhotoNeeded)
                                }
                            }
                            .background(Color.backgroundTertiary)
                            .cornerRadius(12)
                            .padding(.horizontal)
                            
                            
                            Button {
                                if !subscriptionManager.isSubscribed {
                                    isPresented = true
                                } else {
                                    isLoading = true
                                    
                                    type = "video"
                                    
                                    if selectedImage == nil {
                                        NetworkManager.shared.generateVideo(promptText: promptText) { result in
                                            switch result {
                                            case .success(let generationId):
                                                print("✅ Generation ID: \(generationId)")
                                                checkGenerationStatusPeriodically(generationId: ("\(generationId)"))
                                            case .failure(let error):
                                                print("❌ Ошибка: \(error.localizedDescription)")
                                                isLoading = false
                                                
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                                    showAlert = true
                                                }
                                            }
                                        }
                                    } else {
                                        NetworkManager.shared.generateVideoWithPhotoRef(promptText: promptText, image: selectedImage!) { result in
                                            switch result {
                                            case .success(let generationId):
                                                print("✅ Generation ID: \(generationId)")
                                                checkGenerationStatusPeriodically(generationId: ("\(generationId)"))
                                            case .failure(let error):
                                                print("❌ Ошибка: \(error.localizedDescription)")
                                                isLoading = false
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                                    showAlert = true
                                                }
                                            }
                                        }
                                    }
                                }
                                
                                
                            } label: {
                                HStack {
                                    Text("Create (1 credit)")
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
                            
                            
                        } else if selectedSegment == 2 {
                            
                            
                            //MARK: - Video effect tab
                            
                            ScrollView(.vertical, showsIndicators: false) {
                                VStack(alignment: .leading, spacing: 20) {
                                    ForEach(viewModel.groupedTemplates.keys.sorted(), id: \.self) { category in
                                        VStack(alignment: .leading, spacing: 10) {
                                            HStack {
                                                Text(category)
                                                    .font(.title3Emphasized)
                                                    .foregroundColor(.labelPrimary)
                                                
                                                Spacer()
                                                
                                                NavigationLink(destination: AllTemplatesView(items: viewModel.groupedTemplates[category] ?? [], type: "video", aiModel: "pika")) {
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
                                            
                                            HStack(spacing: 10) {
                                                ForEach(viewModel.groupedTemplates[category]?.prefix(2) ?? []) { template in
                                                    NavigationLink(destination: AddPhotoView(items: viewModel.groupedTemplates[category] ?? [], selectedIndex: 0, aiModel: "pika", type: "video")) {
                                                        VideoCardView(item: template)
                                                    }
                                                    
                                                }
                                            }
                                            .padding(.horizontal)
                                            .frame(height: 250)
                                            
                                        }
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 10) {
                                        HStack {
                                            Text("Hailuo effects")
                                                .font(.title3Emphasized)
                                                .foregroundColor(.labelPrimary)
                                            
                                            Spacer()
                                            
                                            NavigationLink(destination: AllTemplatesView(items: viewModelHailuo.filters, type: "video", aiModel: "hailuo")) {
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
                                        
                                        HStack(spacing: 10) {
                                            ForEach(Array(viewModelHailuo.filters.prefix(2).enumerated()), id: \.element.id) { index, filter in
                                                NavigationLink(destination: AddPhotoView(items: viewModelHailuo.filters, selectedIndex: index, aiModel: "hailuo", type: "video")) {
                                                    VideoCardView(item: filter)
                                                }
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
                                viewModel.fetchTemplates()
                                viewModelHailuo.fetchFilters()
                            }
                        }
                        
                        Spacer()
                            .frame(height: 150)
                        
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
                                
                                if subscriptionManager.isSubscribed {
                                    
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
        .fullScreenCover(isPresented: $isImagePickerPresented) {
            ImagePickerView(sourceType: .photoLibrary, selectedImage: $selectedImage)
                .edgesIgnoringSafeArea(.all)
        }
        .fullScreenCover(isPresented: $isLoading) {
            GenerationView()
        }
        .fullScreenCover(isPresented: $navigateToTextGeneratedView) {
            TextGeneratedView(item: $generatedItem, type: type)
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Video generation error"),
                message: Text("Something went wrong or the server is not responding. Try again or do it later."),
                primaryButton: .default(Text("Try Again"), action: {
                    showAlert = false
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        isLoading = true
                        
                        if selectedImage == nil {
                            NetworkManager.shared.generateVideo(promptText: promptText) { result in
                                switch result {
                                case .success(let generationId):
                                    print("✅ Generation ID: \(generationId)")
                                    checkGenerationStatusPeriodically(generationId: ("\(generationId)"))
                                case .failure(let error):
                                    print("❌ Ошибка: \(error.localizedDescription)")
                                    isLoading = false
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        showAlert = true
                                    }
                                }
                            }
                        } else {
                            NetworkManager.shared.generateVideoWithPhotoRef(promptText: promptText, image: selectedImage!) { result in
                                switch result {
                                case .success(let generationId):
                                    print("✅ Generation ID: \(generationId)")
                                    checkGenerationStatusPeriodically(generationId: ("\(generationId)"))
                                case .failure(let error):
                                    print("❌ Ошибка: \(error.localizedDescription)")
                                    isLoading = false
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        showAlert = true
                                    }
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
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    func checkGenerationStatusPeriodically(generationId: String) {
        var retryCount = 0
        let maxRetries = 30
        let retryInterval: TimeInterval = 5.0
        
        let newTextGenerations = TextGenerations(context: moc)
        newTextGenerations.id = UUID()
        newTextGenerations.date = Date()
        newTextGenerations.prompt = promptText
        if let selectedImage = selectedImage,
           let imageData = selectedImage.jpegData(compressionQuality: 0.5) {
            newTextGenerations.photoreference = imageData
        } else {
            newTextGenerations.photoreference = nil
        }
        newTextGenerations.url = nil
        newTextGenerations.type = type
        
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
