//
//  QRScannerRepository.swift
//  CreateQR
//
//  Created by 김미진 on 11/11/24.
//

import Foundation
import AVFoundation

protocol QRScannerRepository {
    func requestCameraPermission(completion: @escaping (Bool) -> Void)
    func startScanning(previewLayer: AVCaptureVideoPreviewLayer, completion: @escaping (String) -> Void)
    func stopScanning()
}

class QRScannerRepositoryImpl: NSObject, QRScannerRepository, AVCaptureMetadataOutputObjectsDelegate {
    private let cameraPermissionDataSource: CameraPermissionDataSource
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var captureSession: AVCaptureSession?
    private var completion: ((String) -> Void)?

    init(cameraPermissionDataSource: CameraPermissionDataSource) {
        self.cameraPermissionDataSource = cameraPermissionDataSource
    }
    // 카메라 권한 요청
    func requestCameraPermission(completion: @escaping (Bool) -> Void) {
        cameraPermissionDataSource.requestPermissionCamera(completion: completion)
    }

    func startScanning(previewLayer: AVCaptureVideoPreviewLayer, completion: @escaping (String) -> Void) {
        self.completion = completion
        self.previewLayer = previewLayer
        setupCaptureSession()
    }
    
    private func setupCaptureSession() {
        captureSession = AVCaptureSession()
        previewLayer?.session = captureSession

        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput

        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }

        if (captureSession?.canAddInput(videoInput) == true) {
            captureSession?.addInput(videoInput)
        } else {
            return
        }

        let metadataOutput = AVCaptureMetadataOutput()

        if (captureSession?.canAddOutput(metadataOutput) == true) {
            captureSession?.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            return
        }
        
        DispatchQueue.global(qos: .background).async {
            self.captureSession?.startRunning()
        }
    }

    func stopScanning() {
        captureSession?.stopRunning()  // 스캔 세션 중단
        captureSession = nil           // 메모리에서 해제
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard let metadataObject = metadataObjects.first,
              let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
              let scannedValue = readableObject.stringValue else { return }

        completion?(scannedValue)  // 스캔 결과 전달
//        stopScanning()
    }
}
