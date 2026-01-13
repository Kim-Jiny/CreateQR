//
//  CreateQRYouTubeType.swift
//  CreateQR
//
//  Created for YouTube Channel QR Code
//

import UIKit

class CreateQRYouTubeType: CreateQRTypeView {

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

    private var saveBtnIndicator: UIActivityIndicatorView!

    // MARK: - Setup
    override func setupUI() {
        setupLabels()
        setupTextFields()
        setupButtons()
        setupIndicator()
    }

    private func setupLabels() {
        channelLabel.text = NSLocalizedString("YouTube Channel", comment: "YouTube Channel")
    }

    private func setupTextFields() {
        let placeholderColor = UIColor.speedMain3

        channelTextField.attributedPlaceholder = NSAttributedString(
            string: "@channel",
            attributes: [.foregroundColor: placeholderColor]
        )
        channelTextField.keyboardType = .asciiCapable
        channelTextField.autocapitalizationType = .none
        channelTextField.autocorrectionType = .no
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
        guard let channel = channelTextField.text, !channel.isEmpty else {
            // TODO: Show alert for empty channel
            return
        }

        // @ 제거 및 URL 생성
        let cleanChannel = channel.hasPrefix("@") ? channel : "@\(channel)"

        // YouTube URL 생성
        let youtubeURL = "https://youtube.com/\(cleanChannel)"

        delegate?.generateQR(url: youtubeURL)
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
