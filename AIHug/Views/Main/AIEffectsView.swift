import SwiftUI
import AVKit

struct AIEffectsView: View {
    
    @StateObject private var viewModel = TemplatesViewModel()
    
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
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack {
                        
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
                        
                        
                        ScrollView(.vertical, showsIndicators: false) {
                            VStack(alignment: .leading, spacing: 20) {
                                ForEach(viewModel.groupedTemplates.keys.sorted(), id: \.self) { category in
                                    VStack(alignment: .leading, spacing: 10) {
                                        HStack {
                                            Text(category)
                                                .font(.title3Emphasized)
                                                .foregroundColor(.labelPrimary)
                                            
                                            Spacer()
                                            
                                            
                                            NavigationLink(destination: AIEffectsDetailView(category: category, templates: viewModel.groupedTemplates[category] ?? [])) {
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
                                        
                                        ScrollView(.horizontal, showsIndicators: false) {
                                            LazyHStack(spacing: 10) {
                                                ForEach(viewModel.groupedTemplates[category] ?? []) { template in
                                                    NavigationLink(destination: AddPhotoView(template: template)) {
                                                            TemplateCardd(
                                                                template: template
                                                            )
                                                        }
                                                }
                                            }
                                            .padding(.horizontal, 16)
                                        }
                                        .frame(height: 250)
                                    }
                                }
                            }
                        }
                        .padding(.top)
                        .onAppear {
                            viewModel.fetchTemplates()
                        }
                        
                        Spacer()
                            .frame(height: 150)
                        
                    }
                    .background(GeometryReader { geometry in
                        Color.clear.onAppear {
                            self.scrollOffset = geometry.frame(in: .global).minY
                        }
                        .onChange(of: geometry.frame(in: .global).minY) { value in
                            self.scrollOffset = value
                        }
                    })
                    .navigationBarBackButtonHidden(true)
                    .navigationTitle(
                        Text("AI effects")
                    )
                    .navigationBarTitleDisplayMode(scrollOffset < -100 ? .inline : .large)
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
        }
        .fullScreenCover(isPresented: $isLoading) {
            GenerationView()
        }
        .fullScreenCover(isPresented: $navigateToTextGeneratedView) {
            //TextGeneratedView(videoURL: $videoURL, promptText: $promptText)
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

import SwiftUI
import AVKit

struct TemplateCardd: View {
    let template: Template
    @State private var player: AVPlayer?
    @State private var isLoading = true
    
    var body: some View {
        ZStack(alignment: .bottom) {
            if isLoading {
                Color.gray.opacity(0.3)
                    .frame(width: 170, height: 250)
                    .cornerRadius(12)
                    .overlay(
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    )
            } else {
                VideoPlayerVieww(player: $player)
                    .frame(width: 170, height: 250)
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
            
        }
        .frame(width: 170, height: 250)
        .onAppear {
            setupPlayer()
        }
    }
    
    
    private func setupPlayer() {
        guard let url = URL(string: template.preview) else { return }

        VideoCacheManager.shared.cacheVideo(url: url) { cachedURL in
            guard let cachedURL = cachedURL else { return }

            DispatchQueue.main.async {
                let newPlayer = AVPlayer(url: cachedURL)
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
                isLoading = false
                player?.play()
            }
        }
    }

    //private func setupPlayer() {
    //    guard let url = URL(string: template.preview) else {
    //        print("Invalid URL: \(template.preview)")
    //        return
    //    }
    //
    //    print("Loading video from: \(url)")
    //
    //    let newPlayer = AVPlayer(url: url)
    //    newPlayer.isMuted = true
    //    newPlayer.actionAtItemEnd = .none
    //
    //    NotificationCenter.default.addObserver(
    //        forName: .AVPlayerItemDidPlayToEndTime,
    //        object: newPlayer.currentItem,
    //        queue: .main
    //    ) { _ in
    //        newPlayer.seek(to: .zero)
    //        newPlayer.play()
    //    }
    //
    //    player = newPlayer
    //
    //    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
    //        isLoading = false
    //        player?.play()
    //    }
    //}
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
