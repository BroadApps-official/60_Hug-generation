import SwiftUI

struct HistoryView: View {
    
    @FetchRequest(sortDescriptors: []) var generationItems: FetchedResults<Generations>

    @Environment(\.managedObjectContext) var moc
    
    @State private var isPresented = false
    @State private var selectedSegment = 0
    
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
                            Text("Text to Video")
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
                            Text("Image to Video")
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
    }
    
}

#Preview {
    HistoryView()
}
