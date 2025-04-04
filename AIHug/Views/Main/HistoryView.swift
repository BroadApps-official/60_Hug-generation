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
                            LazyVGrid(columns: columns, spacing: 12) {
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
        .fullScreenCover(isPresented: $navigateToTextGeneratedView) {
            
                TextGeneratedView(item: $selectedItem)
            
        }
    }
    
}

struct HistoryItemCard: View {
    let textGenerationItems: TextGenerations
    @State private var player: AVPlayer?
    @State private var isLoading = true
    
    var body: some View {
        ZStack(alignment: .bottom) {
            if let urlString = textGenerationItems.url, let url = URL(string: urlString) {
                VideoPlayerView(player: $player)
                    .frame(width: 170, height: 250)
                    .cornerRadius(12)
                    .onAppear {
                        setupPlayer(url: url)
                    }
            } else {
                Color.backgroundSecondary
                    .overlay(
                        VStack {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .accentPrimary))
                            Text("Video is\ngenerating")
                                .foregroundColor(.labelPrimary)
                                .font(.calloutRegular)
                                .multilineTextAlignment(.center)
                        }
                    )
                    .frame(width: 170, height: 250)
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
            .frame(height: 44)
            .overlay(
                HStack {
                    Spacer()
                    
                    Text(textGenerationItems.prompt ?? "No prompt")
                        .foregroundColor(.white)
                        .font(.system(size: 12, weight: .semibold))
                        .lineLimit(1)
                    
                    Spacer()
                }
            )
        }
        .frame(width: 170, height: 250)
        .cornerRadius(12)
    }
    
    private func setupPlayer(url: URL) {
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
}
