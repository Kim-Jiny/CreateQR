//
//  CreateQRTikTokType.swift
//  CreateQR
//
//  Created for TikTok Profile QR Code
//

import UIKit

class CreateQRTikTokType: CreateQRTypeView, QRActionHandling {

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

    var saveActivityIndicator: UIActivityIndicatorView!
    var primaryActionButton: UIButton? { createBtn }
    var saveActionButton: UIButton! { saveBtn }
    var shareActionButton: UIButton! { shareBtn }
    var colorActionButton: UIButton! { colorBtn }
    var logoActionButton: UIButton! { logoBtn }

    // MARK: - Setup
    override func setupUI() {
        setupLabels()
        setupTextFields()
        configureQRActionButtons()
        configureSaveIndicator()
    }

    private func setupLabels() {
        usernameLabel.text = NSLocalizedString("TikTok Username", comment: "TikTok Username")
    }

    private func setupTextFields() {
        let placeholderColor = UIColor.speedMain3

        usernameTextField.attributedPlaceholder = NSAttributedString(
            string: NSLocalizedString("@username", comment: "TikTok username placeholder"),
            attributes: [.foregroundColor: placeholderColor]
        )
        usernameTextField.keyboardType = .asciiCapable
        usernameTextField.autocapitalizationType = .none
        usernameTextField.autocorrectionType = .no
    }

    // MARK: - Actions
    @IBAction func generateBtn(_ sender: Any) {
        guard let username = trimmedText(from: usernameTextField) else {
            showInputAlert(message: NSLocalizedString("Please enter a TikTok username.", comment: ""))
            return
        }

        // @ 제거
        let cleanUsername = username.hasPrefix("@") ? String(username.dropFirst()) : username

        // TikTok URL 생성
        let tiktokURL = "https://tiktok.com/@\(cleanUsername)"

        delegate?.generateQR(url: tiktokURL)
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

    override func imageSaveCompleted() {
        finishSaveAction()
    }
}
