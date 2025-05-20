import SwiftUI
import UIKit
import AVKit
import Photos
import UniformTypeIdentifiers
import StoreKit

struct TextGeneratedView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) var moc
    
    @Binding var item: TextGenerations?
    @State var type: String?
    
    @State private var player: AVPlayer? = nil
    @State private var isPlaying = true
    @State private var isLoading = true
    @State private var showAlert = false
    @State private var alertType: AlertType?
    @State private var exportFileURL: URL?
    @State private var showDocumentExporter = false
    @State private var isControlsVisible = true
    @State private var hideControlsWorkItem: DispatchWorkItem?
    @State private var isShareSheetPresented = false
    @State private var shareURL: URL?
    @State private var isPreparingExport = false
    
    @State private var uiImage: UIImage?
    @State private var isLoadingImage = true
    
    
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
                        
                        if item?.prompt == nil {
                            if item?.type == "video" {
                                Spacer()
                                    .frame(height: 100)
                            } else {
                                Spacer()
                                    .frame(height: 50)
                            }
                            
                        }
                        
                        if item?.type == "video" {
                            RoundedRectangle(cornerRadius: 12)
                                .foregroundColor(.backgroundSecondary)
                                .frame(maxWidth: .infinity)
                                .frame(height: 445)
                                .overlay(
                                    ZStack {
                                        VideoPlayerView(player: $player)
                                            .cornerRadius(12)
                                            .contentShape(Rectangle())
                                            .onTapGesture {
                                                showControlsTemporarily()
                                            }
                                        
                                        if isLoading {
                                            ProgressView()
                                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                                .scaleEffect(2)
                                                .frame(width: 76, height: 76)
                                                .background(BlurView(style: .systemUltraThinMaterial))
                                                .cornerRadius(38)
                                        }
                                        
                                        Button(action: togglePlayPause) {
                                            Image(systemName: isPlaying ? "pause" : "play.fill")
                                                .font(.largeTitleRegular)
                                                .frame(width: 76, height: 76)
                                                .background(BlurView(style: .systemUltraThinMaterial))
                                                .cornerRadius(38)
                                                .foregroundColor(.white)
                                        }
                                        .opacity(isLoading ? 0 : (isControlsVisible ? 1 : 0))
                                        .animation(.easeInOut(duration: 0.25), value: isControlsVisible)
                                        .allowsHitTesting(isControlsVisible && !isLoading)
                                    }
                                )
                                .padding()
                                .onAppear {
                                    setupPlayer()
                                }
                        } else {
                            if let urlString = item?.url, let url = URL(string: urlString) {
                                    ZStack {
                                        if let image = uiImage {
                                            Image(uiImage: image)
                                                .resizable()
                                                .scaledToFill()
                                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                                .clipped()
                                                .cornerRadius(12)
                                        } else if isLoadingImage {
                                            ProgressView()
                                                .frame(width: 76, height: 76)
                                                .background(BlurView(style: .systemUltraThinMaterial))
                                                .cornerRadius(38)
                                        } else {
                                            Image(systemName: "xmark.octagon")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 40, height: 40)
                                                .foregroundColor(.red)
                                        }
                                    }
                                    .frame(height: 490)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .padding()
                                    .onAppear {
                                        loadAndCropImage(from: url)
                                    }
                                }

                        }
                        
                        
                        if item?.prompt != nil {
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
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal)
                                .padding(.bottom)
                            
                        
                        }
                        
                        if let data = item?.photoreference, let image = UIImage(data: data) {
                            HStack {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .padding(0)
                                    .cornerRadius(12)
                                    .clipped()
                            }
                            .padding(.horizontal)
                            .frame(maxWidth: .infinity)
                            .frame(height: 132)
                            .background(Color.backgroundTertiary)
                            .cornerRadius(12)
                            .padding(.horizontal)
                        }
                        
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
            .sheet(isPresented: $isShareSheetPresented) {
                if isPreparingExport {
                    VStack(spacing: 12) {
                        ProgressView()
                        Text("File preparation…")
                    }
                    .padding()
                } else if let shareURL = shareURL {
                    ShareSheet(activityItems: [shareURL])
                }
            }
            .sheet(isPresented: $showDocumentExporter) {
                if isPreparingExport {
                    VStack(spacing: 12) {
                        ProgressView()
                        Text("File preparation…")
                    }
                    .padding()
                } else if let exportFileURL = exportFileURL {
                    DocumentExporter(fileURL: exportFileURL)
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
                                if let urlString = item?.url {
                                    prepareVideoForSharing(from: urlString)
                                }
                            }) {
                                Label("Share", systemImage: "arrow.down.to.line")
                            }
                            Button(action: {
                                saveVideoToFiles(urlString: item?.url)
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
    
    private func showRateAlert() {
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
        } else {
            openAppStore()
        }
    }
    
    private func openAppStore() {
        if let url = URL(string: "https://apps.apple.com/us/app/id\(6742832953)?action=write-review") {
            UIApplication.shared.open(url)
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
            showControlsTemporarily()
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
    
    private func showControlsTemporarily() {
        isControlsVisible = true
        
        hideControlsWorkItem?.cancel()
        let workItem = DispatchWorkItem {
            isControlsVisible = false
        }
        
        hideControlsWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: workItem)
    }
    
    func prepareVideoForSharing(from urlString: String) {
        guard let videoURL = URL(string: urlString) else {
            print("❌ Invalid video URL")
            alertType = .failedDownloading
            showAlert = true
            return
        }

        DispatchQueue.main.async {
            self.isPreparingExport = true
            self.isShareSheetPresented = true
        }

        if videoURL.isFileURL {
            DispatchQueue.main.async {
                self.shareURL = videoURL
                self.isPreparingExport = false
            }
        } else {
            let task = URLSession.shared.downloadTask(with: videoURL) { tempURL, _, error in
                guard let tempURL = tempURL, error == nil else {
                    DispatchQueue.main.async {
                        self.alertType = .failedDownloading
                        self.showAlert = true
                        self.isShareSheetPresented = false
                    }
                    return
                }

                let fileName = UUID().uuidString + ".mp4"
                let tempDir = FileManager.default.temporaryDirectory
                let destinationURL = tempDir.appendingPathComponent(fileName)

                do {
                    if FileManager.default.fileExists(atPath: destinationURL.path) {
                        try FileManager.default.removeItem(at: destinationURL)
                    }
                    try FileManager.default.copyItem(at: tempURL, to: destinationURL)

                    DispatchQueue.main.async {
                        self.shareURL = destinationURL
                        self.isPreparingExport = false
                    }
                } catch {
                    DispatchQueue.main.async {
                        print("❌ Copy failed: \(error)")
                        self.alertType = .failedDownloading
                        self.showAlert = true
                        self.isShareSheetPresented = false
                    }
                }
            }

            task.resume()
        }
    }

    
    func saveVideoToFiles(urlString: String?) {
        guard let urlString = urlString, let videoURL = URL(string: urlString) else {
            print("❌ Invalid video URL")
            alertType = .failedDownloading
            showAlert = true
            return
        }
        
        if videoURL.isFileURL {
            copyAndExportToDocuments(from: videoURL)
        } else {
            DispatchQueue.main.async {
                self.isPreparingExport = true
                self.showDocumentExporter = true
            }
            
            let task = URLSession.shared.downloadTask(with: videoURL) { tempURL, _, error in
                guard let tempURL = tempURL, error == nil else {
                    DispatchQueue.main.async {
                        self.alertType = .failedDownloading
                        self.showAlert = true
                        self.showDocumentExporter = false
                    }
                    return
                }
                
                let fileName = UUID().uuidString + ".mp4"
                let fileManager = FileManager.default
                let docsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
                let destinationURL = docsURL.appendingPathComponent(fileName)
                
                do {
                    if fileManager.fileExists(atPath: destinationURL.path) {
                        try fileManager.removeItem(at: destinationURL)
                    }
                    try fileManager.copyItem(at: tempURL, to: destinationURL)
                    
                    DispatchQueue.main.async {
                        self.exportFileURL = destinationURL
                        self.isPreparingExport = false
                    }
                    
                    
                } catch {
                    DispatchQueue.main.async {
                        self.alertType = .failedDownloading
                        self.showAlert = true
                        self.showDocumentExporter = false
                    }
                }
            }
            task.resume()
        }
    }
    
    
    private func copyAndExportToDocuments(from sourceURL: URL) {
        let fileManager = FileManager.default
        let docsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileName = sourceURL.lastPathComponent
        let destinationURL = docsURL.appendingPathComponent(fileName)
        
        do {
            if fileManager.fileExists(atPath: destinationURL.path) {
                try fileManager.removeItem(at: destinationURL)
            }
            try fileManager.copyItem(at: sourceURL, to: destinationURL)
            DispatchQueue.main.async {
                self.exportFileURL = destinationURL
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    self.showDocumentExporter = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        self.showDocumentExporter = true
                    }
                }
            }
            
        } catch {
            print("❌ File copy failed: \(error)")
            alertType = .failedDownloading
            showAlert = true
        }
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
                    showRateAlert()
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
    
    
    func loadAndCropImage(from url: URL) {
        isLoadingImage = true
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                isLoadingImage = false
                guard let data = data,
                      let image = UIImage(data: data) else {
                    print("❌ Ошибка загрузки изображения")
                    return
                }
                let cropped = cropToAspectRatio(image: image, ratio: 3/5)
                self.uiImage = cropped
            }
        }.resume()
    }
    
    private func cropToAspectRatio(image: UIImage, ratio: CGFloat) -> UIImage {
        let originalWidth = image.size.width
        let originalHeight = image.size.height
        let originalRatio = originalWidth / originalHeight

        var cropRect: CGRect
        if originalRatio > ratio {
            let newWidth = originalHeight * ratio
            let xOffset = (originalWidth - newWidth) / 2
            cropRect = CGRect(x: xOffset, y: 0, width: newWidth, height: originalHeight)
        } else {
            let newHeight = originalWidth / ratio
            let yOffset = (originalHeight - newHeight) / 2
            cropRect = CGRect(x: 0, y: yOffset, width: originalWidth, height: newHeight)
        }

        guard let cgImage = image.cgImage?.cropping(to: cropRect) else { return image }
        return UIImage(cgImage: cgImage, scale: image.scale, orientation: image.imageOrientation)
    }

    
    private func deleteItem() {
        moc.delete(item!)
        
        do {
            try moc.save()
            presentationMode.wrappedValue.dismiss()
        } catch {
            print("Error deleting item: \(error.localizedDescription)")
        }
    }
}

struct DocumentExporter: UIViewControllerRepresentable {
    let fileURL: URL
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forExporting: [fileURL])
        picker.allowsMultipleSelection = false
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
}

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: applicationActivities
        )
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
