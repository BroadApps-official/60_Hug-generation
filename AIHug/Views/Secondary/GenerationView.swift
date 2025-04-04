import SwiftUI
import Lottie

struct GenerationView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.backgroundPrimary
                    
                VStack(spacing: 0) {
                    
                    Text("Video Generation...")
                        .font(.title3Emphasized)
                        .foregroundColor(.labelPrimary)
                        .padding(.bottom, 5)
                    
                    Text("Generation usually takes about a minute")
                        .font(.footnoteRegular)
                        .foregroundColor(.labelSecondary)
                    
                    LottieView(animation: .named("GenerationLoaderAnimation.json"))
                        .playbackMode(.playing(.toProgress(1, loopMode: .loop)))
                        .frame(width: 265, height: 265)
                        .padding(.vertical)
                    
                    CustomProgressView(duration: 100)
                    
                }
                
            }
            .edgesIgnoringSafeArea(.all)
            .navigationBarItems(
                
                trailing:
                    
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(Color.accentPrimary)
                    }
 
            )
        }
    }
}

struct CustomProgressView: View {
    @State private var progress: CGFloat = 0
    let duration: Double

    var body: some View {
        VStack {
            ZStack(alignment: .leading) {

                RoundedRectangle(cornerRadius: 3)
                    .frame(width: 160, height: 6)
                    .foregroundColor(Color.backgroundQuaternary)

                RoundedRectangle(cornerRadius: 3)
                    .frame(width: progress * 160, height: 6)
                    .foregroundColor(.accentPrimary)
                    .animation(.linear(duration: duration), value: progress)
            }
            .onAppear {
                progress = 1
            }
        }
    }
}
