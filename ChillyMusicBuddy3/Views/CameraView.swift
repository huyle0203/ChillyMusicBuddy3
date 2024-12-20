import SwiftUI
import PhotosUI

struct CameraView: View {
    @State private var selectedImage: UIImage?
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var isShowingCamera = false
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Listen Thru Your Moment 👂")
                .font(.system(size: 18))
                .foregroundColor(.white)
            
            if let image = selectedImage {
                // Display selected/captured image
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 200, height: 200)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color(hex: "00C0F9"), Color(hex: "DC00FE")]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                    )
            } else {
                // Camera button
                Button(action: {
                    isShowingCamera = true
                }) {
                    ZStack {
                        Circle()
                            .fill(Color(hex: "1F2937"))
                            .frame(width: 200, height: 200)
                            .overlay(
                                Circle()
                                    .stroke(
                                        LinearGradient(
                                            gradient: Gradient(colors: [Color(hex: "00C0F9"), Color(hex: "DC00FE")]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 2
                                    )
                            )
                        
                        Image(systemName: "camera.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.white)
                    }
                }
            }
            
            HStack {
                VStack { Divider().background(Color.gray).frame(width: 50)}
                Text("Or")
                    .foregroundColor(.gray)
                    .padding(.horizontal, 8)
                VStack { Divider().background(Color.gray).frame(width: 50)}
            }
            .padding(.vertical, 8)

            
            
            // Image upload button
            PhotosPicker(selection: $selectedItems,
                         maxSelectionCount: 1,
                         matching: .images) {
                Text("Upload your image")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 200, height: 40)
                    .background(Color.black)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color(hex: "00C0F9"), Color(hex: "DC00FE")]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                    )
                    .cornerRadius(12)
            }
            .onChange(of: selectedItems) { oldValue, newValue in
                guard let item = newValue.first else { return }
                Task {
                    if let data = try? await item.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        selectedImage = image
                    }
                }
            }
            
            // Submit button
            Button(action: {
                // Handle submit action
            }) {
                Text("Submit")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 120, height: 40)
                    .background(
                        Group {
                            if selectedImage != nil {
                                LinearGradient(
                                    gradient: Gradient(colors: [Color(hex: "00C0F9"), Color(hex: "DC00FE")]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            } else {
                                Color.black
                            }
                        }
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color(hex: "00C0F9"), Color(hex: "DC00FE")]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ),
                                lineWidth: 2
                            )
                    )
                    .cornerRadius(12)
            }
            .disabled(selectedImage == nil)
            
            Spacer()
        }
        .padding()
        .sheet(isPresented: $isShowingCamera) {
            CustomCameraView(selectedImage: $selectedImage)
                .edgesIgnoringSafeArea(.all)
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) private var presentationMode
    var sourceType: UIImagePickerController.SourceType

    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

struct CameraView_Previews: PreviewProvider {
    static var previews: some View {
        CameraView()
            .preferredColorScheme(.dark)
    }
}

