//
//  CreateQRTypeView.swift
//  CreateQR
//
//  Created by 김미진 on 11/8/24.
//

import Foundation
import UIKit

protocol QRTypeDelegate: AnyObject {
    func generateQR(url : String)
    func saveImage()
    func shareImage()
    func colorPicker()
    func addLogo()
    
    func wifiTitlePopup()
}

enum ColorAreaType {
    case contents, back
}

protocol QRPreviewDisplayable where Self: UIView {
    var qrPreviewImageView: UIImageView { get }
    var qrPreviewStackView: UIStackView { get }
}

extension QRPreviewDisplayable {
    func displayGeneratedQR(_ image: UIImage) {
        qrPreviewImageView.image = image
        qrPreviewStackView.isHidden = false
    }
}

protocol QRActionHandling: QRPreviewDisplayable where Self: CreateQRTypeView {
    var primaryActionButton: UIButton? { get }
    var saveActionButton: UIButton! { get }
    var shareActionButton: UIButton! { get }
    var colorActionButton: UIButton! { get }
    var logoActionButton: UIButton! { get }
    var saveActivityIndicator: UIActivityIndicatorView! { get set }
}

extension QRActionHandling {
    func configureQRActionButtons(primaryTitle: String = NSLocalizedString("Generate", comment: "")) {
        let buttonConfigs: [(UIButton?, String)] = [
            (primaryActionButton, primaryTitle),
            (saveActionButton, NSLocalizedString("Save", comment: "Save")),
            (shareActionButton, NSLocalizedString("Share", comment: "Share")),
            (colorActionButton, NSLocalizedString("Color", comment: "Color")),
            (logoActionButton, NSLocalizedString("Add logo", comment: "Add logo"))
        ]

        for (button, title) in buttonConfigs {
            button?.setTitle(title, for: .normal)
            button?.layer.cornerRadius = 10
            button?.layer.borderWidth = 2
            button?.layer.borderColor = UIColor.speedMain4.cgColor
        }
    }

    func configureSaveIndicator() {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.color = .white
        indicator.translatesAutoresizingMaskIntoConstraints = false
        saveActionButton.addSubview(indicator)
        indicator.snp.makeConstraints {
            $0.center.equalTo(saveActionButton.snp.center)
        }
        saveActivityIndicator = indicator
    }

    func handleSaveTap() {
        guard qrPreviewImageView.image != nil else { return }
        saveActionButton.isEnabled = false
        saveActivityIndicator.startAnimating()
        delegate?.saveImage()
    }

    func handleShareTap() {
        guard qrPreviewImageView.image != nil else { return }
        delegate?.shareImage()
    }

    func handleColorTap() {
        delegate?.colorPicker()
    }

    func handleLogoTap() {
        delegate?.addLogo()
    }

    func finishSaveAction() {
        saveActivityIndicator.stopAnimating()
        saveActionButton.isEnabled = true
    }
}

struct CreateQRTypeViewFactory {
    func makeView(for type: CreateType) -> CreateQRTypeView {
        switch type {
        case .url:
            return CreateQRURLType()
        case .card:
            return CreateQRCardType()
        case .menu:
            return CreateQRBetaType()
        case .other:
            return CreateQRCardType()
        case .wifi:
            return CreateQRWifiType()
        case .contact:
            return CreateQRContactType()
        case .instagram:
            return CreateQRInstagramType()
        case .youtube:
            return CreateQRYouTubeType()
        case .tiktok:
            return CreateQRTikTokType()
        }
    }
}

class CreateQRTypeView: UIView {
    weak var delegate: QRTypeDelegate?
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    // MARK: - XIB 로드 및 설정
    
    func commonInit() {
        // XIB 로드
        let nib = UINib(nibName: String(describing: Self.self), bundle: Bundle(for: type(of: self)))
        guard let loadedView = nib.instantiate(withOwner: self, options: nil).first as? UIView else {
            return
        }
        
        // XIB에서 로드된 뷰를 현재 뷰에 추가
        loadedView.frame = self.bounds
        loadedView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(loadedView)
        setupUI()
    }
    
    func trimmedText(from textField: UITextField?) -> String? {
        guard let text = textField?.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !text.isEmpty else {
            return nil
        }
        return text
    }

    func showInputAlert(message: String) {
        let alert = UIAlertController(
            title: NSLocalizedString("Input Required", comment: "Input Required"),
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default))
        parentViewController?.present(alert, animated: true)
    }
    
    func setupUI() {}
    func imageSaveCompleted() {}
}

private extension UIView {
    var parentViewController: UIViewController? {
        sequence(first: self.next, next: { $0?.next })
            .first { $0 is UIViewController } as? UIViewController
    }
}
