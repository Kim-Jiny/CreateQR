//
//  CreateQRURLType.swift
//  CreateQR
//
//  Created by 김미진 on 11/8/24.
//

import UIKit
import CoreImage


class CreateQRURLType: CreateQRTypeView, QRActionHandling {

    @IBOutlet weak var mainScrollView: UIScrollView!
    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var qrImg: UIImageView!
    @IBOutlet weak var generateBtn: UIButton!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var shareBtn: UIButton!
    @IBOutlet weak var colorBtn: UIButton!
    @IBOutlet weak var logoBtn: UIButton!
    @IBOutlet weak var qrStackView: UIStackView!
    var saveActivityIndicator: UIActivityIndicatorView!

    var primaryActionButton: UIButton? { generateBtn }
    var saveActionButton: UIButton! { saveBtn }
    var shareActionButton: UIButton! { shareBtn }
    var colorActionButton: UIButton! { colorBtn }
    var logoActionButton: UIButton! { logoBtn }
    
    override func setupUI() {
        
        let placeholderText = NSLocalizedString("https://yourURL.com", comment: "URL placeholder")
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.speedMain3 // 플레이스홀더 색상 변경
        ]

        let attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: attributes)
        urlTextField.attributedPlaceholder = attributedPlaceholder
        
        let scrollInset: CGFloat = 20
        mainScrollView.contentInset = UIEdgeInsets(top: scrollInset, left: 0, bottom: scrollInset, right: 0)
        
        configureQRActionButtons()
        configureSaveIndicator()
    }
    
    @IBAction func generateBtn(_ sender: Any) {
        guard let url = trimmedText(from: urlTextField) else {
            showInputAlert(message: NSLocalizedString("Please enter text or a URL to generate a QR code.", comment: ""))
            return
        }
        self.delegate?.generateQR(url: url)
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
    
    func getAppIcon() -> UIImage? {
        if let iconFileName = Bundle.main.infoDictionary?["CFBundleIcons"] as? [String: Any],
           let primaryIcons = iconFileName["CFBundlePrimaryIcon"] as? [String: Any],
           let iconFiles = primaryIcons["CFBundleIconFiles"] as? [String],
           let iconName = iconFiles.first {
            return UIImage(named: iconName)
        }
        return nil
    }
    
    // 이미지 저장 완료 후 처리
    override func imageSaveCompleted() {
        finishSaveAction()
    }
    
}
