import SwiftUI
import AVKit

struct ImageCardView<T: PreviewPlayable>: View {
    let item: T
    
    @State private var image: UIImage?
    @State private var isLoading = true
    
    var body: some View {
        ZStack(alignment: .bottom) {
            if isLoading {
                Color.gray.opacity(0.3)
                    .frame(height: 250)
                    .frame(maxWidth: .infinity)
                    .cornerRadius(12)
                    .overlay(
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    )
            } else {
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 250)
                        .frame(maxWidth: .infinity)
                        .cornerRadius(12)
                        .clipped()
                }
            }
            
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 25/255, green: 25/255, blue: 25/255),
                    Color(red: 21/255, green: 21/255, blue: 21/255, opacity: 0.5),
                    Color(red: 32/255, green: 32/255, blue: 32/255, opacity: 0)
                ]),
                startPoint: .bottom,
                endPoint: .top
            )
            .frame(height: 52)
            .cornerRadius(12)
            
            Text(item.displayTitle)
                .font(.subheadlineEmphasized)
                .foregroundColor(.labelPrimary)
                .padding(.bottom, 10)
                .multilineTextAlignment(.center)
        }
        .frame(height: 250)
        .frame(maxWidth: .infinity)
        .onAppear {
            setupImage()
        }
    }
    
    private func setupImage() {
        guard let url = URL(string: item.previewURL) else { return }
        
        // Загрузка изображения из URL
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil, let loadedImage = UIImage(data: data) else {
                return
            }
            
            DispatchQueue.main.async {
                image = cropToAspectRatio(image: loadedImage, ratio: 3/5)
                isLoading = false
            }
        }.resume()
    }
    
    func cropToAspectRatio(image: UIImage, ratio: CGFloat) -> UIImage {
        let originalWidth = image.size.width
        let originalHeight = image.size.height
        let originalRatio = originalWidth / originalHeight

        var cropRect: CGRect
        if originalRatio > ratio {
            // Обрезаем по ширине
            let newWidth = originalHeight * ratio
            let xOffset = (originalWidth - newWidth) / 2
            cropRect = CGRect(x: xOffset, y: 0, width: newWidth, height: originalHeight)
        } else {
            // Обрезаем по высоте
            let newHeight = originalWidth / ratio
            let yOffset = (originalHeight - newHeight) / 2
            cropRect = CGRect(x: 0, y: yOffset, width: originalWidth, height: newHeight)
        }

        guard let cgImage = image.cgImage?.cropping(to: cropRect) else { return image }
        return UIImage(cgImage: cgImage, scale: image.scale, orientation: image.imageOrientation)
    }

}



struct BigImageCardView<T: PreviewPlayable>: View {
    let item: T
    let index: Int
    @Binding var selectedIndex: Int
    
    @State private var image: UIImage?
    @State private var isLoading = true

    var body: some View {
        RoundedRectangle(cornerRadius: 12)
            .foregroundColor(.backgroundSecondary)
            .frame(maxWidth: .infinity)
            .frame(height: 445)
            .overlay(
                ZStack {
                    if let image = image {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 445)
                            .frame(maxWidth: .infinity)
                            .cornerRadius(12) // Применение скругления к изображению
                            .clipped()
                    } else {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(2)
                            .frame(width: 76, height: 76)
                            .background(BlurView(style: .systemUltraThinMaterial))
                            .cornerRadius(38)
                    }
                }
            )
            .padding()
            .onAppear {
                setupImage()
            }
    }

    private func setupImage() {
        guard let url = URL(string: item.previewURL) else { return }
        
        // Загрузка изображения
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil, let loadedImage = UIImage(data: data) else { return }
            
            DispatchQueue.main.async {
                image = cropToAspectRatio(image: loadedImage, ratio: 3/5)  // Применяем обрезку
                isLoading = false
            }
        }.resume()
    }

    func cropToAspectRatio(image: UIImage, ratio: CGFloat) -> UIImage {
        let originalWidth = image.size.width
        let originalHeight = image.size.height
        let originalRatio = originalWidth / originalHeight

        var cropRect: CGRect
        if originalRatio > ratio {
            // Обрезаем по ширине
            let newWidth = originalHeight * ratio
            let xOffset = (originalWidth - newWidth) / 2
            cropRect = CGRect(x: xOffset, y: 0, width: newWidth, height: originalHeight)
        } else {
            // Обрезаем по высоте
            let newHeight = originalWidth / ratio
            let yOffset = (originalHeight - newHeight) / 2
            cropRect = CGRect(x: 0, y: yOffset, width: originalWidth, height: newHeight)
        }

        guard let cgImage = image.cgImage?.cropping(to: cropRect) else { return image }
        return UIImage(cgImage: cgImage, scale: image.scale, orientation: image.imageOrientation)
    }
}




struct VideoCardView<T: PreviewPlayable>: View {
    let item: T
    
    @State private var player: AVPlayer?
    @State private var isLoading = true
    @GestureState private var isPressing = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            if isLoading {
                Color.gray.opacity(0.3)
                    .frame(height: 250)
                    .frame(maxWidth: .infinity)
                    .cornerRadius(12)
                    .overlay(
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    )
            } else {
                VideoPlayerView(player: $player)
                    .frame(height: 250)
                    .frame(maxWidth: .infinity)
                    .cornerRadius(12)
            }
            
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 25/255, green: 25/255, blue: 25/255),
                    Color(red: 21/255, green: 21/255, blue: 21/255, opacity: 0.5),
                    Color(red: 32/255, green: 32/255, blue: 32/255, opacity: 0)
                ]),
                startPoint: .bottom,
                endPoint: .top
            )
            .frame(height: 52)
            .cornerRadius(12)
            
            Text(item.displayTitle)
                .font(.subheadlineEmphasized)
                .foregroundColor(.labelPrimary)
                .padding(.bottom, 10)
                .multilineTextAlignment(.center)
        }
        .frame(height: 250)
        .frame(maxWidth: .infinity)
        .onAppear {
            setupPlayer()
        }
        .onChange(of: isPressing) { pressing in
            if !pressing {
                player?.pause()
                player?.seek(to: .zero)
            }
        }
    }
    
    private func setupPlayer() {
        guard let url = URL(string: item.previewURL) else { return }
        
        VideoCacheManager.shared.cacheVideo(url: url) { cachedURL in
            guard let cachedURL = cachedURL else { return }
            
            DispatchQueue.main.async {
                let newPlayer = AVPlayer(url: cachedURL)
                newPlayer.isMuted = true
                newPlayer.actionAtItemEnd = .pause
                player = newPlayer
                isLoading = false
            }
        }
    }
}



struct BigVideoCardView<T: PreviewPlayable>: View {
    let item: T
    let index: Int
    @Binding var selectedIndex: Int
    
    @State private var player: AVPlayer?
    @State private var isLoading = true
    @State private var isPlaying = true
    @State private var isControlsVisible = true
    @State private var hideControlsWorkItem: DispatchWorkItem?
    
    var body: some View {
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
            .onChange(of: selectedIndex) { newValue in
                if newValue == index {
                    player?.play()
                    isPlaying = true
                } else {
                    player?.pause()
                    isPlaying = false
                }
            }
    }
    
    private func setupPlayer() {
        guard let url = URL(string: item.previewURL) else { return }

        VideoCacheManager.shared.cacheVideo(url: url) { cachedURL in
            guard let cachedURL = cachedURL else { return }

            DispatchQueue.main.async {
                let newPlayer = AVPlayer(url: cachedURL)
                newPlayer.isMuted = true
                newPlayer.actionAtItemEnd = .pause
                player = newPlayer
                isLoading = false

                NotificationCenter.default.addObserver(
                    forName: .AVPlayerItemDidPlayToEndTime,
                    object: newPlayer.currentItem,
                    queue: .main
                ) { _ in
                    newPlayer.seek(to: .zero)
                    newPlayer.play()
                }

                if selectedIndex == index {
                    newPlayer.play()
                    isPlaying = true
                }
            }
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
}




struct HistoryItemCard: View {
    let textGenerationItems: TextGenerations
    
    @State private var player: AVPlayer?
    @State private var image: UIImage?
    @State private var isLoading = true
    @GestureState private var isPressing = false

    var body: some View {
        ZStack(alignment: .bottom) {
            if isLoading {
                Color.gray.opacity(0.3)
                    .frame(height: 250)
                    .frame(maxWidth: .infinity)
                    .cornerRadius(12)
                    .overlay(
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    )
            } else {
                if textGenerationItems.type == "video" {
                    VideoPlayerView(player: $player)
                        .frame(height: 250)
                        .frame(maxWidth: .infinity)
                        .cornerRadius(12)
                } else {
                    if let image = image {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 250)
                            .frame(maxWidth: .infinity)
                            .cornerRadius(12)
                            .clipped()
                    }
                }
            }

            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 25/255, green: 25/255, blue: 25/255),
                    Color(red: 21/255, green: 21/255, blue: 21/255, opacity: 0.5),
                    Color(red: 32/255, green: 32/255, blue: 32/255, opacity: 0)
                ]),
                startPoint: .bottom,
                endPoint: .top
            )
            .frame(height: 52)
            .cornerRadius(12)
            .overlay(
                HStack {
                    Spacer()
                    Text(textGenerationItems.filter ?? "Prompt")
                        .foregroundColor(.white)
                        .font(.subheadlineEmphasized)
                        .lineLimit(1)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 8)
                    Spacer()
                }
            )
        }
        .frame(height: 250)
        .frame(maxWidth: .infinity)
        .onAppear {
            if textGenerationItems.type == "video" {
                setupPlayer()
            } else {
                setupImage()
            }
        }
        .onChange(of: isPressing) { pressing in
            if !pressing {
                player?.pause()
                player?.seek(to: .zero)
            }
        }
    }

    private func setupPlayer() {
        guard let urlString = textGenerationItems.url,
              let url = URL(string: urlString) else { return }

        VideoCacheManager.shared.cacheVideo(url: url) { cachedURL in
            guard let cachedURL = cachedURL else { return }

            DispatchQueue.main.async {
                let newPlayer = AVPlayer(url: cachedURL)
                newPlayer.isMuted = true
                newPlayer.actionAtItemEnd = .pause
                player = newPlayer
                isLoading = false
            }
        }
    }

    private func setupImage() {
        guard let urlString = textGenerationItems.url,
              let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data,
                  let loadedImage = UIImage(data: data) else { return }

            DispatchQueue.main.async {
                image = cropToAspectRatio(image: loadedImage, ratio: 3/5)
                isLoading = false
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
