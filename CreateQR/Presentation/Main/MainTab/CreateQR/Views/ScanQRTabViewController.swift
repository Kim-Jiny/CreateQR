//
//  ScanQRTabViewController.swift
//  CreateQR
//
//  Created by 김미진 on 11/11/24.
//

import Foundation
import UIKit
import AVFoundation

class ScanQRTabViewController: UIViewController, StoryboardInstantiable {
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
                self?.showPermissionAlert()
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
           let alert = UIAlertController(title: "Camera Permission Needed",
                                         message: "Please allow camera access to scan QR codes.",
                                         preferredStyle: .alert)
           alert.addAction(UIAlertAction(title: "OK", style: .default))
           present(alert, animated: true)
       }
}
