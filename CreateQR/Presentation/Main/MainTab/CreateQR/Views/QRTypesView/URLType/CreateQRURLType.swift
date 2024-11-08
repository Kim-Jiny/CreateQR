//
//  CreateQRURLType.swift
//  CreateQR
//
//  Created by 김미진 on 11/8/24.
//

import UIKit
import CoreImage

class CreateQRURLType: CreateQRTypeView {

    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var qrImg: UIImageView!
    
    override func setupUI() {
        
        let placeholderText = "https://nachocode.io"
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.speedMain3 // 플레이스홀더 색상 변경
        ]

        let attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: attributes)
        urlTextField.attributedPlaceholder = attributedPlaceholder
    }
    
    @IBAction func generateBtn(_ sender: Any) {
        let url = getUrl()
        if let img = generateQRCode(from: url) {
            qrImg.image = img
        }
    }
    
    func generateQRCode(from string: String) -> UIImage? {
        // 문자열을 QR 코드 데이터로 변환
        let data = string.data(using: .utf8)
        
        // QR 코드 생성 필터
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            
            // QR 코드 이미지 생성
            if let outputImage = filter.outputImage {
                // 이미지 크기 조정
                let transform = CGAffineTransform(scaleX: 10, y: 10) // 크기 조정 (여기서 10은 확대 배율)
                let scaledImage = outputImage.transformed(by: transform)
                
                // CIImage를 UIImage로 변환하여 반환
                return UIImage(ciImage: scaledImage)
            }
        }
        return nil
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
}
