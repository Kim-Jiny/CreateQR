//
//  ScanQRTabViewController.swift
//  CreateQR
//
//  Created by 김미진 on 11/11/24.
//

import Foundation
import UIKit
import AVFoundation

class ScanQRTabViewController: UIViewController, StoryboardInstantiable, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    var viewModel: MainViewModel?
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var photoBtn: UIButton!
    
    private var previewLayer: AVCaptureVideoPreviewLayer?
//    let qrView: QRScanView = QRScanView()
    lazy var dismissBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(systemName: "xmark"), for: .normal)
        return btn
    }()
    
    // 카메라 미리보기 뷰
    private let cameraPreviewView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        setupBindings()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("ScanQRTabViewController viewDidAppear")
        setupView()
        setupCameraView()
        viewModel?.checkCameraPermission()
    }
    
    private func setupView() {
        bottomView.backgroundColor = .speedMain3
        bottomView.roundTopCorners(cornerRadius: 30)
        
        photoBtn.setTitle(NSLocalizedString("Scan from Gallery", comment: ""), for: .normal)
        photoBtn.layer.cornerRadius = 10
        photoBtn.layer.borderWidth = 2.0
        photoBtn.layer.borderColor = UIColor.speedMain2.cgColor
    }
    
    private func setupCameraView() {
        cameraView.addSubview(cameraPreviewView)
        cameraPreviewView.snp.makeConstraints {
            $0.top.bottom.leading.trailing.equalToSuperview()
        }
        
        
        previewLayer = AVCaptureVideoPreviewLayer(session: AVCaptureSession())
        previewLayer?.frame = self.view.layer.bounds
        previewLayer?.videoGravity = .resizeAspectFill
        cameraPreviewView.layer.addSublayer(previewLayer!)
        
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("ScanQRTabViewController viewDidDisappear")
        previewLayer?.removeFromSuperlayer()
        self.previewLayer = nil
        viewModel?.stopScanning()  // 뷰가 사라질 때 스캔 중단
    }
    
    private func setupBindings() {
        // 카메라 권한 상태 확인 후 시작
        viewModel?.cameraPermission.observe(on: self) { [weak self] hasPermission in
            guard let hasPermission = hasPermission else { return }
            guard hasPermission else {
                DispatchQueue.main.async {
                    self?.showPermissionAlert()
                }
                return
            }
            if let previewLayer = self?.previewLayer {
                self?.viewModel?.startScanning(previewLayer: previewLayer)
            }
        }
        
        // QR 스캔 결과에 따라 처리
        viewModel?.scannedResult.observe(on: self) { [weak self] result in
            print("값 도착: \(result)")
            //TODO: - url로 연결해줄 수 있는 버튼 화면에 추가 
            if result != "" {
                self?.viewModel?.stopScanning()
                self?.qrDataAlert(result)
            }else {
                if let previewLayer = self?.previewLayer {
                    self?.viewModel?.startScanning(previewLayer: previewLayer)
                }
            }
        }
    }
    
    // 권한 요청 알림
    private func showPermissionAlert() {
        let alert = UIAlertController(title: NSLocalizedString("Camera Permission Required", comment:"Camera Permission Required"),
                                      message: NSLocalizedString("Please allow camera access to scan the QR code.", comment:"Please allow camera access to scan the QR code."),
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment:"Cancel"), style: .cancel))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Go to Settings", comment:"Go to Settings"), style: .default, handler: { [weak self] _ in
            self?.viewModel?.openAppSettings()
        }))
        present(alert, animated: true)
    }
    
    @IBAction func selectImageFromAlbum(_ sender: UIButton) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    // 이미지가 선택되었을 때 호출되는 델리게이트 메서드
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        if let selectedImage = info[.originalImage] as? UIImage {
            scanQRCode(from: selectedImage)
        }
    }

    // QR 코드 스캔 함수
    func scanQRCode(from image: UIImage) {
        guard let ciImage = CIImage(image: image) else { return }
        
        let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])
        let features = detector?.features(in: ciImage) as? [CIQRCodeFeature]
        
        if let qrCode = features?.first?.messageString {
            // QR 코드 스캔 성공, QR 코드 내용을 처리합니다.
            print("QR 코드 내용: \(qrCode)")
            qrDataAlert(qrCode)
        } else {
            print("QR 코드가 없습니다.")
            let alert = UIAlertController(title: NSLocalizedString("No QR code found", comment:"No QR code found"), message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment:"OK"), style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
    
    func qrDataAlert(_ qrCode: String) {
        //QR 스캔했을 때 저장, 사파리 오픈을 선택 할 수 있음.
        let alert = UIAlertController(title: NSLocalizedString("View QR Content", comment:"View QR Content"), message: qrCode, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment:"OK"), style: .default, handler: { _ in
            self.viewModel?.scannedResult.value = ""
        }))
        
        if let url = URL(string: qrCode), UIApplication.shared.canOpenURL(url) {
            alert.addAction(UIAlertAction(title: NSLocalizedString("Open in Safari", comment:"Open in Safari"), style: .default, handler: { _ in
                self.viewModel?.scannedResult.value = ""
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }))
        }
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Save", comment:"Save"), style: .default, handler: { _ in
            let qrImg = self.viewModel?.generateQR(from: qrCode, color: .black, backgroundColor: .white, logo: nil, logoStyle: .square)
            let item = QRItem(title: NSLocalizedString("Untitled", comment:"Untitled"), qrImageData: qrImg?.pngData(), qrType: .other, qrData: qrCode, qrColor: UIColor.black.toHex() ?? "000000FF", backColor: UIColor.white.toHex() ?? "FFFFFFFF", logo: nil, logoStyle: .square)
            self.viewModel?.addMyQR(item)
            self.viewModel?.scannedResult.value = ""
        }))
        
        present(alert, animated: true, completion: nil)
    }
}
