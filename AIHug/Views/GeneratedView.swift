import SwiftUI
import AVKit
import Photos

struct GeneratedView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @Binding var selectedCategoryTitleEn: String?
    @Binding var selectedImage1: UIImage?
    @Binding var selectedImage2: UIImage?
    @Binding var videoURL: String?
    
    @State private var player: AVPlayer? = nil
    @State private var isPlaying = true
    @State private var isLoading = true
    
    var body: some View {
        
        NavigationView {
            ZStack {
                Color.backgroundPrimary
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    
                    RoundedRectangle(cornerRadius: 12)
                        .foregroundColor(.backgroundSecondary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 445)
                        .overlay(
                            ZStack {
                                VideoPlayerView(player: $player)
                                    .cornerRadius(12)
                                
                                Button(action: togglePlayPause) {
                                    Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 76, height: 76)
                                        .foregroundColor(.backgroundTertiary)
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .accentPrimary))
                                        .scaleEffect(2)
                                }
                            }
                        )
                        .padding()
                        .onAppear {
                            setupPlayer()
                        }
                    
                    HStack() {
                        VStack(spacing: 0) {
                            if let image = selectedImage1 {
                                ZStack {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 172, height: 148)
                                        .cornerRadius(12)
                                        .clipped()
                                    
                                    RoundedRectangle(cornerRadius: 12)
                                        .frame(width: 172, height: 148)
                                        .foregroundColor(.backgroundDim)
                                    
                                    Text("1 photo")
                                        .foregroundColor(.labelSecondary)
                                        .font(.title3Regular)
                                }
                            } else {
                                Text("Loading...")
                                    .font(.calloutEmphasized)
                                    .foregroundColor(.labelTertiary)
                            }
                        }
                        .frame(width: 172, height: 148)
                        .background(Color.backgroundTertiary)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder()
                                .foregroundColor(.accentPrimary)
                        )
                        
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
                                    
                                    RoundedRectangle(cornerRadius: 12)
                                        .frame(width: 172, height: 148)
                                        .foregroundColor(.backgroundDim)
                                    
                                    Text("2 photo")
                                        .foregroundColor(.labelSecondary)
                                        .font(.title3Regular)
                                }
                            } else {
                                Text("Loading...")
                                    .font(.calloutEmphasized)
                                    .foregroundColor(.labelTertiary)
                            }
                        }
                        .frame(width: 172, height: 148)
                        .background(Color.backgroundTertiary)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder()
                                .foregroundColor(.accentPrimary)
                        )
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    Button {
                        saveVideoToGallery(urlString: videoURL)
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
            .navigationTitle(Text("\(selectedCategoryTitleEn ?? " AI Effect")"))
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
                                    presentationMode.wrappedValue.dismiss()
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            } else {
                                Button(action: {
                                    presentationMode.wrappedValue.dismiss()
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
        
        guard let validURLString = videoURL, let url = URL(string: validURLString) else {
            print("Invalid URL: \(videoURL ?? "")")
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
                } else {
                    print("❌ Save error: \(error?.localizedDescription ?? "Unknown error")")
                    self.requestPhotoLibraryAccess()
                }
            }
        }
    }
    
    private func downloadAndSaveToGallery(remoteURL: URL) {
        let task = URLSession.shared.downloadTask(with: remoteURL) { tempURL, _, error in
            guard let tempURL = tempURL, error == nil else {
                print("❌ Download failed: \(error?.localizedDescription ?? "")")
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
    
}

