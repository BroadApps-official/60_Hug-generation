import SwiftUI

struct GenderSelectionView: View {
    
    @EnvironmentObject var sessionViewModel: UserSessionViewModel
    @State private var selectedSegment: Int?
    var onFinish: () -> Void
    
    var body: some View {
        ZStack {
            Color.backgroundPrimary
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                
                Text("Choose a gender for your future avatar")
                    .font(.largeTitleEmphasized)
                    .foregroundColor(.labelPrimary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .padding(.bottom, 5)
                
                Text("It can be changed in the application settings")
                    .font(.bodyRegular)
                    .foregroundColor(.labelTertiary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                
                HStack {
                    
                    Button {
                        selectedSegment = 0
                    } label: {
                        VStack{

                            Image("wAvatar")
                                .resizable()
                                .frame(width: 100, height: 100)
                            
                            Text("Women")
                                .foregroundColor(.labelPrimary)
                                .font(.title2Emphasized)

                        }
                        .frame(height: 176)
                        .frame(maxWidth: .infinity)
                        .background(selectedSegment == 0 ? Color.accentPrimary : Color.backgroundSecondary)
                        .cornerRadius(20)
                    }
                    
                    Button {
                        selectedSegment = 1
                    } label: {
                        VStack{

                            Image("mAvatar")
                                .resizable()
                                .frame(width: 100, height: 100)
                            
                            Text("Men")
                                .foregroundColor(.labelPrimary)
                                .font(.title2Emphasized)

                        }
                        .frame(height: 176)
                        .frame(maxWidth: .infinity)
                        .background(selectedSegment == 1 ? Color.accentPrimary : Color.backgroundSecondary)
                        .cornerRadius(20)
                    }
                    
                }
                .padding(.horizontal)
                .padding(.top, 10)
                
                Spacer()
                    .frame(height: 100)
                
            }
            
            VStack {
                Spacer()
                
                Button {
                    UserDefaults.standard.set(selectedSegment, forKey: "selectedGender")
                    sessionViewModel.refreshUserData()
                    onFinish()
                } label: {
                    HStack {
                        Text("Save")
                            .font(.bodyEmphasized)
                            .foregroundColor(.labelPrimary)
                    }
                    .frame(height: 48)
                    .frame(maxWidth: .infinity)
                    .background(selectedSegment == nil ? Color.accentGrey : Color.accentPrimary)
                    .cornerRadius(12)
                    .padding()
                }
                .opacity(selectedSegment == nil ? 0.12 : 1)
                .disabled(selectedSegment == nil)
            }
            
        }
                    
    }
}
