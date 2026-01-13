//
//  DefaultQRScannerRepository.swift
//  CreateQR
//
//  Clean Architecture - Data Layer Repository Implementation
//

import Foundation
import AVFoundation

final class DefaultQRScannerRepository: NSObject, QRScannerRepository, AVCaptureMetadataOutputObjectsDelegate {

    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var captureSession: AVCaptureSession?
    private var completion: ((String) -> Void)?

    func startScanning(previewLayer: AVCaptureVideoPreviewLayer, completion: @escaping (String) -> Void) {
        stopScanning()
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

        if captureSession?.canAddInput(videoInput) == true {
            captureSession?.addInput(videoInput)
        } else {
            return
        }

        let metadataOutput = AVCaptureMetadataOutput()

        if captureSession?.canAddOutput(metadataOutput) == true {
            captureSession?.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [
                .qr,
                .ean8,
                .ean13,
                .pdf417,
                .code128,
                .code39,
                .code93,
                .upce,
                .aztec,
                .dataMatrix,
                .itf14
            ]
        } else {
            return
        }

        DispatchQueue.global(qos: .background).async {
            self.captureSession?.startRunning()
        }
    }

    func stopScanning() {
        captureSession?.stopRunning()
        captureSession = nil
    }

    func metadataOutput(
        _ output: AVCaptureMetadataOutput,
        didOutput metadataObjects: [AVMetadataObject],
        from connection: AVCaptureConnection
    ) {
        guard let metadataObject = metadataObjects.first,
              let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
              let scannedValue = readableObject.stringValue else { return }

        completion?(scannedValue)
    }
}
