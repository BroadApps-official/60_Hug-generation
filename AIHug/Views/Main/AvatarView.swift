import SwiftUI

struct AvatarView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @State private var selectedImage: UIImage?
    @State private var isSheetPresented = false
    @State private var avatarPaywallIsPresented = false
    
    
    var body: some View {
        
        ZStack {
            Color.backgroundPrimary
                .edgesIgnoringSafeArea(.all)
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack {
                    
                    Text("New avatar")
                        .font(.headlineRegular)
                        .foregroundColor(.labelSecondary)
                        .frame(height: 80)
                        .frame(maxWidth: .infinity)
                        .background(Color.backgroundTertiary)
                        .cornerRadius(12)
                        .padding()
                    
                    HStack {
                        Text("Photos")
                            .font(.title3Emphasized)
                            .foregroundColor(.labelPrimary)
                        
                        Spacer()
                        
                        Text("0 out of 50")
                            .font(.bodyRegular)
                            .foregroundColor(.labelSecondary)
                    }
                    .padding(.horizontal)
                    
                    HStack {
                        Text("Add 15 to 50 photos")
                            .font(.caption1Regular)
                            .foregroundColor(.labelTertiary)
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    HStack {
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
                                            .frame(width: 100, height: 100)
                                            .padding(0)
                                            .cornerRadius(12)
                                            .clipped()
                                        
                                        VStack {
                                            HStack {
                                                Spacer()
                                                
                                                Image(systemName: "xmark")
                                                    .foregroundColor(.labelPrimary)
                                                    .font(.caption1Regular)
                                                
                                                    .frame(width: 32, height: 32)
                                                    .background(Color.backgroundQuaternary)
                                                    .cornerRadius(8)
                                                
                                            }
                                            Spacer()
                                        }
                                    }
                                } else {
                                    Image(systemName: "plus")
                                        .font(.bodyRegular)
                                        .foregroundColor(.accentSecondary)
                                        .padding(.bottom, 10)
                                    
                                    Text("Add photo")
                                        .font(.footnoteEmphasized)
                                        .foregroundColor(.accentSecondary)
                                }
                            }
                            Spacer()
                            
                        }
                        .frame(width: 100, height: 100)
                        .background(Color.backgroundTertiary)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(
                                    style: StrokeStyle(lineWidth: 2, dash: [10])
                                )
                                .foregroundColor(selectedImage == nil ? .accentSecondary : .clear)
                        )
                        .padding(.horizontal)
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 132)
                    .background(Color.backgroundTertiary)
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    
                    
                    Spacer()
                    
                    Button {
                        
                        
                    } label: {
                        HStack {
                            
                            Text("Create (1 credit)")
                                .font(.bodyEmphasized)
                                .foregroundColor(.labelPrimary)
                        }
                        .frame(height: 48)
                        .frame(maxWidth: .infinity)
                        .background(selectedImage != nil ? Color.accentPrimary : Color.accentGrey)
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 200)
                    .opacity(selectedImage != nil ? 1 : 0.12)
                    .disabled(selectedImage == nil)
                    
                    
                    
                    
                    
                    
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
                .sheet(isPresented: $isSheetPresented) {
                    PhotoPicker(selectedImage: $selectedImage)
                }
                .onChange(of: selectedImage) { newValue in
                    if newValue != nil {
                        isSheetPresented = false
                    }
                }
                
                Spacer()
                    .frame(height: 150)
            }
            
            
                
                LinearGradient(
                    gradient: Gradient(colors: [.backgroundPrimary, .backgroundPrimary.opacity(0.5)]),
                    startPoint: .bottom,
                    endPoint: .top
                )
                
                VStack(spacing: 6) {
                    

                    Text("You've run out of available avatars")
                        .font(.title3Emphasized)
                        .foregroundColor(.labelPrimary)
                    
                    Text("Add new avatars")
                        .font(.footnoteRegular)
                        .foregroundColor(.labelSecondary)
                    
                    Button {
                        avatarPaywallIsPresented = true
                    } label: {
                        Text("Add avatars")
                            .foregroundColor(.labelPrimary)
                            .font(.bodyEmphasized)
                            .frame(width: 280, height: 48)
                            .background(Color.accentPrimary)
                            .cornerRadius(12)
                    }
                    .padding(.top)
                    
                }
                

        }
        .fullScreenCover(isPresented: $avatarPaywallIsPresented) {
            AvatarPayWall()
        }
    }
}
