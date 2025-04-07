import SwiftUI

struct AIEffectsDetailView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    let category: String
    let templates: [Template]
    
    let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(templates) { template in
                    
                    NavigationLink(destination: AddPhotoView(template: template)) {
                            TemplateCardd(
                                template: template
                            )
                        }
                }
            }
            .padding()
            
            Spacer()
                .frame(height: 150)
        }
        .navigationTitle(category)
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
