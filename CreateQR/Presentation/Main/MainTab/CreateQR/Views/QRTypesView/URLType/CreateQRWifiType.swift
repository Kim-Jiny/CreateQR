//
//  CreateQRBetaType.swift
//  CreateQR
//
//  Created by 김미진 on 11/12/24.
//

import UIKit

class CreateQRWifiType: CreateQRTypeView, QRActionHandling {
    
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
    var saveActivityIndicator: UIActivityIndicatorView!
    var primaryActionButton: UIButton? { createBtn }
    var saveActionButton: UIButton! { saveBtn }
    var shareActionButton: UIButton! { shareBtn }
    var colorActionButton: UIButton! { colorBtn }
    var logoActionButton: UIButton! { logoBtn }
    
    override func setupUI() {
        wifiTitle.text = NSLocalizedString("Wifi Name", comment: "Wifi Name")
        
        let placeholderText = NSLocalizedString("My wifi name", comment: "Wifi name placeholder")
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.speedMain3 // 플레이스홀더 색상 변경
        ]

        let attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: attributes)
        wifiTitleTextField.attributedPlaceholder = attributedPlaceholder
        let placeholderText2 = NSLocalizedString("My wifi password", comment: "Wifi password placeholder")
        let attributes2: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.speedMain3 // 플레이스홀더 색상 변경
        ]

        let attributedPlaceholder2 = NSAttributedString(string: placeholderText2, attributes: attributes2)
        wifiPwTextField.attributedPlaceholder = attributedPlaceholder2
        
        wifiPw.text = NSLocalizedString("Wifi Password", comment: "Wifi Password")
        
        configureQRActionButtons()
        configureSaveIndicator()
    }
    
    @IBAction func generateBtn(_ sender: Any) {
        guard let ssid = wifiTitleTextField.text, !ssid.isEmpty else {
            delegate?.wifiTitlePopup()
            return
        }
        
        let password = wifiPwTextField.text ?? ""
        let wifiType = password.isEmpty ? "nopass" : "WPA"

        let qrContent = "WIFI:T:\(wifiType);S:\(Self.escapeWifiValue(ssid));P:\(Self.escapeWifiValue(password));;"

        delegate?.generateQR(url: qrContent)
    }

    /// Escapes reserved characters in a WIFI: URI field per the MECARD/WIFI scheme.
    /// The characters `\ ; , : "` are structural delimiters and must be backslash-escaped
    /// when they appear inside an SSID or password, otherwise scanners misparse the payload.
    static func escapeWifiValue(_ value: String) -> String {
        var result = ""
        for character in value {
            switch character {
            case "\\", ";", ",", ":", "\"":
                result.append("\\")
                result.append(character)
            default:
                result.append(character)
            }
        }
        return result
    }

    
    @IBAction func saveBtn(_ sender: Any) {
        handleSaveTap()
    }
    
    @IBAction func shareBtn(_ sender: Any) {
        handleShareTap()
    }
    
    @IBAction func colorBtn(_ sender: Any) {
        handleColorTap()
    }
    
    @IBAction func logoBtn(_ sender: Any) {
        handleLogoTap()
    }
    
    // 이미지 저장 완료 후 처리
    override func imageSaveCompleted() {
        finishSaveAction()
    }
}
