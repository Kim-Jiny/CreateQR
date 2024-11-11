//
//  CreateQRURLType.swift
//  CreateQR
//
//  Created by 김미진 on 11/8/24.
//

import UIKit
import CoreImage


class CreateQRURLType: CreateQRTypeView {

    @IBOutlet weak var mainScrollView: UIScrollView!
    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var qrImg: UIImageView!
    @IBOutlet weak var generateBtn: UIButton!
    @IBOutlet weak var saveBtn: UIButton!
    private var activityIndicator: UIActivityIndicatorView!
    
    override func setupUI() {
        
        let placeholderText = "https://nachocode.io"
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.speedMain3 // 플레이스홀더 색상 변경
        ]

        let attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: attributes)
        urlTextField.attributedPlaceholder = attributedPlaceholder
        
        let scrollInset: CGFloat = 20
        mainScrollView.contentInset = UIEdgeInsets(top: scrollInset, left: 0, bottom: scrollInset, right: 0)
        
        generateBtn.layer.cornerRadius = 10
        generateBtn.layer.borderWidth = 2.0
        generateBtn.layer.borderColor = UIColor.speedMain2.cgColor
        
        saveBtn.layer.cornerRadius = 10
        saveBtn.layer.borderWidth = 2.0
        saveBtn.layer.borderColor = UIColor.speedMain2.cgColor
        
        
        activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.color = .white
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        saveBtn.addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints { 
            $0.center.equalTo(saveBtn.snp.center)
        }
    }
    
    @IBAction func generateBtn(_ sender: Any) {
        let url = getUrl()
        if let img = generateQR(from: url, color: .black, backgroundColor: .clear, logo: nil ) {
            qrImg.image = img
        }
    }
    
    @IBAction func saveBtn(_ sender: Any) {
        if let img = qrImg.image {
            saveBtn.isEnabled = false
            activityIndicator.startAnimating()
            self.delegate?.saveImage(img: img)
        }
    }
    
    func getAppIcon() -> UIImage? {
        if let iconFileName = Bundle.main.infoDictionary?["CFBundleIcons"] as? [String: Any],
           let primaryIcons = iconFileName["CFBundlePrimaryIcon"] as? [String: Any],
           let iconFiles = primaryIcons["CFBundleIconFiles"] as? [String],
           let iconName = iconFiles.first {
            return UIImage(named: iconName)
        }
        return nil
    }
    // QR 코드 생성 함수 (색상 변경 및 커스텀 이미지 추가 포함)
    func generateQR(from string: String, color: UIColor, backgroundColor: UIColor, logo: UIImage?) -> UIImage? {
        // QR 코드 문자열을 CIImage로 변환
        let data = string.data(using: .utf8)
        
        guard let filter = CIFilter(name: "CIQRCodeGenerator") else {
            return nil
        }
        
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue("Q", forKey: "inputCorrectionLevel")
        
        guard let qrImage = filter.outputImage else {
            return nil
        }
        
        // 색상 변경을 위한 필터 적용
        let colorFilter = CIFilter(name: "CIFalseColor")
        colorFilter?.setValue(qrImage, forKey: kCIInputImageKey)
        colorFilter?.setValue(CIColor(color: color), forKey: "inputColor0")
        colorFilter?.setValue(CIColor(color: backgroundColor), forKey: "inputColor1")
        
        guard let coloredQRImage = colorFilter?.outputImage else {
            return nil
        }
        
        // 이미지를 표시할 크기로 스케일 조정
        let transform = CGAffineTransform(scaleX: 10, y: 10)
        let scaledQRImage = coloredQRImage.transformed(by: transform)
        
        // UIImage로 변환
        let qrUIImage = convert(scaledQRImage)
        
        // 로고가 있는 경우 QR 코드 중앙에 추가
        if let qrUIImage = qrUIImage, let logo = logo {
            return overlayLogo(on: qrUIImage, logo: logo)
        }
        
        func convert(_ cmage:CIImage) -> UIImage? {
            let context:CIContext = CIContext(options: nil)
            guard let cgImage:CGImage = context.createCGImage(cmage, from: cmage.extent) else { return nil }
            let image:UIImage = UIImage(cgImage: cgImage)
            return image
        }
        
        return qrUIImage
    }

    // QR 코드 위에 로고를 추가하는 함수
    private func overlayLogo(on qrImage: UIImage, logo: UIImage) -> UIImage? {
        let qrSize = qrImage.size
        let logoSize = CGSize(width: qrSize.width / 4, height: qrSize.height / 4) // 로고 크기 조정
        let logoOrigin = CGPoint(x: (qrSize.width - logoSize.width) / 2, y: (qrSize.height - logoSize.height) / 2)
        
        UIGraphicsBeginImageContext(qrSize)
        qrImage.draw(in: CGRect(origin: .zero, size: qrSize))
        
        // 로고 그리기
        logo.draw(in: CGRect(origin: logoOrigin, size: logoSize))
        
        let combinedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return combinedImage
    }
    
    func getUrl() -> String {
        // urlTextField.text가 nil이거나 빈 문자열이면 기본 URL 반환
        let defaultUrl = "https://nachocode.io"

        if let urlText = urlTextField.text, !urlText.isEmpty {
            return urlText // 입력된 URL을 반환
        } else {
            return defaultUrl // 기본 URL 반환
        }
    }
    
    // 이미지 저장 완료 후 처리
    override func imageSaveCompleted() {
        // 인디케이터 중지
        activityIndicator.stopAnimating()
        // 버튼 다시 활성화
        saveBtn.isEnabled = true
    }
}
