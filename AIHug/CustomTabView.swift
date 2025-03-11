import SwiftUI

struct CustomTabView: View {
    
    @State private var selectedIndex = 0
    
    var body: some View {
        ZStack {
            
            ZStack {
                switch selectedIndex {
                case 0:
                    MainGenerationView()
                case 1:
                    HistoryView()
                case 2:
                    SettingsView()
                default:
                    Text("First tab")
                }
            }
            
            VStack {
                Spacer()
                    
                HStack(spacing: 0) {

                    Spacer()
                        .frame(width: 10)
                    
                    TabBarItem(iconName: "sparkles", title: "Generation", isSelected: selectedIndex == 0)
                        .onTapGesture {
                            selectedIndex = 0
                        }

                    TabBarItem(iconName: "rectangle.stack.badge.play.fill", title: "History", isSelected: selectedIndex == 1)
                        .onTapGesture {
                            selectedIndex = 1
                        }

                    TabBarItem(iconName: "gearshape.fill", title: "Settings", isSelected: selectedIndex == 2)
                        .onTapGesture {
                            selectedIndex = 2
                        }

                    Spacer()
                        .frame(width: 10)
                }
                .frame(height: 80)
                .background(BlurView(style: .systemUltraThinMaterial))
                .cornerRadius(20)
                .padding(.horizontal)
            }
            
        }
    }
}

#Preview {
    CustomTabView()
}

struct TabBarItem: View {
    let iconName: String
    let title: String
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            Image(systemName: iconName)
                .font(.bodyRegular)
                .frame(width: 32, height: 32, alignment: .center)
                .foregroundColor(isSelected ? Color.labelPrimary : Color.labelQuaternary)

            Text(title)
                .font(.caption2Emphasized)
                .foregroundColor(isSelected ? Color.labelPrimary : Color.labelQuaternary)
                .padding(.bottom, 5)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 60)
        .background(isSelected ? Color.backgroundQuaternary : Color.clear)
        .cornerRadius(12)
    }
}

struct BlurView: UIViewRepresentable {
    let style: UIBlurEffect.Style

    func makeUIView(context: Context) -> UIVisualEffectView {
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: style))
        return blurView
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        
    }
}

