import SwiftUI

struct AIEffectsDetailView: View {
    let category: String
    let templates: [Template]
    
    let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(templates) { template in
                    
                    NavigationLink(destination: AddPhotoView(template: template)) {
                            TemplateCardd(
                                template: template
                            )
                        }
                }
            }
            .padding()
        }
        .navigationTitle(category)
        .navigationBarTitleDisplayMode(.inline)
    }
}
