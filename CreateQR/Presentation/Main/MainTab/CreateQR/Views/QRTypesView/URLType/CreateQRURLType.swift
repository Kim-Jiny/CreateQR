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
    @IBOutlet weak var shareBtn: UIButton!
    @IBOutlet weak var colorBtn: UIButton!
    @IBOutlet weak var logoBtn: UIButton!
    @IBOutlet weak var qrStackView: UIStackView!
    private var saveBtnIndicator: UIActivityIndicatorView!
    
    override func setupUI() {
        
        let placeholderText = "https://yourURL.com"
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.speedMain3 // 플레이스홀더 색상 변경
        ]

        let attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: attributes)
        urlTextField.attributedPlaceholder = attributedPlaceholder
        
        let scrollInset: CGFloat = 20
        mainScrollView.contentInset = UIEdgeInsets(top: scrollInset, left: 0, bottom: scrollInset, right: 0)
        
        generateBtn.setTitle(NSLocalizedString("Generate", comment: ""), for: .normal)
        generateBtn.layer.cornerRadius = 10
        generateBtn.layer.borderWidth = 2.0
        generateBtn.layer.borderColor = UIColor.speedMain4.cgColor
        
        saveBtn.setTitle(NSLocalizedString("Save", comment: "Save"), for: .normal)
        saveBtn.layer.cornerRadius = 10
        saveBtn.layer.borderWidth = 2.0
        saveBtn.layer.borderColor = UIColor.speedMain4.cgColor
        
        shareBtn.setTitle(NSLocalizedString("Share", comment: "Share"), for: .normal)
        shareBtn.layer.cornerRadius = 10
        shareBtn.layer.borderWidth = 2.0
        shareBtn.layer.borderColor = UIColor.speedMain4.cgColor
        
        colorBtn.setTitle(NSLocalizedString("Color", comment: "Share"), for: .normal)
        colorBtn.layer.cornerRadius = 10
        colorBtn.layer.borderWidth = 2.0
        colorBtn.layer.borderColor = UIColor.speedMain4.cgColor
        
        logoBtn.setTitle(NSLocalizedString("Add logo", comment: "Add logo"), for: .normal)
        logoBtn.layer.cornerRadius = 10
        logoBtn.layer.borderWidth = 2.0
        logoBtn.layer.borderColor = UIColor.speedMain4.cgColor
    
        saveBtnIndicator = UIActivityIndicatorView(style: .medium)
        saveBtnIndicator.color = .white
        saveBtnIndicator.translatesAutoresizingMaskIntoConstraints = false
        saveBtn.addSubview(saveBtnIndicator)
        saveBtnIndicator.snp.makeConstraints { 
            $0.center.equalTo(saveBtn.snp.center)
        }
        
    }
    
    @IBAction func generateBtn(_ sender: Any) {
        let url = getUrl()
        self.delegate?.generateQR(url: url)
    }
    
    @IBAction func saveBtn(_ sender: Any) {
        if let _ = qrImg.image {
            saveBtn.isEnabled = false
            saveBtnIndicator.startAnimating()
            self.delegate?.saveImage()
        }
    }
    @IBAction func shareBtn(_ sender: Any) {
        guard let _ = qrImg.image else {
            print("공유할 이미지가 없습니다.")
            return
        }
        self.delegate?.shareImage()
    }
    
    @IBAction func colorBtn(_ sender: Any) {
        self.delegate?.colorPicker()
    }
    
    @IBAction func logoBtn(_ sender: Any) {
        self.delegate?.addLogo()
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
    
    func getUrl() -> String {
        // urlTextField.text가 nil이거나 빈 문자열이면 기본 URL 반환
        let defaultUrl = "You made it blank"

        if let urlText = urlTextField.text, !urlText.isEmpty {
            return urlText // 입력된 URL을 반환
        } else {
            return defaultUrl // 기본 URL 반환
        }
    }
    
    // 이미지 저장 완료 후 처리
    override func imageSaveCompleted() {
        // 인디케이터 중지
        saveBtnIndicator.stopAnimating()
        // 버튼 다시 활성화
        saveBtn.isEnabled = true
    }
    
}
