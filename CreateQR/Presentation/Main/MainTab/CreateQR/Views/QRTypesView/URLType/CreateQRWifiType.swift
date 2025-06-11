//
//  CreateQRBetaType.swift
//  CreateQR
//
//  Created by 김미진 on 11/12/24.
//

import UIKit

class CreateQRWifiType: CreateQRTypeView {
    
    @IBOutlet weak var wifiTitle: UILabel!
    @IBOutlet weak var wifiTitleTextField: UITextField!
    @IBOutlet weak var wifiPw: UILabel!
    @IBOutlet weak var wifiPwTextField: UITextField!
    
    @IBOutlet weak var qrImg: UIImageView!
    @IBOutlet weak var createBtn: UIButton!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var shareBtn: UIButton!
    @IBOutlet weak var colorBtn: UIButton!
    @IBOutlet weak var logoBtn: UIButton!
    @IBOutlet weak var qrStackView: UIStackView!
    private var saveBtnIndicator: UIActivityIndicatorView!
    
    override func setupUI() {
        wifiTitle.text = NSLocalizedString("Wifi Name", comment: "Wifi Name")
        
        let placeholderText = "My wifi name"
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.speedMain3 // 플레이스홀더 색상 변경
        ]

        let attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: attributes)
        wifiTitleTextField.attributedPlaceholder = attributedPlaceholder
        let placeholderText2 = "My wifi password"
        let attributes2: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.speedMain3 // 플레이스홀더 색상 변경
        ]

        let attributedPlaceholder2 = NSAttributedString(string: placeholderText2, attributes: attributes2)
        wifiPwTextField.attributedPlaceholder = attributedPlaceholder2
        
        wifiPw.text = NSLocalizedString("Wifi Password", comment: "Wifi Password")
        
        createBtn.setTitle(NSLocalizedString("Generate", comment: ""), for: .normal)
        createBtn.layer.cornerRadius = 10
        createBtn.layer.borderWidth = 2.0
        createBtn.layer.borderColor = UIColor.speedMain4.cgColor
        
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
        guard let ssid = wifiTitleTextField.text, !ssid.isEmpty else {
            delegate?.wifiTitlePopup()
            return
        }
        
        let password = wifiPwTextField.text ?? ""
        let wifiType = password.isEmpty ? "nopass" : "WPA"
        
        let qrContent = "WIFI:T:\(wifiType);S:\(ssid);P:\(password);;"
        
        delegate?.generateQR(url: qrContent)
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
    
    // 이미지 저장 완료 후 처리
    override func imageSaveCompleted() {
        // 인디케이터 중지
        saveBtnIndicator.stopAnimating()
        // 버튼 다시 활성화
        saveBtn.isEnabled = true
    }
}
