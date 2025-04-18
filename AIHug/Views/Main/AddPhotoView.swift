import AVKit
import SwiftUI

struct AddPhotoView<T: PreviewPlayable>: View {
    
    @FetchRequest(sortDescriptors: []) var textGeneretionItems: FetchedResults<TextGenerations>
    @Environment(\.managedObjectContext) var moc
    @State private var generatedItem: TextGenerations?
    
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    
    let item: T
    @State private var selectedImage: UIImage?
    @State private var isSheetPresented = false
    @State private var isLoading = false
    @State private var navigateToTextGeneratedView = false
    @State private var videoURL: String?
    @State private var showAlert = false
    @State private var isPresented = false

    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack {
                
                MiniTemplateCard(item: item)
                    .padding(.vertical, 20)
                
                HStack {
                    Text("Upload photo")
                        .font(.title3Emphasized)
                        .foregroundColor(.labelPrimary)
                    
                    Spacer()
                }
                .padding(.horizontal)
                
                Button {
                    isSheetPresented.toggle()
                } label: {
                    Spacer()
                    VStack(spacing: 0) {
                        
                        if let image = selectedImage {
                            ZStack {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 352, height: 352)
                                    .padding(0)
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
                                .foregroundColor(.labelPrimaryInvariably)
                                .padding(.bottom, 10)
                            
                            Text("Add photo")
                                .font(.calloutRegular)
                                .foregroundColor(.labelSecondary)
                        }
                    }
                    Spacer()
                    
                }
                .frame(height: 352)
                .frame(maxWidth: .infinity)
                .background(Color.backgroundTertiary)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(
                            style: StrokeStyle(lineWidth: 2, dash: [10])
                        )
                        .foregroundColor(selectedImage == nil ? .separatorPrimary : .clear)
                )
                .padding(.horizontal)
                
                Spacer()
                
                Button {
                    
                    if !subscriptionManager.isSubscribed {
                        isPresented = true
                    } else {
                        isLoading = true
                        
                        if let image = selectedImage {
                            
                            
                            guard let imageURL = saveImageToTemporaryDirectory(image: image) else {
                                print("❌ Ошибка: не удалось сохранить изображение")
                                isLoading = false
                                return
                            }
                            
                            // Первый запрос: Генерация видео
                            NetworkManager.shared.generateImage(
                                templateId: item.idMain,
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
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        showAlert = true
                                    }
                                }
                            }
                        }
                    }
                    
                } label: {
                    HStack {
                        
                        Text("Create a masterpiece")
                            .font(.bodyEmphasized)
                            .foregroundColor(.labelPrimary)
                    }
                    .frame(height: 48)
                    .frame(maxWidth: .infinity)
                    .background(selectedImage != nil ? Color.accentPrimary : Color.accentGrey)
                    .cornerRadius(12)
                    .padding(.horizontal)
                    .padding(.top)
                }
                .padding(.bottom, 200)
                .opacity(selectedImage != nil ? 1 : 0.12)
                .disabled(selectedImage == nil)
            }
            .navigationTitle(item.displayTitle)
            .navigationBarTitleDisplayMode(.inline)
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
                    }))
            .sheet(isPresented: $isSheetPresented) {
                PhotoPicker(selectedImage: $selectedImage)
            }
            .onChange(of: selectedImage) { newValue in
                if newValue != nil {
                    isSheetPresented = false
                }
            }
            .fullScreenCover(isPresented: $isLoading) {
                GenerationView()
            }
            .fullScreenCover(isPresented: $navigateToTextGeneratedView) {
                TextGeneratedView(item: $generatedItem)
            }
            .sheet(isPresented: $isPresented) {
                PayWall()
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Video generation error"),
                    message: Text("Something went wrong or the server is not responding. Try again or do it later."),
                    primaryButton: .default(Text("Try Again"), action: {
                        showAlert = false
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            isLoading = true
                            
                        }
                    }),
                    secondaryButton: .cancel()
                )
            }
            
            Spacer()
                .frame(height: 150)
        }
    }
    
    func saveImageToTemporaryDirectory(image: UIImage) -> URL? {
            let tempDirectory = FileManager.default.temporaryDirectory
            let fileURL = tempDirectory.appendingPathComponent("merged_image.jpg")
            
            if let data = image.jpegData(compressionQuality: 0.8) {
                do {
                    try data.write(to: fileURL)
                    print(" сохранения изображения")
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
        
        let newTextGenerations = TextGenerations(context: moc)
        newTextGenerations.id = UUID()
        newTextGenerations.date = Date()
        newTextGenerations.prompt = item.displayTitle
        newTextGenerations.url = nil
        
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

struct MiniTemplateCard<T: PreviewPlayable>: View {
    let item: T
    @State private var player: AVPlayer?
    @State private var isLoading = true
    
    var body: some View {
        ZStack(alignment: .bottom) {
            if isLoading {
                Color.gray.opacity(0.3)
                    .frame(width: 90, height: 130)
                    .cornerRadius(10)
                    .overlay(
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    )
            } else {
                VideoPlayerVieww(player: $player)
                    .frame(width: 90, height: 130)
                    .cornerRadius(10)
            }
            
        }
        .frame(width: 90, height: 130)
        .onAppear {
            setupPlayer()
        }
    }
    
    private func setupPlayer() {
        guard let url = URL(string: item.preview) else {
            print("Invalid URL: \(item.preview)")
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
