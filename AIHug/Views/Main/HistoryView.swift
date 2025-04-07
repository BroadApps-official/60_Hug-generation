import SwiftUI
import AVKit

struct HistoryView: View {
    
    @FetchRequest(sortDescriptors: []) var textGenerationItems: FetchedResults<TextGenerations>
    @Environment(\.managedObjectContext) var moc
    
    @State private var isPresented = false
    @State private var selectedSegment = 1
    @State private var navigateToTextGeneratedView = false
    
    @State private var selectedItem: TextGenerations?
    
    let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    var body: some View {
        
        NavigationView {
            ZStack {
                Color.backgroundPrimary
                    .edgesIgnoringSafeArea(.all)
                ScrollView(.vertical, showsIndicators: false) {
                    VStack {
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
                        if textGenerationItems.isEmpty {
                            ZStack {
                                
                                VStack(spacing: 10) {
                                    HStack(spacing: 10){
                                        RoundedRectangle(cornerRadius: 8)
                                            .foregroundColor(.backgroundTertiary)
                                            .frame(height: 148)
                                        RoundedRectangle(cornerRadius: 8)
                                            .foregroundColor(.backgroundTertiary)
                                            .frame(height: 148)
                                        
                                    }
                                    .padding(.horizontal)
                                    
                                    HStack(spacing: 10){
                                        RoundedRectangle(cornerRadius: 8)
                                            .foregroundColor(.backgroundTertiary)
                                            .frame(height: 148)
                                        RoundedRectangle(cornerRadius: 8)
                                            .foregroundColor(.backgroundTertiary)
                                            .frame(height: 148)
                                        
                                    }
                                    .padding(.horizontal)
                                    
                                }
                                
                                LinearGradient(
                                    gradient: Gradient(colors: [.backgroundPrimary, .clear]),
                                    startPoint: .bottom,
                                    endPoint: .top
                                )
                                .frame(height: 310)
                                
                                VStack(spacing: 6) {
                                    
                                    Spacer()
                                        .frame(height: 160)
                                    
                                    Text("It's empty here")
                                        .font(.title3Emphasized)
                                        .foregroundColor(.labelPrimary)
                                    
                                    Text("Create your first generation")
                                        .font(.footnoteRegular)
                                        .foregroundColor(.labelSecondary)
                                }
                                
                            }
                            .padding(.top)
                        } else {
                            ScrollView {
                                LazyVGrid(columns: columns, spacing: 20) {
                                    ForEach(textGenerationItems, id: \.id) { item in
                                        HistoryItemCard(textGenerationItems: item)
                                            .onTapGesture {
                                                selectedItem = item
                                                navigateToTextGeneratedView = true
                                            }
                                    }
                                }
                                .padding()
                            }
                        }
                        
                        Spacer()
                            .frame(height: 150)
                        
                    }
                    .navigationBarBackButtonHidden(true)
                    .navigationTitle(
                        Text("History")
                    )
                    .navigationBarTitleDisplayMode(.large)
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
        .fullScreenCover(isPresented: $navigateToTextGeneratedView) {
            
            TextGeneratedView(item: $selectedItem)
            
        }
    }
    
}

struct HistoryItemCard: View {
    let textGenerationItems: TextGenerations
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
            .overlay(
                HStack {
                    Spacer()
                    Text(textGenerationItems.prompt ?? "No prompt")
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
            setupPlayer()
        }
        .gesture(
            LongPressGesture(minimumDuration: 0.2)
                .updating($isPressing) { currentState, gestureState, _ in
                    gestureState = currentState
                }
                .onEnded { _ in
                    player?.play()
                }
        )
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
}
