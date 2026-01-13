//
//  CreateQRInstagramType.swift
//  CreateQR
//
//  Created for Instagram Profile QR Code
//

import UIKit

class CreateQRInstagramType: CreateQRTypeView {

    // MARK: - IBOutlets
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var usernameTextField: UITextField!

    @IBOutlet weak var qrImg: UIImageView!
    @IBOutlet weak var createBtn: UIButton!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var shareBtn: UIButton!
    @IBOutlet weak var colorBtn: UIButton!
    @IBOutlet weak var logoBtn: UIButton!
    @IBOutlet weak var qrStackView: UIStackView!

    private var saveBtnIndicator: UIActivityIndicatorView!

    // MARK: - Setup
    override func setupUI() {
        setupLabels()
        setupTextFields()
        setupButtons()
        setupIndicator()
    }

    private func setupLabels() {
        usernameLabel.text = NSLocalizedString("Instagram Username", comment: "Instagram Username")
    }

    private func setupTextFields() {
        let placeholderColor = UIColor.speedMain3

        usernameTextField.attributedPlaceholder = NSAttributedString(
            string: "@username",
            attributes: [.foregroundColor: placeholderColor]
        )
        usernameTextField.keyboardType = .asciiCapable
        usernameTextField.autocapitalizationType = .none
        usernameTextField.autocorrectionType = .no
    }

    private func setupButtons() {
        let buttons = [createBtn, saveBtn, shareBtn, colorBtn, logoBtn]
        let titles = [
            NSLocalizedString("Generate", comment: ""),
            NSLocalizedString("Save", comment: ""),
            NSLocalizedString("Share", comment: ""),
            NSLocalizedString("Color", comment: ""),
            NSLocalizedString("Add logo", comment: "")
        ]

        for (index, button) in buttons.enumerated() {
            button?.setTitle(titles[index], for: .normal)
            button?.layer.cornerRadius = 10
            button?.layer.borderWidth = 2.0
            button?.layer.borderColor = UIColor.speedMain4.cgColor
        }
    }

    private func setupIndicator() {
        saveBtnIndicator = UIActivityIndicatorView(style: .medium)
        saveBtnIndicator.color = .white
        saveBtnIndicator.translatesAutoresizingMaskIntoConstraints = false
        saveBtn.addSubview(saveBtnIndicator)
        saveBtnIndicator.snp.makeConstraints {
            $0.center.equalTo(saveBtn.snp.center)
        }
    }

    // MARK: - Actions
    @IBAction func generateBtn(_ sender: Any) {
        guard let username = usernameTextField.text, !username.isEmpty else {
            // TODO: Show alert for empty username
            return
        }

        // @ 제거
        let cleanUsername = username.hasPrefix("@") ? String(username.dropFirst()) : username

        // Instagram deeplink URL 생성
        // 앱이 설치되어 있으면 앱으로 열리고, 없으면 웹으로 열림
        let instagramURL = "https://instagram.com/\(cleanUsername)"

        delegate?.generateQR(url: instagramURL)
    }

    @IBAction func saveBtn(_ sender: Any) {
        if let _ = qrImg.image {
            saveBtn.isEnabled = false
            saveBtnIndicator.startAnimating()
            delegate?.saveImage()
        }
    }

    @IBAction func shareBtn(_ sender: Any) {
        guard let _ = qrImg.image else { return }
        delegate?.shareImage()
    }

    @IBAction func colorBtn(_ sender: Any) {
        delegate?.colorPicker()
    }

    @IBAction func logoBtn(_ sender: Any) {
        delegate?.addLogo()
    }

    override func imageSaveCompleted() {
        saveBtnIndicator.stopAnimating()
        saveBtn.isEnabled = true
    }
}
