import SwiftUI
import AVKit

struct AIEffectsView: View {
    
    @StateObject private var viewModel = TemplatesViewModel()
    @StateObject private var viewModelHailuo = FiltersViewModel()
    
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    
    @State private var isPresented = false
    @State private var isLoading: Bool = false
    @State private var scrollOffset: CGFloat = 0
    @State private var selectedSegment = 1
    @State private var selectedTemplateID: Int? = nil
    @State private var selectedImage: UIImage? = nil
    @State private var isSheetPresented = false
    @State private var selectedButton: String? = nil
    @State private var selectedCategoryTitleEn: String? = nil
    @State private var navigateToTextGeneratedView = false
    @State private var videoURL: String?
    @State private var showAlert = false
    
    var body: some View {
        
        NavigationView {
            ZStack {
                Color.backgroundPrimary
                    .edgesIgnoringSafeArea(.all)
                
                /*
                 HStack {
                 Button {
                 selectedSegment = 0
                 } label: {
                 Spacer()
                 Text("Photo")
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
                 Text("Video")
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
                 */
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        ForEach(viewModel.groupedTemplates.keys.sorted(), id: \.self) { category in
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Text(category)
                                        .font(.title3Emphasized)
                                        .foregroundColor(.labelPrimary)
                                    
                                    Spacer()
                                    
                                    NavigationLink(destination: AITemplatesDetailView(title: category, items: viewModel.groupedTemplates[category] ?? [])) {
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
                                        NavigationLink(destination: AddPhotoView(item: template)) {
                                            VideoCardView(item: template)
                                        }
                                    }
                                }
                                .padding(.horizontal, 16)
                                .frame(height: 250)
                                
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text("Hailuo effects")
                                    .font(.title3Emphasized)
                                    .foregroundColor(.labelPrimary)
                                
                                Spacer()
                                
                                NavigationLink(destination: AITemplatesDetailView(title: "Hailuo effects", items: viewModelHailuo.filters)) {
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
                                ForEach(viewModelHailuo.filters.prefix(2)) { filter in
                                    NavigationLink(destination: AddPhotoView(item: filter)) {
                                        VideoCardView(item: filter)
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
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
                .navigationBarBackButtonHidden(true)
                .navigationTitle(
                    Text("AI effects")
                )
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
                                .sheet(isPresented: $isPresented) {
                                    PayWall()
                                }
                            }
                        }
                )
            }
        }
        .fullScreenCover(isPresented: $isLoading) {
            GenerationView()
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
        selectedImage != nil && selectedTemplateID != nil
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
                        //self.navigateToTextGeneratedView = true
                        
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
                VideoPlayerVieww(player: $player)
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
        //.gesture(
        //    LongPressGesture(minimumDuration: 0.2)
        //        .updating($isPressing) { currentState, gestureState, _ in
        //            gestureState = currentState
        //        }
        //        .onEnded { _ in
        //            player?.play()
        //        }
        //)
        .onChange(of: isPressing) { pressing in
            if !pressing {
                player?.pause()
                player?.seek(to: .zero)
            }
        }
    }
    
    private func setupPlayer() {
        guard let url = URL(string: item.preview) else { return }
        
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

struct VideoPlayerVieww: UIViewControllerRepresentable {
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
