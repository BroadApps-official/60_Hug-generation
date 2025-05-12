import SwiftUI

struct AllTemplatesView<T: Identifiable & PreviewPlayable>: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    let items: [T]
    let type: String
    
    private let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                    NavigationLink(destination: AddPhotoView(items: items, selectedIndex: index, aiModel: "", type: type)) {
                        if type == "video" {
                            VideoCardView(item: item)
                        } else {
                            ImageCardView(item: item)
                        }
                    }
                }

            }
            .padding()
            
            Spacer().frame(height: 150)
        }
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
