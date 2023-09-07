//
//  Scanner.swift
//  QRscannerDemo
//
//  Created by Manoj Amsavel on 9/7/23.
//

import SwiftUI
import AVKit

struct ScannerView: View {
    @State private var isScanning: Bool = false
    @State private var session: AVCaptureSession = .init()
    @State private var qrOutput: AVCaptureMetadataOutput = .init()
    @State private var errorMessage: String = ""
    @State private var showError: Bool = false
    @State private var cameraPermission: Permission = .idle
    @StateObject private var qrDelegate = QRScannerDelegate()
    @State private var scannedCode: String = ""
    @Environment (\.openURL) private var openURL
    var body: some View {
        VStack(spacing: 8){
            Button{
                
                
            }label: {
                Image(systemName: "qrcode.viewfinder").font(.title3)
                    .foregroundColor(Color(.blue))
                
            }
            .frame(maxWidth: .infinity,alignment: .leading)
            Text("Please the QR code inside the area")
                .font(.title3)
                .foregroundColor(.black.opacity(0.8))
                .padding(.top,20)
            Text("Scanning will start automatically")
                .font(.title3)
                .foregroundColor(.gray)
            Spacer(minLength: 15)
            
            
            GeometryReader{
                let size = $0.size
                ZStack{
                    CameraView (frameSize: CGSize (width: size.width, height: size.width), session: $session)
                    ForEach(0...4, id: \.self) { index in
                        let rotation = Double (index) * 90
                        RoundedRectangle (cornerRadius: 2, style: .circular)
                        /// Trimming to get Scanner like Edges
                            .trim(from: 0.61, to: 0.64)
                            .stroke (Color("Blue"), style: StrokeStyle(lineWidth: 5, lineCap:
                                    .round, lineJoin: .round))
                            .rotationEffect (.init(degrees: rotation))
                    }
                }
                .frame(width: size.width, height: size.width)
                .overlay(alignment: .top, content: {
                    Rectangle()
                        .fill(Color("Blue"))
                        .frame(height: 2.5)
                        .shadow(color: Color.black.opacity (0.8), radius: 8, x: 0, y: isScanning ? 15:
                                    -15)
                    
                        .offset(y: isScanning ? size.width : 0)
                })
                .frame(maxWidth: .infinity, maxHeight:.infinity)
            }
            .padding(.horizontal,45)
            Spacer(minLength: 15)
            Button{
                if !session.isRunning && cameraPermission == .approved {
                    reactivateCamera()
                    activateScannerAnimation ()
                }
                
            }label: {
                Image(systemName: "qrcode.viewfinder")
                    .font(.title3)
                    .foregroundColor(.gray)
            }
            Spacer(minLength: 45)
        }
        .padding(15)
        .onAppear(perform: checkCameraPermission)
        .alert(errorMessage, isPresented: $showError) {
            if cameraPermission == .denied {
                Button("Settings") {
                    let settingsString = UIApplication.openSettingsURLString
                    if let settingsURL = URL (string: settingsString) {
                        /// Opening App's Setting, Using openURL SwiftUI API
                        openURL(settingsURL)
                    }
                }
                /// along with cancel button
                Button("Cancel", role:  .cancel){
                }
            }
        }
        
        .onChange (of: qrDelegate.scannedCode) { newValue in
            if let code = newValue {
                scannedCode = code
                /// When the first code scan is available, immediately stop the camera.
                session.stopRunning ( )
                ///Stopping Scanner Animation
                deActivateScannerAnimation()
                ///Clearing the data on delegate
                qrDelegate.scannedCode = nil
            }
        }
    }
    func reactivateCamera() {
        
        DispatchQueue.global (qos: .background).async {
            session.startRunning()
        }
    }
    func activateScannerAnimation () {
        /// Adding Delay for Each Reversal
        withAnimation(.easeInOut(duration: 0.85).delay(0.1).repeatForever (autoreverses: true)) {
            isScanning = true
        }
    }
    func deActivateScannerAnimation () {
        /// Adding Delay for Each Reversal
        withAnimation(.easeInOut(duration: 0.85)){
            isScanning = true
        }
    }
    func checkCameraPermission () {
        Task {
            switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .authorized:
                cameraPermission = .approved
                if session.inputs.isEmpty{
                    /// New Setup
                    setupCamera()
                }else{
                    /// Already Existing One
                    session.startRunning ()
                }
            case .notDetermined:
                /// Requesting Camera Access
                if await AVCaptureDevice.requestAccess (for: .video) {
                    /// Permission Granted
                    cameraPermission = .approved
                    setupCamera()
                } else {
                    /// Permission Denied
                    cameraPermission = .denied
                    presentError( "Please Provide Access to Camera for scanning codes")
                }
            case .denied, .restricted:
                cameraPermission = .denied
                presentError( "Please Provide Access to Camera for scanning codes")
            default: break
            }
        }
    }
    func presentError(_ message: String) {
        errorMessage = message
        showError.toggle()
    }
    func setupCamera(){
        do {
            /// Finding Back Camera
            guard let device = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .back).devices.first else {
                presentError( "UNKNOWN DEVICE ERROR")
                return
            }
            /// Camera Input
            let input = try AVCaptureDeviceInput (device: device)
            /// For Extra Saftey
            /// Checking Whether input & output can be added to the session
            guard session.canAddInput (input), session.canAddOutput (qrOutput) else {
                presentError("UNKNOWN INPUT/OUTPUT ERROR")
                return
            }
            
            /// Adding Input & ouptut to Camera Session
            session.beginConfiguration()
            session.addInput(input)
            session.addOutput (qrOutput)
            /// Setting Ouput config to read QR Codes
            qrOutput.metadataObjectTypes = [.qr]
            /// Adding Delegate to Retreive the Fetched QR Code From Camera
            qrOutput.setMetadataObjectsDelegate(qrDelegate, queue: .main)
            session.commitConfiguration ()
//            /// Note Session must be started on Background thread
            DispatchQueue.global (qos: .background).async {
                session.startRunning()
            }
           activateScannerAnimation()
        } catch {
            presentError(error.localizedDescription)
        }
    }
}
           


struct ScannerView_Previews: PreviewProvider {
    static var previews: some View {
        ScannerView()
    }
}
