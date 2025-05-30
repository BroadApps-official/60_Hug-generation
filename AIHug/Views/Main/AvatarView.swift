import SwiftUI

struct AvatarView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var sessionViewModel: UserSessionViewModel
    
    @State private var selectedImages: [UIImage] = []
    @State private var avatarPaywallIsPresented = false
    @State private var showActionSheet = false
    @State private var imageSource: UIImagePickerController.SourceType?
    @State private var isImagePickerPresented = false
    @State private var isLoading = false

    @State private var showAlert = false
    @State private var alertType: AlertType?
    
    enum AlertType {
        case successfullyCreated
        case failedDownloading
        case deleteEnsure
    }
    
    var body: some View {
        
        ZStack {
            Color.backgroundPrimary
                .edgesIgnoringSafeArea(.all)
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack {
                    
                    Text("New avatar")
                        .font(.headlineRegular)
                        .foregroundColor(.labelSecondary)
                        .frame(height: 80)
                        .frame(maxWidth: .infinity)
                        .background(Color.backgroundTertiary)
                        .cornerRadius(12)
                        .padding()
                    
                    HStack {
                        Text("Photos")
                            .font(.title3Emphasized)
                            .foregroundColor(.labelPrimary)
                        
                        Spacer()
                        
                        Text("\(selectedImages.count) out of \( sessionViewModel.userData!.stat.maxUploadPhotos)")
                            .font(.bodyRegular)
                            .foregroundColor(.labelSecondary)
                    }
                    .padding(.horizontal)
                    
                    HStack {
                        Text("Add \( sessionViewModel.userData!.stat.minUploadPhotos) to \( sessionViewModel.userData!.stat.maxUploadPhotos) photos")
                            .font(.caption1Regular)
                            .foregroundColor(.labelTertiary)
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    
          
                    // Контейнер с фоном, скруглением и шириной
                    ZStack {
                        Color.backgroundTertiary
                            .cornerRadius(12)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                // Кнопка "+" всегда первая
                                Button {
                                    showActionSheet = true
                                } label: {
                                    VStack(spacing: 0) {
                                        Image(systemName: "plus")
                                            .font(.bodyRegular)
                                            .foregroundColor(.accentSecondary)
                                            .padding(.bottom, 10)

                                        Text("Add photo")
                                            .font(.footnoteEmphasized)
                                            .foregroundColor(.accentSecondary)
                                    }
                                    .frame(width: 100, height: 100)
                                    .background(Color.backgroundTertiary)
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [10]))
                                            .foregroundColor(.accentSecondary)
                                    )
                                }

                                // Выбранные изображения
                                ForEach(Array(selectedImages.enumerated()), id: \.offset) { index, image in
                                    ZStack(alignment: .topTrailing) {
                                        Image(uiImage: image)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 100, height: 100)
                                            .cornerRadius(12)
                                            .clipped()

                                        Button {
                                            selectedImages.remove(at: index)
                                        } label: {
                                            Image(systemName: "xmark")
                                                .font(.caption2)
                                                .foregroundColor(.white)
                                                .frame(width: 20, height: 20)
                                                .background(Color.black.opacity(0.6))
                                                .clipShape(Circle())
                                                .padding(5)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 132)
                    .padding(.horizontal)
                            
                    
                    Button {
                        
                        isLoading = true
                        
                        NetworkManager.shared.generateAvatar(images: selectedImages) { result in
                            switch result {
                            case .success(let generationId):
                                print("✅ ID получен: \(generationId)")
                                
                                checkAvatarGenerationStatusPeriodically(generationId: generationId)

                                
                                
                            case .failure(let error):
                                print("❌ Ошибка генерации: \(error.localizedDescription)")
                                
                                isLoading = false
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    //showAlert = true
                                }
                            }
                        }
                        
                        //DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        //    alertType = .failedDownloading
                        //    showAlert = true
                        //}
                    } label: {
                        Text("Create (1 credit)")
                            .font(.bodyEmphasized)
                            .foregroundColor(.labelPrimary)
                            .frame(height: 48)
                            .frame(maxWidth: .infinity)
                            .background(sessionViewModel.userData!.stat.minUploadPhotos > selectedImages.count ? Color.accentGrey : Color.accentPrimary)
                            .cornerRadius(12)
                            .padding(.horizontal)
                    }
                    .padding(.top)
                    .opacity(sessionViewModel.userData!.stat.minUploadPhotos > selectedImages.count ? 0.12 : 1)
                    .disabled(sessionViewModel.userData!.stat.minUploadPhotos > selectedImages.count)
                    
                    
                    Button {
                        alertType = .deleteEnsure
                        showAlert = true
                    } label: {
                        Text("Clear data")
                            .font(.calloutRegular)
                            .foregroundColor(selectedImages.isEmpty ? Color.labelQuintuple : Color.labelTertiary)
                    }
                    .padding(.top, 10)
                    
                    
                    
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
                .fullScreenCover(isPresented: $isImagePickerPresented) {
                    ImagePickerViewMulti { images in
                        selectedImages.append(contentsOf: images)
                    }
                }

                
                Spacer()
                    .frame(height: 150)
            }

            
            if sessionViewModel.userData!.stat.availableModels <= 0 {
                LinearGradient(
                    gradient: Gradient(colors: [.backgroundPrimary, .backgroundPrimary.opacity(0.5)]),
                    startPoint: .bottom,
                    endPoint: .top
                )
            
                VStack(spacing: 6) {
            
            
                    Text("You've run out of available avatars")
                        .font(.title3Emphasized)
                        .foregroundColor(.labelPrimary)
            
                    Text("Add new avatars")
                        .font(.footnoteRegular)
                        .foregroundColor(.labelSecondary)
            
                    Button {
                        avatarPaywallIsPresented = true
                    } label: {
                        Text("Add avatars")
                            .foregroundColor(.labelPrimary)
                            .font(.bodyEmphasized)
                            .frame(width: 280, height: 48)
                            .background(Color.accentPrimary)
                            .cornerRadius(12)
                    }
                    .padding(.top)
            
                }
            }
            
        }
        .alert(isPresented: $showAlert) {
            switch alertType {
            case .successfullyCreated:
                return Alert(
                    title: Text("Avatar created successfully"),
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
            case .deleteEnsure:
                return Alert(
                    title: Text("Delete the avatar?"),
                    message: Text("You will not be able to restore it after deleting it."),
                    primaryButton: .destructive(Text("Delete"), action: {
                        selectedImages = []
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
        .confirmationDialog("Select action", isPresented: $showActionSheet, titleVisibility: .visible) {
            
            Button("From the gallery") {
                imageSource = .photoLibrary
                isImagePickerPresented = true
            }

            Button("Take a photo") {
                imageSource = .camera
                isImagePickerPresented = true
            }

            Button("Cancel", role: .cancel) { }

        } message: {
            Text("Add a photo so we can do a cool effect with it")
        }

    }
    
    func checkAvatarGenerationStatusPeriodically(generationId: String) {
        var retryCount = 0
        let maxRetries = 100
        let retryInterval: TimeInterval = 5.0

        func checkStatus() {
            if retryCount >= maxRetries {
                print("❌ Превышено количество попыток")
                isLoading = false
                showAlert = true
                return
            }

            NetworkManager.shared.getAvatarGenerationStatus(generationId: generationId) { result in
                switch result {
                case .success(let data):
                    print("✅ Статус: \(data.status)")
                    
                    if data.status.uppercased() == "OK" {
                        print("✅ Аватар готов")
                        DispatchQueue.main.async {
                            isLoading = false
                            sessionViewModel.refreshUserData()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                alertType = .successfullyCreated
                                showAlert = true
                            }
                        }
                    } else {
                        retryCount += 1
                        DispatchQueue.main.asyncAfter(deadline: .now() + retryInterval) {
                            checkStatus()
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
import PhotosUI

struct ImagePickerViewMulti: UIViewControllerRepresentable {
    var onImagesPicked: ([UIImage]) -> Void

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 0 // 0 = без лимита

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
        // ничего не обновляем
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(onImagesPicked: onImagesPicked)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let onImagesPicked: ([UIImage]) -> Void

        init(onImagesPicked: @escaping ([UIImage]) -> Void) {
            self.onImagesPicked = onImagesPicked
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)

            var images: [UIImage] = []
            let group = DispatchGroup()

            for result in results {
                if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                    group.enter()
                    result.itemProvider.loadObject(ofClass: UIImage.self) { object, error in
                        defer { group.leave() }
                        if let image = object as? UIImage {
                            images.append(image)
                        }
                    }
                }
            }

            group.notify(queue: .main) {
                self.onImagesPicked(images)
            }
        }
    }
}

