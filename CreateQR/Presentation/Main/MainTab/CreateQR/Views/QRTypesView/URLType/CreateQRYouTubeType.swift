//
//  CreateQRYouTubeType.swift
//  CreateQR
//
//  Created for YouTube Channel QR Code
//

import UIKit

class CreateQRYouTubeType: CreateQRTypeView, QRActionHandling {

    // MARK: - IBOutlets
    @IBOutlet weak var channelLabel: UILabel!
    @IBOutlet weak var channelTextField: UITextField!

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
        channelLabel.text = NSLocalizedString("YouTube Channel", comment: "YouTube Channel")
    }

    private func setupTextFields() {
        let placeholderColor = UIColor.speedMain3

        channelTextField.attributedPlaceholder = NSAttributedString(
            string: NSLocalizedString("@channel", comment: "YouTube channel placeholder"),
            attributes: [.foregroundColor: placeholderColor]
        )
        channelTextField.keyboardType = .asciiCapable
        channelTextField.autocapitalizationType = .none
        channelTextField.autocorrectionType = .no
    }

    // MARK: - Actions
    @IBAction func generateBtn(_ sender: Any) {
        guard let channel = trimmedText(from: channelTextField) else {
            showInputAlert(message: NSLocalizedString("Please enter a YouTube channel handle.", comment: ""))
            return
        }

        // @ 제거 및 URL 생성
        let rawChannel = channel.hasPrefix("@") ? channel : "@\(channel)"
        let cleanChannel = rawChannel.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? rawChannel

        // YouTube URL 생성
        let youtubeURL = "https://youtube.com/\(cleanChannel)"

        delegate?.generateQR(url: youtubeURL)
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
