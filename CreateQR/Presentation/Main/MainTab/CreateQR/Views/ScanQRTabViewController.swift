//
//  ScanQRTabViewController.swift
//  CreateQR
//
//  Created by 김미진 on 11/11/24.
//

import Foundation
import UIKit
import AVFoundation
import Contacts
import ContactsUI
import Vision

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
    private var isCameraViewConfigured = false
    private var isScanningActive = false
    
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = cameraPreviewView.bounds
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
        guard !isCameraViewConfigured else {
            previewLayer?.frame = cameraPreviewView.bounds
            return
        }
        isCameraViewConfigured = true
        cameraView.addSubview(cameraPreviewView)
        cameraPreviewView.snp.makeConstraints {
            $0.top.bottom.leading.trailing.equalToSuperview()
        }
        
        
        previewLayer = AVCaptureVideoPreviewLayer(session: AVCaptureSession())
        previewLayer?.frame = cameraPreviewView.bounds
        previewLayer?.videoGravity = .resizeAspectFill
        if let previewLayer {
            cameraPreviewView.layer.addSublayer(previewLayer)
        }
        
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("ScanQRTabViewController viewDidDisappear")
        previewLayer?.removeFromSuperlayer()
        self.previewLayer = nil
        isCameraViewConfigured = false
        isScanningActive = false
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
            self?.startScanningIfNeeded()
        }
        
        // QR 스캔 결과에 따라 처리
        viewModel?.scannedResult.observe(on: self) { [weak self] result in
            print("값 도착: \(result)")
            if result != "" {
                self?.isScanningActive = false
                self?.viewModel?.stopScanning()
                self?.qrDataAlert(result)
            }else {
                self?.startScanningIfNeeded()
            }
        }
    }

    private func startScanningIfNeeded() {
        guard !isScanningActive, let previewLayer = previewLayer else { return }
        isScanningActive = true
        viewModel?.startScanning(previewLayer: previewLayer)
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

    // QR 코드 스캔 함수 (갤러리 이미지) — Vision 프레임워크 사용
    func scanQRCode(from image: UIImage) {
        guard let cgImage = image.cgImage else {
            showNoQRCodeAlert()
            return
        }

        let request = VNDetectBarcodesRequest { [weak self] request, _ in
            let payload = (request.results as? [VNBarcodeObservation])?
                .first(where: { $0.symbology == .qr })?
                .payloadStringValue

            DispatchQueue.main.async {
                guard let self else { return }
                if let payload, !payload.isEmpty {
                    print("QR 코드 내용: \(payload)")
                    self.qrDataAlert(payload)
                } else {
                    print("QR 코드가 없습니다.")
                    self.showNoQRCodeAlert()
                }
            }
        }
        request.symbologies = [.qr]

        // Vision 작업은 백그라운드에서 수행
        DispatchQueue.global(qos: .userInitiated).async {
            let handler = VNImageRequestHandler(cgImage: cgImage, orientation: image.cgImageOrientation, options: [:])
            do {
                try handler.perform([request])
            } catch {
                DispatchQueue.main.async { [weak self] in
                    self?.showNoQRCodeAlert()
                }
            }
        }
    }

    private func showNoQRCodeAlert() {
        let alert = UIAlertController(title: NSLocalizedString("No QR code found", comment:"No QR code found"), message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment:"OK"), style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func qrDataAlert(_ qrCode: String) {
        // vCard 감지
        if qrCode.hasPrefix("BEGIN:VCARD") {
            showVCardAlert(qrCode)
            return
        }

        // Instagram URL 감지
        if let instagramUsername = extractInstagramUsername(from: qrCode) {
            showInstagramAlert(username: instagramUsername, originalURL: qrCode)
            return
        }

        // YouTube URL 감지
        if let youtubeChannel = extractYouTubeChannel(from: qrCode) {
            showYouTubeAlert(channel: youtubeChannel, originalURL: qrCode)
            return
        }

        // TikTok URL 감지
        if let tiktokUsername = extractTikTokUsername(from: qrCode) {
            showTikTokAlert(username: tiktokUsername, originalURL: qrCode)
            return
        }

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

        alert.addAction(UIAlertAction(title: NSLocalizedString("Save to app as QR code", comment:"Save to app as QR code"), style: .default, handler: { _ in
            let qrImg = self.viewModel?.generateQR(from: qrCode, color: .black, backgroundColor: .white, logo: nil, logoStyle: .square)
            let item = QRItem(title: qrCode, qrImageData: qrImg?.pngData(), qrType: .other, qrData: qrCode, qrColor: UIColor.black.toHex() ?? "000000FF", backColor: UIColor.white.toHex() ?? "FFFFFFFF", logo: nil, logoStyle: .square)
            self.viewModel?.addMyQR(item)
            self.viewModel?.scannedResult.value = ""
        }))

        present(alert, animated: true, completion: nil)
    }

    // MARK: - Instagram 처리
    private func extractInstagramUsername(from urlString: String) -> String? {
        // instagram.com/username 또는 www.instagram.com/username 패턴 감지
        guard let url = URL(string: urlString),
              let host = url.host?.lowercased(),
              (host == "instagram.com" || host == "www.instagram.com") else {
            return nil
        }

        let pathComponents = url.pathComponents.filter { $0 != "/" }
        guard let username = pathComponents.first, !username.isEmpty else {
            return nil
        }

        // 특수 경로 제외 (p, reel, stories 등)
        let excludedPaths = ["p", "reel", "reels", "stories", "explore", "accounts", "direct"]
        if excludedPaths.contains(username.lowercased()) {
            return nil
        }

        return username
    }

    private func showInstagramAlert(username: String, originalURL: String) {
        let alert = UIAlertController(
            title: NSLocalizedString("Instagram", comment: "Instagram"),
            message: "@\(username)",
            preferredStyle: .alert
        )

        // Instagram 앱으로 열기
        let instagramAppURL = URL(string: "instagram://user?username=\(username)")
        if let appURL = instagramAppURL, UIApplication.shared.canOpenURL(appURL) {
            alert.addAction(UIAlertAction(
                title: NSLocalizedString("Open in Instagram", comment: ""),
                style: .default
            ) { _ in
                self.viewModel?.scannedResult.value = ""
                UIApplication.shared.open(appURL)
            })
        }

        // 웹으로 열기
        if let webURL = URL(string: originalURL) {
            alert.addAction(UIAlertAction(
                title: NSLocalizedString("Open in Safari", comment: ""),
                style: .default
            ) { _ in
                self.viewModel?.scannedResult.value = ""
                UIApplication.shared.open(webURL)
            })
        }

        // QR로 저장
        alert.addAction(UIAlertAction(
            title: NSLocalizedString("Save to app as QR code", comment: ""),
            style: .default
        ) { _ in
            let qrImg = self.viewModel?.generateQR(from: originalURL, color: .black, backgroundColor: .white, logo: nil, logoStyle: .square)
            let item = QRItem(title: "@\(username)", qrImageData: qrImg?.pngData(), qrType: .instagram, qrData: originalURL, qrColor: UIColor.black.toHex() ?? "000000FF", backColor: UIColor.white.toHex() ?? "FFFFFFFF", logo: nil, logoStyle: .square)
            self.viewModel?.addMyQR(item)
            self.viewModel?.scannedResult.value = ""
        })

        // 취소
        alert.addAction(UIAlertAction(
            title: NSLocalizedString("Cancel", comment: ""),
            style: .cancel
        ) { _ in
            self.viewModel?.scannedResult.value = ""
        })

        present(alert, animated: true)
    }

    // MARK: - YouTube 처리
    private func extractYouTubeChannel(from urlString: String) -> String? {
        // youtube.com/@channel 또는 youtube.com/channel/xxx 패턴 감지
        guard let url = URL(string: urlString),
              let host = url.host?.lowercased(),
              (host == "youtube.com" || host == "www.youtube.com" || host == "m.youtube.com" || host == "youtu.be") else {
            return nil
        }

        let pathComponents = url.pathComponents.filter { $0 != "/" }

        // @핸들 형식
        if let first = pathComponents.first, first.hasPrefix("@") {
            return first
        }

        // /channel/XXXXX 형식
        if pathComponents.count >= 2 && pathComponents[0] == "channel" {
            return pathComponents[1]
        }

        // /c/채널명 형식
        if pathComponents.count >= 2 && pathComponents[0] == "c" {
            return "@\(pathComponents[1])"
        }

        // youtu.be/비디오ID (비디오 링크는 채널이 아님)
        if host == "youtu.be" {
            return nil
        }

        return nil
    }

    private func showYouTubeAlert(channel: String, originalURL: String) {
        let displayChannel = channel.hasPrefix("@") ? channel : "@\(channel)"

        let alert = UIAlertController(
            title: NSLocalizedString("YouTube", comment: "YouTube"),
            message: displayChannel,
            preferredStyle: .alert
        )

        // YouTube 앱으로 열기
        let youtubeAppURL = URL(string: "youtube://\(originalURL.replacingOccurrences(of: "https://", with: "").replacingOccurrences(of: "http://", with: ""))")
        if let appURL = youtubeAppURL, UIApplication.shared.canOpenURL(appURL) {
            alert.addAction(UIAlertAction(
                title: NSLocalizedString("Open in YouTube", comment: ""),
                style: .default
            ) { _ in
                self.viewModel?.scannedResult.value = ""
                UIApplication.shared.open(appURL)
            })
        }

        // 웹으로 열기
        if let webURL = URL(string: originalURL) {
            alert.addAction(UIAlertAction(
                title: NSLocalizedString("Open in Safari", comment: ""),
                style: .default
            ) { _ in
                self.viewModel?.scannedResult.value = ""
                UIApplication.shared.open(webURL)
            })
        }

        // QR로 저장
        alert.addAction(UIAlertAction(
            title: NSLocalizedString("Save to app as QR code", comment: ""),
            style: .default
        ) { _ in
            let qrImg = self.viewModel?.generateQR(from: originalURL, color: .black, backgroundColor: .white, logo: nil, logoStyle: .square)
            let item = QRItem(title: displayChannel, qrImageData: qrImg?.pngData(), qrType: .youtube, qrData: originalURL, qrColor: UIColor.black.toHex() ?? "000000FF", backColor: UIColor.white.toHex() ?? "FFFFFFFF", logo: nil, logoStyle: .square)
            self.viewModel?.addMyQR(item)
            self.viewModel?.scannedResult.value = ""
        })

        // 취소
        alert.addAction(UIAlertAction(
            title: NSLocalizedString("Cancel", comment: ""),
            style: .cancel
        ) { _ in
            self.viewModel?.scannedResult.value = ""
        })

        present(alert, animated: true)
    }

    // MARK: - TikTok 처리
    private func extractTikTokUsername(from urlString: String) -> String? {
        // tiktok.com/@username 패턴 감지
        guard let url = URL(string: urlString),
              let host = url.host?.lowercased(),
              (host == "tiktok.com" || host == "www.tiktok.com" || host == "m.tiktok.com" || host == "vm.tiktok.com") else {
            return nil
        }

        let pathComponents = url.pathComponents.filter { $0 != "/" }

        // @유저네임 형식
        if let first = pathComponents.first, first.hasPrefix("@") {
            return String(first.dropFirst())
        }

        return nil
    }

    private func showTikTokAlert(username: String, originalURL: String) {
        let alert = UIAlertController(
            title: NSLocalizedString("TikTok", comment: "TikTok"),
            message: "@\(username)",
            preferredStyle: .alert
        )

        // TikTok 앱으로 열기
        let tiktokAppURL = URL(string: "snssdk1233://user/profile/\(username)")
        if let appURL = tiktokAppURL, UIApplication.shared.canOpenURL(appURL) {
            alert.addAction(UIAlertAction(
                title: NSLocalizedString("Open in TikTok", comment: ""),
                style: .default
            ) { _ in
                self.viewModel?.scannedResult.value = ""
                UIApplication.shared.open(appURL)
            })
        }

        // 웹으로 열기
        if let webURL = URL(string: originalURL) {
            alert.addAction(UIAlertAction(
                title: NSLocalizedString("Open in Safari", comment: ""),
                style: .default
            ) { _ in
                self.viewModel?.scannedResult.value = ""
                UIApplication.shared.open(webURL)
            })
        }

        // QR로 저장
        alert.addAction(UIAlertAction(
            title: NSLocalizedString("Save to app as QR code", comment: ""),
            style: .default
        ) { _ in
            let qrImg = self.viewModel?.generateQR(from: originalURL, color: .black, backgroundColor: .white, logo: nil, logoStyle: .square)
            let item = QRItem(title: "@\(username)", qrImageData: qrImg?.pngData(), qrType: .tiktok, qrData: originalURL, qrColor: UIColor.black.toHex() ?? "000000FF", backColor: UIColor.white.toHex() ?? "FFFFFFFF", logo: nil, logoStyle: .square)
            self.viewModel?.addMyQR(item)
            self.viewModel?.scannedResult.value = ""
        })

        // 취소
        alert.addAction(UIAlertAction(
            title: NSLocalizedString("Cancel", comment: ""),
            style: .cancel
        ) { _ in
            self.viewModel?.scannedResult.value = ""
        })

        present(alert, animated: true)
    }

    // MARK: - vCard 처리
    private func showVCardAlert(_ vCardString: String) {
        guard let contact = parseVCard(vCardString) else {
            // 파싱 실패 시 일반 알림 표시
            let alert = UIAlertController(
                title: NSLocalizedString("Contact QR", comment: ""),
                message: vCardString,
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default) { _ in
                self.viewModel?.scannedResult.value = ""
            })
            present(alert, animated: true)
            return
        }

        // 연락처 정보 표시
        var message = ""
        if !contact.givenName.isEmpty || !contact.familyName.isEmpty {
            message += "\(contact.familyName)\(contact.givenName)"
        }
        if let phone = contact.phoneNumbers.first?.value.stringValue {
            message += "\n📞 \(phone)"
        }
        if let email = contact.emailAddresses.first?.value as String? {
            message += "\n✉️ \(email)"
        }
        if !contact.organizationName.isEmpty {
            message += "\n🏢 \(contact.organizationName)"
        }

        let alert = UIAlertController(
            title: NSLocalizedString("Contact Found", comment: ""),
            message: message,
            preferredStyle: .alert
        )

        // 연락처에 추가 버튼
        alert.addAction(UIAlertAction(
            title: NSLocalizedString("Add to Contacts", comment: ""),
            style: .default
        ) { [weak self] _ in
            self?.viewModel?.scannedResult.value = ""
            self?.showContactViewController(contact: contact)
        })

        // QR로 저장 버튼
        alert.addAction(UIAlertAction(
            title: NSLocalizedString("Save to app as QR code", comment: ""),
            style: .default
        ) { [weak self] _ in
            let qrImg = self?.viewModel?.generateQR(from: vCardString, color: .black, backgroundColor: .white, logo: nil, logoStyle: .square)
            let title = "\(contact.familyName)\(contact.givenName)"
            let item = QRItem(title: title, qrImageData: qrImg?.pngData(), qrType: .contact, qrData: vCardString, qrColor: UIColor.black.toHex() ?? "000000FF", backColor: UIColor.white.toHex() ?? "FFFFFFFF", logo: nil, logoStyle: .square)
            self?.viewModel?.addMyQR(item)
            self?.viewModel?.scannedResult.value = ""
        })

        // 취소 버튼
        alert.addAction(UIAlertAction(
            title: NSLocalizedString("Cancel", comment: ""),
            style: .cancel
        ) { _ in
            self.viewModel?.scannedResult.value = ""
        })

        present(alert, animated: true)
    }

    private func parseVCard(_ vCardString: String) -> CNMutableContact? {
        let contact = CNMutableContact()

        let lines = vCardString.components(separatedBy: "\n")
        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)

            if trimmedLine.hasPrefix("FN:") {
                // Full Name
                let name = String(trimmedLine.dropFirst(3))
                contact.givenName = name
            } else if trimmedLine.hasPrefix("N:") {
                // Structured Name: N:성;이름;;;
                let nameComponents = String(trimmedLine.dropFirst(2)).components(separatedBy: ";")
                if nameComponents.count >= 2 {
                    contact.familyName = nameComponents[0]
                    contact.givenName = nameComponents[1]
                }
            } else if trimmedLine.hasPrefix("TEL:") || trimmedLine.hasPrefix("TEL;") {
                // Phone
                var phone = trimmedLine
                if let colonIndex = trimmedLine.firstIndex(of: ":") {
                    phone = String(trimmedLine[trimmedLine.index(after: colonIndex)...])
                }
                let phoneNumber = CNLabeledValue(
                    label: CNLabelPhoneNumberMobile,
                    value: CNPhoneNumber(stringValue: phone)
                )
                contact.phoneNumbers.append(phoneNumber)
            } else if trimmedLine.hasPrefix("EMAIL:") || trimmedLine.hasPrefix("EMAIL;") {
                // Email
                var email = trimmedLine
                if let colonIndex = trimmedLine.firstIndex(of: ":") {
                    email = String(trimmedLine[trimmedLine.index(after: colonIndex)...])
                }
                let emailAddress = CNLabeledValue(
                    label: CNLabelHome,
                    value: email as NSString
                )
                contact.emailAddresses.append(emailAddress)
            } else if trimmedLine.hasPrefix("ORG:") {
                // Organization
                let org = String(trimmedLine.dropFirst(4))
                contact.organizationName = org
            } else if trimmedLine.hasPrefix("URL:") {
                // URL
                let urlString = String(trimmedLine.dropFirst(4))
                let url = CNLabeledValue(
                    label: CNLabelURLAddressHomePage,
                    value: urlString as NSString
                )
                contact.urlAddresses.append(url)
            }
        }

        // 최소한 이름이나 전화번호가 있어야 유효한 연락처
        if contact.givenName.isEmpty && contact.familyName.isEmpty && contact.phoneNumbers.isEmpty {
            return nil
        }

        return contact
    }

    private func showContactViewController(contact: CNMutableContact) {
        let contactVC = CNContactViewController(forUnknownContact: contact)
        contactVC.contactStore = CNContactStore()
        contactVC.delegate = self
        contactVC.allowsEditing = true
        contactVC.allowsActions = true

        let navController = UINavigationController(rootViewController: contactVC)
        present(navController, animated: true)
    }
}

// MARK: - CNContactViewControllerDelegate
extension ScanQRTabViewController: CNContactViewControllerDelegate {
    func contactViewController(_ viewController: CNContactViewController, didCompleteWith contact: CNContact?) {
        viewController.dismiss(animated: true)
    }
}

private extension UIImage {
    /// Maps the UIImage orientation to the CGImagePropertyOrientation that Vision expects,
    /// so QR codes in rotated photos are still detected.
    var cgImageOrientation: CGImagePropertyOrientation {
        switch imageOrientation {
        case .up: return .up
        case .down: return .down
        case .left: return .left
        case .right: return .right
        case .upMirrored: return .upMirrored
        case .downMirrored: return .downMirrored
        case .leftMirrored: return .leftMirrored
        case .rightMirrored: return .rightMirrored
        @unknown default: return .up
        }
    }
}
