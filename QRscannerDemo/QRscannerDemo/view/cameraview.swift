//
//  cameraview.swift
//  QRscannerDemo
//
//  Created by Manoj Amsavel on 9/7/23.
//

import SwiftUI
import AVKit
/// Camera View Using AVCapture Video PreviewLayer
struct CameraView: UIViewRepresentable {
var frameSize: CGSize
/// Camera Session
@Binding var session: AVCaptureSession
func makeUIView (context: Context) -> UIView {
/// Defining Camera Frame Size
let view = UIViewType (frame: CGRect (origin: .zero, size: frameSize))
view.backgroundColor = .clear
let cameraLayer = AVCaptureVideoPreviewLayer (session: session)
cameraLayer.frame = .init(origin: .zero, size: frameSize)
cameraLayer.videoGravity = .resizeAspectFill
cameraLayer.masksToBounds = true
view.layer.addSublayer(cameraLayer)
return view
}
func updateUIView(_ uiView: UIViewType, context: Context) {
}
}
