import SwiftUI
import AVKit

struct HistoryView: View {
    
    @FetchRequest(sortDescriptors: []) var textGenerationItems: FetchedResults<TextGenerations>
    @Environment(\.managedObjectContext) var moc
    
    @State private var isPresented = false
    @State private var selectedSegment = 0
    @State private var navigateToTextGeneratedView = false
    
    @Binding var selectedTabIndex: Int
    
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    
    var videoItems: [TextGenerations] {
        textGenerationItems.filter { $0.type == "video" }
    }

    var photoItems: [TextGenerations] {
        textGenerationItems.filter { $0.type != "video" }
    }
    
    @State private var selectedItem: TextGenerations?
    @State private var selectedItemType: String?
    
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
                        
                        HStack {
                            Button {
                                selectedSegment = 0
                            } label: {
                                Spacer()
                                Image(systemName: "sparkles")
                                    .foregroundColor(selectedSegment == 0 ? Color.labelPrimary : Color.labelTertiary)
                                    .font(.system(size: 14))
                                Text("Video")
                                    .foregroundColor(selectedSegment == 0 ? Color.labelPrimary : Color.labelTertiary)
                                    .font(.footnoteEmphasized)
                                Spacer()
                            }
                            .frame(height: 40)
                            .background(selectedSegment == 0 ? Color.accentPrimaryAlpha : Color.backgroundTertiary)
                            .cornerRadius(20)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(selectedSegment == 0 ? Color.accentPrimary : Color.clear, lineWidth: 2)
                            )
                            .padding(.horizontal, 2)
                            
                            Button {
                                selectedSegment = 1
                            } label: {
                                Spacer()
                                Image(systemName: "photo.tv")
                                    .foregroundColor(selectedSegment == 1 ? Color.labelPrimary : Color.labelTertiary)
                                    .font(.system(size: 14))
                                Text("Photo")
                                    .foregroundColor(selectedSegment == 1 ? Color.labelPrimary : Color.labelTertiary)
                                    .font(.footnoteEmphasized)
                                Spacer()
                            }
                            .frame(height: 40)
                            .background(selectedSegment == 1 ? Color.accentPrimaryAlpha : Color.backgroundTertiary)
                            .cornerRadius(20)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(selectedSegment == 1 ? Color.accentPrimary : Color.clear, lineWidth: 2)
                            )
                            .padding(.horizontal, 2)
                            
                        }
                        .padding(.horizontal)
                        .padding(.top, 10)
                        
                        if (selectedSegment == 0 && videoItems.isEmpty) || (selectedSegment == 1 && photoItems.isEmpty) {
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
                                    
                                    Button {
                                        if selectedSegment == 0 {
                                            selectedTabIndex = 0
                                        } else {
                                            selectedTabIndex = 1
                                        }
                                    } label: {
                                        Text("Create")
                                            .foregroundColor(.labelPrimary)
                                            .font(.bodyEmphasized)
                                            .frame(width: 280, height: 48)
                                            .background(Color.accentPrimary)
                                            .cornerRadius(12)
                                    }
                                    .padding(.top)
                                    
                                }
                                
                            }
                            .padding(.top)
                        } else {

                            ScrollView {
                                LazyVGrid(columns: columns, spacing: 20) {
                                    ForEach(selectedSegment == 0 ? videoItems : photoItems, id: \.id) { item in
                                        HistoryItemCard(textGenerationItems: item)
                                            .onTapGesture {
                                                selectedItem = item
                                                selectedItemType = item.type ?? "video"
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
                            HStack {
                                if !subscriptionManager.isSubscribed {
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
                                    .fullScreenCover(isPresented: $isPresented) {
                                        PayWall()
                                    }
                                }
                            }
                        
                    )
                }
            }
        }
        .fullScreenCover(isPresented: $navigateToTextGeneratedView) {
            TextGeneratedView(item: $selectedItem, type: selectedItemType)
        }
    }
    
}
