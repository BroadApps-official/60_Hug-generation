import AVKit
import SwiftUI

struct AddPhotoView: View {
    let template: Template
    @State private var selectedImage: UIImage?
    @State private var isSheetPresented = false
    @State private var isLoading = false
    
    var body: some View {
        VStack {
            
            MiniTemplateCard(template: template)

            HStack {
                Text("Upload photo")
                    .font(.title3Emphasized)
                    .foregroundColor(.labelPrimary)
                
                Spacer()
            }
            .padding(.horizontal)
            
            Button {
                isSheetPresented.toggle()
            } label: {
                Spacer()
                VStack(spacing: 0) {
                    
                    if let image = selectedImage {
                        ZStack {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 352, height: 352)
                                .padding(0)
                                .cornerRadius(12)
                                .clipped()
                            
                            VStack {
                                Spacer()
                                HStack {
                                    Spacer()
                                    HStack{
                                        Image(systemName: "arrow.triangle.2.circlepath")
                                            .foregroundColor(.labelPrimary)
                                            .font(.caption1Regular)
                                        Text("Change")
                                            .foregroundColor(.labelPrimary)
                                            .font(.footnoteRegular)
                                    }
                                    .padding(.vertical, 12)
                                    .padding(.horizontal, 8)
                                    .background(Color.backgroundDim)
                                    .cornerRadius(8)
                                    .padding()
                                    
                                }
                            }
                        }
                    } else {
                        Image(systemName: "plus")
                            .font(.largeTitleRegular)
                            .foregroundColor(.labelPrimaryInvariably)
                            .padding(.bottom, 10)
                        
                        Text("Add photo")
                            .font(.calloutRegular)
                            .foregroundColor(.labelSecondary)
                    }
                }
                Spacer()
                
            }
            .frame(width: 352, height: 352)
            .background(Color.backgroundTertiary)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(
                        style: StrokeStyle(lineWidth: 2, dash: [10])
                    )
                    .foregroundColor(selectedImage == nil ? .separatorPrimary : .clear)
            )
            .padding(.horizontal)
            
            Spacer()
            
            Button {
                isLoading = true
                
            } label: {
                HStack {
                    
                    Text("Create a masterpiece")
                        .font(.bodyEmphasized)
                        .foregroundColor(.labelPrimary)
                }
                .frame(height: 48)
                .frame(maxWidth: .infinity)
                .background(Color.accentPrimary)
                .cornerRadius(12)
                .padding(.horizontal)
                .padding(.top)
            }
            .padding(.bottom, 200)
        }
        .navigationTitle(template.effect)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $isSheetPresented) {
            PhotoPicker(selectedImage: $selectedImage)
        }
        .fullScreenCover(isPresented: $isLoading) {
            GenerationView()
        }
    }
    
}

struct MiniTemplateCard: View {
    let template: Template
    @State private var player: AVPlayer?
    @State private var isLoading = true
    
    var body: some View {
        ZStack(alignment: .bottom) {
            if isLoading {
                Color.gray.opacity(0.3)
                    .frame(width: 90, height: 130)
                    .cornerRadius(10)
                    .overlay(
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    )
            } else {
                VideoPlayerVieww(player: $player)
                    .frame(width: 90, height: 130)
                    .cornerRadius(10)
            }
            
        }
        .frame(width: 90, height: 130)
        .onAppear {
            setupPlayer()
        }
    }
    
    private func setupPlayer() {
        guard let url = URL(string: template.preview) else {
            print("Invalid URL: \(template.preview)")
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
}
