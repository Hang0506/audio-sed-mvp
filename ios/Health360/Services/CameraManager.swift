import SwiftUI
// import AVFoundation  // Phase 2: uncomment for real camera

class CameraManager: ObservableObject {
    @Published var capturedImage: UIImage?
    @Published var isCapturing = false
    @Published var hasPermission = false

    // MARK: - Phase 2: Real AVCaptureSession
    // private let session = AVCaptureSession()
    // private var photoOutput = AVCapturePhotoOutput()
    //
    // func setupSession() {
    //     session.beginConfiguration()
    //     guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
    //           let input = try? AVCaptureDeviceInput(device: device) else { return }
    //     session.addInput(input)
    //     session.addOutput(photoOutput)
    //     session.commitConfiguration()
    // }

    func requestPermission() {
        // MVP: auto-grant
        hasPermission = true
        // Phase 2:
        // AVCaptureDevice.requestAccess(for: .video) { granted in
        //     DispatchQueue.main.async { self.hasPermission = granted }
        // }
    }

    func capturePhoto() {
        guard !isCapturing else { return }
        isCapturing = true

        // MVP: simulate 1s capture delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.capturedImage = nil // Mock: no real image
            self?.isCapturing = false
        }
    }
}
