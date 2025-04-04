import SwiftUI
import AVKit
import Photos

struct TextGeneratedView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) var moc
    
    @Binding var item: TextGenerations?
    
    @State private var player: AVPlayer? = nil
    @State private var isPlaying = true
    @State private var isLoading = true
    @State private var showAlert = false
    @State private var alertType: AlertType?
    
    enum AlertType {
        case successDownloading
        case failedDownloading
        case deleteEnsure
    }
    
    var body: some View {
        NavigationView{
            ZStack {
                Color.backgroundPrimary
                    .edgesIgnoringSafeArea(.all)
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 0) {
                        
                        RoundedRectangle(cornerRadius: 12)
                            .foregroundColor(.backgroundSecondary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 445)
                            .overlay(
                                ZStack {
                                    VideoPlayerView(player: $player)
                                        .cornerRadius(12)
                                    
                                    
                                    
                                    if isLoading {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            .scaleEffect(2)
                                            .frame(width: 76, height: 76)
                                            .background(BlurView(style: .systemUltraThinMaterial))
                                            .cornerRadius(38)
                                    } else {
                                        Button(action: togglePlayPause) {
                                            Image(systemName: isPlaying ? "pause" : "play.fill")
                                                .font(.largeTitleRegular)
                                                .frame(width: 76, height: 76)
                                                .background(BlurView(style: .systemUltraThinMaterial))
                                                .cornerRadius(38)
                                                .foregroundColor(.white)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                            )
                            .padding()
                            .onAppear {
                                setupPlayer()
                            }
                        
                        HStack {
                            Text("Prompt")
                                .font(.title3Emphasized)
                                .foregroundColor(.labelPrimary)
                            
                            Spacer()
                            
                            Button(action: {
                                UIPasteboard.general.string = item?.prompt
                            }) {
                                Text("Copy")
                                    .font(.footnoteRegular)
                                    .foregroundColor(.labelSecondary)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 10)
                        
                        Text(item?.prompt ?? "")
                            .foregroundColor(.labelPrimary)
                            .font(.bodyRegular)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.backgroundTertiary)
                            .cornerRadius(14)
                            .padding(.horizontal)
                        
                        HStack {
                            Text("Style")
                                .font(.title3Emphasized)
                                .foregroundColor(.labelPrimary)
                            
                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.top)
                        .padding(.bottom, 10)
                        
                        HStack(spacing: 16) {
                            Image(item?.styleImageName ?? "")
                                .resizable()
                                .scaledToFill()
                                .clipShape(Circle())
                                .frame(width: 56, height: 56)
                            
                            Text(item?.styleName ?? "")
                                .font(.bodyRegular)
                                .foregroundColor(.labelPrimary)
                            
                            Spacer()
                        }
                        .padding(.horizontal)
                        
                        Spacer()
                            .frame(height: 150)
                        
                    }
                }
                
                VStack {
                    Spacer()
                    
                    Button {
                        saveVideoToGallery(urlString: item?.url)
                    } label: {
                        HStack {
                            Text("Save")
                                .font(.bodyEmphasized)
                                .foregroundColor(.labelPrimary)
                        }
                        .frame(height: 48)
                        .frame(maxWidth: .infinity)
                        .background(Color.accentPrimary)
                        .cornerRadius(12)
                        .padding()
                    }
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
                        title: Text("Error, video not saved to gallery"),
                        message: Text("Something went wrong or the server is not responding. Try again or do it later."),
                        primaryButton: .default(Text("Try Again"), action: {
                            showAlert = false
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                saveVideoToGallery(urlString: item?.url)
                            }
                        }),
                        secondaryButton: .cancel()
                    )
                case .deleteEnsure:
                    return Alert(
                        title: Text("Delete this video?"),
                        message: Text("It will disappear from the list on the History tab. You will not be able to restore it after deleting it."),
                        primaryButton: .destructive(Text("Delete"), action: {
                            deleteItem()
                        }),
                        secondaryButton: .cancel()
                    )
                case .none:
                    return Alert(title: Text("Ошибка"))
                }
            }
            .navigationTitle(Text("Result"))
            .navigationBarTitleDisplayMode(.inline)
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
                    
                    Menu {
                        
                        Section {
                            Button(action: {
                                
                            }) {
                                Label("Share", systemImage: "arrow.down.to.line")
                            }
                            Button(action: {
                                
                            }) {
                                Label("Save to files", systemImage: "folder.badge.plus")
                            }
                        }
                        
                        
                        Section {
                            
                            if #available(iOS 15.0, *) {
                                Button(role: .destructive) {
                                    alertType = .deleteEnsure
                                    showAlert = true
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            } else {
                                Button(action: {
                                    alertType = .deleteEnsure
                                    showAlert = true
                                }) {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                            
                            
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.accentPrimary)
                    }
            )
        }
    }
    
    private func setupPlayer() {
        
        guard let validURLString = item?.url, let url = URL(string: validURLString) else {
            print("Invalid URL: \(item?.url ?? "")")
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
    
    private func togglePlayPause() {
        guard let player = player else { return }
        
        if isPlaying {
            player.pause()
        } else {
            player.play()
        }
        
        isPlaying.toggle()
    }
    
    
    func saveVideoToGallery(urlString: String?) {
        guard let urlString = urlString, let url = URL(string: urlString) else {
            print("❌ Invalid video URL")
            alertType = .failedDownloading
            showAlert = true
            return
        }
        
        guard url.isFileURL else {
            print("❌ Remote URLs require download first")
            downloadAndSaveToGallery(remoteURL: url)
            
            return
        }
        
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
        }) { success, error in
            DispatchQueue.main.async {
                if success {
                    print("✅ Video saved to gallery")
                    alertType = .successDownloading
                    showAlert = true
                } else {
                    print("❌ Save error: \(error?.localizedDescription ?? "Unknown error")")
                    alertType = .failedDownloading
                    showAlert = true
                    self.requestPhotoLibraryAccess()
                }
            }
        }
    }
    
    private func downloadAndSaveToGallery(remoteURL: URL) {
        let task = URLSession.shared.downloadTask(with: remoteURL) { tempURL, _, error in
            guard let tempURL = tempURL, error == nil else {
                print("❌ Download failed: \(error?.localizedDescription ?? "")")
                alertType = .failedDownloading
                showAlert = true
                return
            }
            
            let fileManager = FileManager.default
            let docsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let permanentURL = docsURL.appendingPathComponent(remoteURL.lastPathComponent)
            
            do {
                if fileManager.fileExists(atPath: permanentURL.path) {
                    try fileManager.removeItem(at: permanentURL)
                }
                try fileManager.copyItem(at: tempURL, to: permanentURL)
                
                self.saveVideoToGallery(urlString: permanentURL.absoluteString)
            } catch {
                print("❌ File move error: \(error)")
                alertType = .failedDownloading
                showAlert = true
            }
        }
        task.resume()
    }
    
    private func requestPhotoLibraryAccess() {
        PHPhotoLibrary.requestAuthorization { status in
            if status == .denied {
                DispatchQueue.main.async {
                    if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(settingsURL)
                    }
                }
            }
        }
    }
    
    private func deleteItem() {
        moc.delete(item!)
        
        do {
            try moc.save()
            presentationMode.wrappedValue.dismiss()
        } catch {
            print("Error deleting item: \(error.localizedDescription)")
            // Добавьте обработку ошибки при необходимости
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
