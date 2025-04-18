import SwiftUI

struct AITemplatesDetailView<T: Identifiable & PreviewPlayable>: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    let title: String
    let items: [T]
    
    private let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(items) { item in
                    NavigationLink(destination: AddPhotoView(item: item)) {
                        VideoCardView(item: item)
                    }
                }
            }
            .padding()
            
            Spacer().frame(height: 150)
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
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
                }))
    }
}
