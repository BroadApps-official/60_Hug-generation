import SwiftUI
import UIKit

struct PhotoPicker: View {
    
    @Binding var selectedButton: String? // Привязка к выбранной кнопке
    @Binding var selectedImage: UIImage?
    @State private var isImagePickerPresented = false
    @State private var selectedSource: UIImagePickerController.SourceType? = nil  // Добавим переменную для источника
    
    var body: some View {
        
        VStack(spacing: 0) {
            
            Text("Add photo")
                .font(.title3Emphasized)
                .foregroundColor(.labelPrimary)
                .padding(.bottom, 20)
                .padding(.top)
            
            HStack {
                Text("Bad examples")
                    .font(.title3Emphasized)
                    .foregroundColor(.labelPrimary)
                
                
                Spacer()
            }
            .padding(.horizontal)
            .padding(.bottom, 5)
            
            HStack {
                Text("Group photo, covered face, nudity, very large face, blurred face, very small face, hands not visible or covered.")
                    .font(.footnoteRegular)
                    .foregroundColor(.labelSecondary)
                    .padding(.horizontal)
                    .multilineTextAlignment(.leading)
                
                Spacer()
            }
            
            HStack {
                ZStack {
                    Image("badExample1")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 173, height: 173)
                        .clipped()
                        .cornerRadius(16)
                    
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.accentRed)
                                .font(.largeTitleRegular)
                                .frame(width: 64, height: 64)
                        }
                    }
                }
                .frame(width: 173, height: 173)
                
                Spacer()
                
                ZStack {
                    Image("badExample2")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 173, height: 173)
                        .clipped()
                        .cornerRadius(16)
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.accentRed)
                                .font(.largeTitleRegular)
                                .frame(width: 64, height: 64)
                        }
                    }
                }
                .frame(width: 173, height: 173)
            }
            .padding(.horizontal)
            .padding(.top)
            
            HStack {
                Text("Good examples")
                    .font(.title3Emphasized)
                    .foregroundColor(.labelPrimary)
                
                
                Spacer()
            }
            .padding(.horizontal)
            .padding(.bottom, 5)
            .padding(.top)
            
            HStack {
                Text("The photo was taken full-face (the man is standing straight), hands are visible.")
                    .font(.footnoteRegular)
                    .foregroundColor(.labelSecondary)
                    .padding(.horizontal)
                    .multilineTextAlignment(.leading)
                
                Spacer()
            }
            
            HStack {
                ZStack {
                    Image("goodExample1")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 173, height: 173)
                        .clipped()
                        .cornerRadius(16)
                    
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.accentGreen)
                                .font(.largeTitleRegular)
                                .frame(width: 64, height: 64)
                        }
                    }
                }
                .frame(width: 173, height: 173)
                
                Spacer()
                
                ZStack {
                    Image("goodExample2")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 173, height: 173)
                        .clipped()
                        .cornerRadius(16)
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.accentGreen)
                                .font(.largeTitleRegular)
                                .frame(width: 64, height: 64)
                        }
                    }
                }
                .frame(width: 173, height: 173)
            }
            .padding(.horizontal)
            .padding(.top)
            
            HStack {
                
                Button {
                    selectedSource = .camera // Устанавливаем камеру как источник
                    isImagePickerPresented.toggle()
                } label: {
                    Text("Take a photo")
                        .font(.bodyEmphasized)
                        .foregroundColor(.labelPrimary)
                        .padding()
                        .frame(height: 48)
                        .frame(maxWidth: .infinity)
                        .background(Color.accentPrimaryAlpha)
                        .cornerRadius(12)
                }
                
                Button {
                    selectedSource = .photoLibrary // Устанавливаем галерею как источник
                    isImagePickerPresented.toggle()
                } label: {
                    Text("From the gallery")
                        .font(.bodyEmphasized)
                        .foregroundColor(.labelPrimary)
                        .padding()
                        .frame(height: 48)
                        .frame(maxWidth: .infinity)
                        .background(Color.accentPrimary)
                        .cornerRadius(12)
                }
                
            }
            .padding(.horizontal)
            .padding(.top)
            
            Text("Use images where the face and hands are visible\nfor the best result.")
                .font(.caption2Regular)
                .foregroundColor(.labelTertiary)
                .padding(.horizontal)
                .multilineTextAlignment(.center)
                .padding(.top)
            
                .fullScreenCover(isPresented: $isImagePickerPresented) {
                    ImagePickerView(sourceType: selectedSource ?? .photoLibrary, selectedImage: $selectedImage)
                        .edgesIgnoringSafeArea(.all)
                }
            
            Spacer()
        }
        .background(BlurView(style: .systemUltraThinMaterial).opacity(0.5))
        .edgesIgnoringSafeArea(.all)
        
    }
}

struct ImagePickerView: UIViewControllerRepresentable {
    var sourceType: UIImagePickerController.SourceType // Получаем тип источника
    @Binding var selectedImage: UIImage?
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = context.coordinator
        imagePickerController.sourceType = sourceType // Устанавливаем источник
        return imagePickerController
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        // Обновление UI не требуется
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(selectedImage: $selectedImage)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        @Binding var selectedImage: UIImage?
        
        init(selectedImage: Binding<UIImage?>) {
            _selectedImage = selectedImage
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                selectedImage = image
            }
            picker.dismiss(animated: true)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}
