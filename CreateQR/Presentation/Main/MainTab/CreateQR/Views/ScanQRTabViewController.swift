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
        }
    }
    
    // 권한 요청 알림
    private func showPermissionAlert() {
        let alert = UIAlertController(title: "카메라 권한이 필요합니다.",
                                      message: "QR을 스캔하기 위해 카메라 권한을 허용해 주세요.",
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "설정으로 이동", style: .default, handler: { [weak self] _ in
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
            // 알림 또는 화면에 표시할 수도 있습니다.
            let alert = UIAlertController(title: "QR 코드", message: qrCode, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        } else {
            print("QR 코드가 없습니다.")
            let alert = UIAlertController(title: "발견된 QR코드가 없습니다.", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
}
