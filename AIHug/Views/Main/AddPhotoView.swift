import AVKit
import SwiftUI

struct AddPhotoView<T: PreviewPlayable>: View {
    
    @FetchRequest(sortDescriptors: []) var textGeneretionItems: FetchedResults<TextGenerations>
    @Environment(\.managedObjectContext) var moc
    @State private var generatedItem: TextGenerations?
    
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    
    let items: [T]
    @State private var selectedIndex: Int
    @State private var aiModel: String
    @State private var type: String
    @State private var selectedImage: UIImage?
    @State private var isSheetPresented = false
    @State private var isLoading = false
    @State private var navigateToTextGeneratedView = false
    @State private var generatedURL: String?
    @State private var showAlert = false
    @State private var isPresented = false

    init(items: [T], selectedIndex: Int, aiModel: String, type: String) {
        self.items = items
        self._selectedIndex = State(initialValue: selectedIndex)
        self.aiModel = aiModel
        self.type = type
    }

    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack {
                
                 GeometryReader { geo in
                     ScrollViewReader { proxy in
                         ScrollView(.horizontal, showsIndicators: false) {
                             HStack(spacing: -24) {
                                 ForEach(items.indices, id: \.self) { index in
                                     if type == "video" {
                                         BigVideoCardView(
                                             item: items[index],
                                             index: index,
                                             selectedIndex: $selectedIndex
                                         )
                                         .frame(width: geo.size.width, height: 445)
                                         .animation(.easeInOut, value: selectedIndex)
                                         .id(index)
                                         .onTapGesture {
                                             withAnimation {
                                                 selectedIndex = index
                                                 proxy.scrollTo(index, anchor: .center)
                                             }
                                         }
                                     } else {
                                         BigImageCardView(
                                            item: items[index],
                                            index: index,
                                            selectedIndex: $selectedIndex
                                         )
                                         .frame(width: geo.size.width, height: 445)
                                         .animation(.easeInOut, value: selectedIndex)
                                         .id(index)
                                         .onTapGesture {
                                             withAnimation {
                                                 selectedIndex = index
                                                 proxy.scrollTo(index, anchor: .center)
                                             }
                                         }

                                     }
                                     
                                 }
                             }
                             .gesture(
                                 DragGesture()
                                     .onEnded { value in
                                         let threshold: CGFloat = 50
                                         if value.translation.width < -threshold, selectedIndex < items.count - 1 {
                                             selectedIndex += 1
                                         } else if value.translation.width > threshold, selectedIndex > 0 {
                                             selectedIndex -= 1
                                         }
                                         withAnimation {
                                             proxy.scrollTo(selectedIndex, anchor: .center)
                                         }
                                     }
                             )
                         }
                         .onAppear {
                                     DispatchQueue.main.async {
                                         proxy.scrollTo(selectedIndex, anchor: .center)
                                     }
                                 }
                     }
                 }
                 .frame(height: 445)

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
                .padding(.horizontal)
                .frame(maxWidth: .infinity)
                .frame(height: 132)
                .background(Color.backgroundTertiary)
                .cornerRadius(12)
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
                            
                            let currentItem = items[selectedIndex]
                            
                            if aiModel == "scenario" {
                                NetworkManager.shared.sendPostRequest(scenarioID: "15", image: selectedImage!)
                            } else if aiModel == "photoEffects" {
                                NetworkManager.shared.photoEffectsGenerate(photoEffectID: "\(currentItem.idMain)", image: selectedImage!) { result in
                                    switch result {
                                    case .success(let jobId):
                                        print("✅ Job ID получен: \(jobId)")
                                        
                                        checkGenerationStatusPeriodicallyFotobudka(jobId: "\(jobId)")

                                        
                                    case .failure(let error):
                                        print("❌ Ошибка генерации: \(error.localizedDescription)")
                                        
                                        isLoading = false
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                            showAlert = true
                                        }
                                    }
                                }
                                
                            } else {
                                NetworkManager.shared.generateImage(
                                    templateId: currentItem.idMain,
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
                    }
                    
                } label: {
                    HStack {
                        
                        Text("Create (1 credit)")
                            .font(.bodyEmphasized)
                            .foregroundColor(.labelPrimary)
                    }
                    .frame(height: 48)
                    .frame(maxWidth: .infinity)
                    .background(selectedImage != nil ? Color.accentPrimary : Color.accentGrey)
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
                .padding(.bottom, 200)
                .opacity(selectedImage != nil ? 1 : 0.12)
                .disabled(selectedImage == nil)
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
                TextGeneratedView(item: $generatedItem, type: type)
                
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
        
        let currentItem = items[selectedIndex]
        
        let newTextGenerations = TextGenerations(context: moc)
        newTextGenerations.id = UUID()
        newTextGenerations.date = Date()
        newTextGenerations.filter = currentItem.displayTitle
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
                        self.generatedURL = videoURL
                        
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
    
    
    func checkGenerationStatusPeriodicallyFotobudka(jobId: String) {
        var retryCount = 0
        let maxRetries = 30
        let retryInterval: TimeInterval = 5.0

        let currentItem = items[selectedIndex]

        let newTextGenerations = TextGenerations(context: moc)
        newTextGenerations.id = UUID()
        newTextGenerations.date = Date()
        newTextGenerations.filter = currentItem.displayTitle
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


