import SwiftUI
import AVKit
import Photos

struct TextGeneratedView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @Binding var videoURL: String?
    @Binding var promptText: String
    
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
                    
                    HStack {
                        Text("Prompt")
                            .font(.title2Emphasized)
                            .foregroundColor(.labelPrimary)
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                    
                    VStack {
                        ScrollView {
                            HStack {
                                Text(promptText)
                                    .foregroundColor(.labelQuaternary)
                                    .font(.bodyRegular)
                                    .padding(8)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Spacer()
                            }
                            .padding(.horizontal, 10)
                        }
                        .frame(height: 100)

                        Spacer()
                    }
                    .frame(height: 120)
                    .background(RoundedRectangle(cornerRadius: 14)
                        .fill(Color.backgroundTertiary))
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
