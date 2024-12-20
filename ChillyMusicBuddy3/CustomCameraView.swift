import SwiftUI
import AVFoundation
import PhotosUI

struct CustomCameraView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var cameraController = CameraController()
    @Binding var selectedImage: UIImage?
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var isFlashOn = false
    @State private var currentZoom: CGFloat = 1.0
    @State private var capturedImage: UIImage?
    @State private var showingReviewScreen = false

    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)

            if showingReviewScreen, let image = capturedImage {
                // Review captured photo
                VStack {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .padding()

                    HStack(spacing: 60) {
                        Button(action: {
                            showingReviewScreen = false
                            capturedImage = nil
                        }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                                .frame(width: 60, height: 60)
                                .background(Color.black.opacity(0.5))
                                .clipShape(Circle())
                        }

                        Button(action: {
                            selectedImage = image
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Image(systemName: "checkmark")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                                .frame(width: 60, height: 60)
                                .background(Color(hex: "FFD700"))
                                .clipShape(Circle())
                        }
                    }
                    .padding(.bottom, 30)
                }
            } else {
                // Camera preview with a square aspect ratio
                GeometryReader { geometry in
                    // We'll make the camera preview a square by constraining its aspect ratio
                    CameraPreviewView(previewLayer: cameraController.previewLayer)
                        .aspectRatio(1, contentMode: .fit)
                        .frame(width: geometry.size.width)
                        .clipped()
                        .padding(.top, (geometry.size.height - geometry.size.width)/2) // Center in vertical space if desired
                }

                // Controls overlay
                VStack {
                    // Top controls
                    HStack {
                        Button(action: {
                            isFlashOn.toggle()
                            cameraController.toggleFlash(isOn: isFlashOn)
                        }) {
                            Image(systemName: isFlashOn ? "bolt.fill" : "bolt.slash.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.white)
                                .frame(width: 44, height: 44)
                                .background(Color.black.opacity(0.25))
                                .clipShape(Circle())
                        }

                        Spacer()

                        Text("\(String(format: "%.1fx", currentZoom))")
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.black.opacity(0.25))
                            .cornerRadius(20)
                    }
                    .padding()

                    Spacer()

                    // Bottom controls
                    HStack(spacing: 60) {
                        // Gallery button
                        PhotosPicker(selection: $selectedItems,
                                     maxSelectionCount: 1,
                                     matching: .images) {
                            Image(systemName: "photo.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                                .frame(width: 44, height: 44)
                        }
                        .onChange(of: selectedItems) { oldValue, newValue in
                            guard let item = newValue.first else { return }
                            Task {
                                if let data = try? await item.loadTransferable(type: Data.self),
                                   let image = UIImage(data: data) {
                                    selectedImage = image
                                    presentationMode.wrappedValue.dismiss()
                                }
                            }
                        }

                        // Capture button
                        Button(action: {
                            cameraController.capturePhoto { image in
                                if let image = image {
                                    let squareImage = cropToSquare(image: image)
                                    capturedImage = squareImage
                                    showingReviewScreen = true
                                }
                            }
                        }) {
                            ZStack {
                                Circle()
                                    .strokeBorder(Color(hex: "FFD700"), lineWidth: 3)
                                    .frame(width: 74, height: 74)

                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 66, height: 66)
                            }
                        }

                        // Camera flip button
                        Button(action: {
                            cameraController.flipCamera()
                        }) {
                            Image(systemName: "arrow.triangle.2.circlepath.camera")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                                .frame(width: 44, height: 44)
                        }
                    }
                    .padding(.bottom, 30)
                }
            }
        }
        .onAppear {
            cameraController.checkPermissionsAndSetup()
        }
    }

    private func cropToSquare(image: UIImage) -> UIImage {
        let originalWidth = image.size.width
        let originalHeight = image.size.height
        let side = min(originalWidth, originalHeight)

        let x = (originalWidth - side) / 2.0
        let y = (originalHeight - side) / 2.0

        let cropRect = CGRect(x: x, y: y, width: side, height: side)
        if let cgImage = image.cgImage?.cropping(to: cropRect) {
            return UIImage(cgImage: cgImage, scale: image.scale, orientation: image.imageOrientation)
        }
        return image
    }
}

class CameraController: NSObject, ObservableObject {
    @Published var session = AVCaptureSession()
    let previewLayer = AVCaptureVideoPreviewLayer()
    private var photoOutput = AVCapturePhotoOutput()
    private var position: AVCaptureDevice.Position = .back
    private var completionHandler: ((UIImage?) -> Void)?

    override init() {
        super.init()
        previewLayer.session = session
        previewLayer.videoGravity = .resizeAspectFill
    }

    func checkPermissionsAndSetup() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupCamera()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                if granted {
                    DispatchQueue.main.async {
                        self?.setupCamera()
                    }
                }
            }
        default:
            break
        }
    }

    private func setupCamera() {
        session.beginConfiguration()

        // Remove existing inputs/outputs
        session.inputs.forEach { session.removeInput($0) }
        session.outputs.forEach { session.removeOutput($0) }

        do {
            guard let device = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                       for: .video,
                                                       position: position) else { return }

            let input = try AVCaptureDeviceInput(device: device)

            if session.canAddInput(input) {
                session.addInput(input)
            }

            if session.canAddOutput(photoOutput) {
                session.addOutput(photoOutput)
            }

            session.commitConfiguration()

            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.session.startRunning()
            }
        } catch {
            print("Error setting up camera: \(error.localizedDescription)")
            session.commitConfiguration()
        }
    }

    func toggleFlash(isOn: Bool) {
        guard let device = AVCaptureDevice.default(for: .video),
              device.hasTorch else { return }

        do {
            try device.lockForConfiguration()
            device.torchMode = isOn ? .on : .off
            device.unlockForConfiguration()
        } catch {
            print("Error toggling flash: \(error.localizedDescription)")
        }
    }

    func setZoom(_ factor: CGFloat) {
        guard let device = AVCaptureDevice.default(for: .video) else { return }
        do {
            try device.lockForConfiguration()
            device.videoZoomFactor = factor
            device.unlockForConfiguration()
        } catch {
            print("Error setting zoom: \(error.localizedDescription)")
        }
    }

    func flipCamera() {
        position = position == .back ? .front : .back

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.session.stopRunning()
            DispatchQueue.main.async {
                self?.setupCamera()
            }
        }
    }

    func capturePhoto(completion: @escaping (UIImage?) -> Void) {
        completionHandler = completion
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
}

extension CameraController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photo: AVCapturePhoto,
                     error: Error?) {
        guard let data = photo.fileDataRepresentation(),
              let image = UIImage(data: data) else {
            completionHandler?(nil)
            return
        }
        completionHandler?(image)
    }
}

struct CameraPreviewView: UIViewRepresentable {
    let previewLayer: AVCaptureVideoPreviewLayer

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        view.layer.addSublayer(previewLayer)
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        previewLayer.frame = uiView.bounds
    }
}


