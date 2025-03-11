import SwiftUI
import AVKit

struct MainGenerationView: View {
    
    @FetchRequest(sortDescriptors: []) var imagesToVideo: FetchedResults<ImagesToVideo>
    @FetchRequest(sortDescriptors: []) var textToVideo: FetchedResults<TextToVideo>
    @Environment(\.managedObjectContext) var moc
    
    @StateObject private var viewModel = TemplatesViewModel()
    
    @State private var isPresented = false
    @State private var isLoading: Bool = false
    @State private var scrollOffset: CGFloat = 0
    @State private var selectedSegment = 0
    @State private var selectedTemplateID: Int? = nil
    @State private var selectedImage1: UIImage? = nil  // Для первой кнопки
    @State private var selectedImage2: UIImage? = nil
    @State private var isSheetPresented = false
    @State private var selectedButton: String? = nil
    @State private var selectedCategoryTitleEn: String? = nil
    @State private var mergedImage: UIImage?
    @State private var navigateToMergedView = false
    @State private var navigateToTextGeneratedView = false
    @State private var videoURL: String?
    @State private var showAlert = false
    @State private var promptText: String = ""
    
    // Button(action: {
    //     let newHistoryItem = History(context: moc)
    //     newHistoryItem.id = UUID()
    //     newHistoryItem.url = imageURL
    //     newHistoryItem.time = Date()
    //
    //     try? moc.save()
    //
    //     presentationMode.wrappedValue.dismiss()
    // }
    
    var body: some View {
        
        NavigationView {
            ZStack {
                Color.backgroundPrimary
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    
                    HStack {
                        Button {
                            selectedSegment = 0
                        } label: {
                            Spacer()
                            Text("Text to Video")
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
                            Text("Image to Video")
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
                    
                    if selectedSegment == 0 {
                        HStack {
                            Text("Enter prompt")
                                .font(.title1Emphasized)
                                .foregroundColor(.labelPrimary)
                            
                            Spacer()
                        }
                        .padding(.horizontal)
                        
                        
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
                        
                        Button {
                            isLoading = true
                            
                            NetworkManager.shared.generateVideo(promptText: promptText) { result in
                                switch result {
                                case .success(let generationId):
                                    print("✅ Generation ID: \(generationId)")
                                    checkGenerationStatusPeriodically(generationId: ("\(generationId)"))
                                case .failure(let error):
                                    print("❌ Ошибка: \(error.localizedDescription)")
                                    isLoading = false
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
                            .background(promtButtonEnabled ? Color.accentPrimary : Color.gray.opacity(0.5))
                            .cornerRadius(12)
                            .padding()
                        }
                        .disabled(!promtButtonEnabled)
                        
                        
                        
                    } else {
                        HStack {
                            Text("Select an effect:")
                                .font(.title1Emphasized)
                                .foregroundColor(.labelPrimary)
                            
                            Spacer()
                        }
                        .padding(.horizontal)
                        
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHStack(spacing: 10) {
                                ForEach(viewModel.templates) { template in
                                    TemplateCard(
                                        template: template,
                                        isSelected: selectedTemplateID == template.id,
                                        onSelect: {
                                            selectedTemplateID = template.id
                                            selectedCategoryTitleEn = template.categoryTitleEn
                                            print("Selected template ID:", template.id)
                                        }
                                    )
                                }
                            }
                            .padding()
                        }
                        .onAppear {
                            viewModel.fetchTemplates()
                        }
                        .frame(height: 148)
                        .padding(.bottom, 10)
                        
                        HStack {
                            Text("Select a photo:")
                                .font(.title1Emphasized)
                                .foregroundColor(.labelPrimary)
                            
                            Spacer()
                        }
                        .padding(.horizontal)
                        
                        HStack() {
                            
                            Button {
                                selectedButton = "Image 1"
                                isSheetPresented.toggle()
                            } label: {
                                Spacer()
                                VStack(spacing: 0) {
                                    
                                    if let image = selectedImage1 {
                                        ZStack {
                                            Image(uiImage: image)
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 172, height: 148)
                                                .cornerRadius(12)
                                                .clipped()
                                            
                                            VStack {
                                                Spacer()
                                                HStack {
                                                    Spacer()
                                                    HStack{
                                                        Image(systemName: "arrow.triangle.2.circlepath")
                                                            .foregroundColor(.labelPrimary)
                                                            .font(.caption1Regular)
                                                        Text("Change")
                                                            .foregroundColor(.labelPrimary)
                                                            .font(.footnoteRegular)
                                                    }
                                                    .padding(.vertical, 12)
                                                    .padding(.horizontal, 8)
                                                    .background(Color.backgroundDim)
                                                    .cornerRadius(8)
                                                    .padding()
                                                    
                                                }
                                            }
                                        }
                                        
                                        
                                    } else {
                                        Image(systemName: "plus")
                                            .font(.largeTitleRegular)
                                            .foregroundColor(.accentSecondary)
                                            .padding(.bottom, 10)
                                        
                                        Text("Image 1")
                                            .font(.calloutEmphasized)
                                            .foregroundColor(.accentSecondary)
                                    }
                                }
                                Spacer()
                            }
                            .frame(width: 172, height: 148)
                            .background(Color.backgroundTertiary)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .strokeBorder(
                                        style: StrokeStyle(lineWidth: 2, dash: [10])
                                    )
                                    .foregroundColor(selectedImage1 == nil ? .accentSecondary : .clear)
                            )
                            
                            Spacer()
                            
                            Button {
                                selectedButton = "Image 2"
                                isSheetPresented.toggle()
                            } label: {
                                Spacer()
                                VStack(spacing: 0) {
                                    
                                    if let image = selectedImage2 {
                                        ZStack {
                                            Image(uiImage: image)
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 172, height: 148)
                                                .cornerRadius(12)
                                                .clipped()
                                            
                                            VStack {
                                                Spacer()
                                                HStack {
                                                    Spacer()
                                                    HStack{
                                                        Image(systemName: "arrow.triangle.2.circlepath")
                                                            .foregroundColor(.labelPrimary)
                                                            .font(.caption1Regular)
                                                        Text("Change")
                                                            .foregroundColor(.labelPrimary)
                                                            .font(.footnoteRegular)
                                                    }
                                                    .padding(.vertical, 12)
                                                    .padding(.horizontal, 8)
                                                    .background(Color.backgroundDim)
                                                    .cornerRadius(8)
                                                    .padding()
                                                    
                                                }
                                            }
                                        }
                                    } else {
                                        Image(systemName: "plus")
                                            .font(.largeTitleRegular)
                                            .foregroundColor(.accentSecondary)
                                            .padding(.bottom, 10)
                                        
                                        Text("Image 2")
                                            .font(.calloutEmphasized)
                                            .foregroundColor(.accentSecondary)
                                    }
                                }
                                Spacer()
                                
                            }
                            .frame(width: 172, height: 148)
                            .background(Color.backgroundTertiary)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .strokeBorder(
                                        style: StrokeStyle(lineWidth: 2, dash: [10])
                                    )
                                    .foregroundColor(selectedImage2 == nil ? .accentSecondary : .clear)
                            )
                        }
                        .padding(.horizontal)
                        
                        Button {
                            isLoading = true
                            
                            if let image1 = selectedImage1, let image2 = selectedImage2 {
                                mergedImage = combineImagesHorizontally(image1: image1, image2: image2)
                                
                                guard let mergedImage = mergedImage else {
                                    print("❌ Ошибка: не удалось объединить изображения")
                                    isLoading = false
                                    return
                                }
                                
                                guard let imageURL = saveImageToTemporaryDirectory(image: mergedImage) else {
                                    print("❌ Ошибка: не удалось сохранить изображение")
                                    isLoading = false
                                    return
                                }
                                
                                // Первый запрос: Генерация видео
                                NetworkManager.shared.generateImage(
                                    templateId: selectedTemplateID,
                                    imageURL: imageURL
                                ) { result in
                                    switch result {
                                    case .success(let generationId):
                                        print("✅ Generation ID получен: \(generationId)")
                                        
                                        // Запуск проверки статуса с интервалом
                                        checkGenerationStatusPeriodically(generationId: ("\(generationId)"))
                                        
                                    case .failure(let error):
                                        print("❌ Ошибка генерации: \(error.localizedDescription)")
                                        isLoading = false
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
                            .background(isButtonEnabled ? Color.accentPrimary : Color.gray.opacity(0.5))
                            .cornerRadius(12)
                            .padding()
                        }
                        .disabled(!isButtonEnabled)
                    }
                    
                    Spacer()
                    
                }
                .navigationBarBackButtonHidden(true)
                .navigationTitle(
                    Text("Generation")
                )
                .navigationBarTitleDisplayMode(.large)
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
        .sheet(isPresented: $isSheetPresented) {
            PhotoPicker(selectedButton: $selectedButton, selectedImage: selectedButton == "Image 1" ? $selectedImage1 : $selectedImage2)
        }
        .fullScreenCover(isPresented: $isLoading) {
            GenerationView()
        }
        .fullScreenCover(isPresented: $navigateToMergedView) {
            GeneratedView(selectedCategoryTitleEn: $selectedCategoryTitleEn, selectedImage1: $selectedImage1, selectedImage2: $selectedImage2, videoURL: $videoURL)
            
        }
        .fullScreenCover(isPresented: $navigateToTextGeneratedView) {
            TextGeneratedView(videoURL: $videoURL, promptText: $promptText)
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Ошибка"),
                message: Text("Превышено количество попыток."),
                dismissButton: .default(Text("Ок"))
            )
        }
    }
    
    private var isButtonEnabled: Bool {
        selectedImage1 != nil && selectedImage2 != nil && selectedTemplateID != nil
    }
    
    private var promtButtonEnabled: Bool {
        !promptText.isEmpty
    }
    
    func saveImageToTemporaryDirectory(image: UIImage) -> URL? {
        let tempDirectory = FileManager.default.temporaryDirectory
        let fileURL = tempDirectory.appendingPathComponent("merged_image.jpg")
        
        if let data = image.jpegData(compressionQuality: 0.8) {
            do {
                try data.write(to: fileURL)
                return fileURL
            } catch {
                print("❌ Ошибка сохранения изображения: \(error.localizedDescription)")
                isLoading = false
            }
        }
        return nil
    }
    
    func checkGenerationStatusPeriodically(generationId: String) {
        var retryCount = 0
        let maxRetries = 30
        let retryInterval: TimeInterval = 5.0
        
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
                        isLoading = false
                        if selectedSegment == 0 {
                            self.navigateToTextGeneratedView = true
                        } else {
                            self.navigateToMergedView = true
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

import SwiftUI
import AVKit

struct TemplateCard: View {
    let template: Template
    @State private var player: AVPlayer?
    @State private var isLoading = true
    var isSelected: Bool
    var onSelect: () -> Void
    
    var body: some View {
        ZStack(alignment: .bottom) {
            if isLoading {
                Color.gray.opacity(0.3)
                    .frame(width: 170, height: 148)
                    .cornerRadius(12)
                    .overlay(
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    )
            } else {
                VideoPlayerView(player: $player)
                    .frame(width: 170, height: 148)
                    .cornerRadius(12)
            }
            
            LinearGradient(
                gradient: Gradient(colors:
                                    [Color(red: 25/255, green: 25/255, blue: 25/255),
                                     Color(red: 21/255, green: 21/255, blue: 21/255, opacity: 0.5),
                                     Color(red: 32/255, green: 32/255, blue: 32/255, opacity: 0)]
                                  ),
                startPoint: .bottom,
                endPoint: .top
            )
            .frame(height: 52)
            .cornerRadius(12)
            
            Text(template.effect)
                .font(.subheadlineEmphasized)
                .foregroundColor(.labelPrimary)
                .padding(.bottom, 10)
                .multilineTextAlignment(.center)
            
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color.accentPrimary : Color.clear, lineWidth: 2)
            
            
        }
        .frame(width: 170, height: 148)
        .onTapGesture {
            onSelect()
        }
        .onAppear {
            setupPlayer()
        }
    }
    
    private func setupPlayer() {
        guard let url = URL(string: template.previewSmall) else {
            print("Invalid URL: \(template.previewSmall)")
            return
        }
        
        print("Loading video from: \(url)")
        
        let newPlayer = AVPlayer(url: url)
        newPlayer.isMuted = true
        newPlayer.actionAtItemEnd = .none
        
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: newPlayer.currentItem,
            queue: .main
        ) { _ in
            newPlayer.seek(to: .zero)
            newPlayer.play()
        }
        
        player = newPlayer
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            isLoading = false
            player?.play()
        }
    }
}

struct VideoPlayerView: UIViewControllerRepresentable {
    @Binding var player: AVPlayer?
    
    func makeUIViewController(context: Context) -> UIViewController {
        let controller = AVPlayerViewController()
        controller.player = player
        controller.showsPlaybackControls = false
        controller.videoGravity = .resizeAspectFill
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        guard let controller = uiViewController as? AVPlayerViewController else { return }
        controller.player = player
    }
}

struct MergedImageView: View {
    let image: UIImage
    
    var body: some View {
        VStack {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .padding()
            
            Spacer()
        }
        .navigationTitle("Результат")
        .navigationBarTitleDisplayMode(.inline)
    }
}
