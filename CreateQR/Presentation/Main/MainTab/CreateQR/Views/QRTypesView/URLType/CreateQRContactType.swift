//
//  CreateQRContactType.swift
//  CreateQR
//
//  Created for Contact (vCard) QR Code
//

import UIKit

class CreateQRContactType: CreateQRTypeView {

    // MARK: - IBOutlets (Required Fields)
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!

    // MARK: - IBOutlets (Optional Fields)
    @IBOutlet weak var companyLabel: UILabel!
    @IBOutlet weak var companyTextField: UITextField!
    @IBOutlet weak var snsLabel: UILabel!
    @IBOutlet weak var snsTextField: UITextField!

    // MARK: - IBOutlets (QR & Buttons)
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
        nameLabel.text = NSLocalizedString("Name", comment: "Name") + " *"
        phoneLabel.text = NSLocalizedString("Phone", comment: "Phone") + " *"
        emailLabel.text = NSLocalizedString("Email", comment: "Email") + " *"
        companyLabel.text = NSLocalizedString("Company", comment: "Company")
        snsLabel.text = NSLocalizedString("SNS / Website", comment: "SNS")
    }

    private func setupTextFields() {
        let placeholderColor = UIColor.speedMain3

        nameTextField.attributedPlaceholder = NSAttributedString(
            string: NSLocalizedString("Full Name", comment: ""),
            attributes: [.foregroundColor: placeholderColor]
        )

        phoneTextField.attributedPlaceholder = NSAttributedString(
            string: "010-1234-5678",
            attributes: [.foregroundColor: placeholderColor]
        )
        phoneTextField.keyboardType = .phonePad

        emailTextField.attributedPlaceholder = NSAttributedString(
            string: "example@email.com",
            attributes: [.foregroundColor: placeholderColor]
        )
        emailTextField.keyboardType = .emailAddress

        companyTextField.attributedPlaceholder = NSAttributedString(
            string: NSLocalizedString("Company Name (Optional)", comment: ""),
            attributes: [.foregroundColor: placeholderColor]
        )

        snsTextField.attributedPlaceholder = NSAttributedString(
            string: "instagram.com/username",
            attributes: [.foregroundColor: placeholderColor]
        )
        snsTextField.keyboardType = .URL
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
        guard let name = nameTextField.text, !name.isEmpty else {
            // TODO: Show alert for empty name
            return
        }

        guard let phone = phoneTextField.text, !phone.isEmpty else {
            // TODO: Show alert for empty phone
            return
        }

        guard let email = emailTextField.text, !email.isEmpty else {
            // TODO: Show alert for empty email
            return
        }

        let company = companyTextField.text ?? ""
        let sns = snsTextField.text ?? ""

        // Generate vCard format
        let vCard = generateVCard(
            name: name,
            phone: phone,
            email: email,
            company: company,
            url: sns
        )

        delegate?.generateQR(url: vCard)
    }

    private func generateVCard(name: String, phone: String, email: String, company: String, url: String) -> String {
        var vCard = """
        BEGIN:VCARD
        VERSION:3.0
        FN:\(name)
        TEL:\(formatPhoneNumber(phone))
        EMAIL:\(email)
        """

        if !company.isEmpty {
            vCard += "\nORG:\(company)"
        }

        if !url.isEmpty {
            var formattedURL = url
            if !url.hasPrefix("http://") && !url.hasPrefix("https://") {
                formattedURL = "https://" + url
            }
            vCard += "\nURL:\(formattedURL)"
        }

        vCard += "\nEND:VCARD"

        return vCard
    }

    private func formatPhoneNumber(_ phone: String) -> String {
        // Remove all non-numeric characters except +
        let cleaned = phone.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()

        // If Korean number without country code, add +82
        if cleaned.hasPrefix("010") || cleaned.hasPrefix("011") {
            return "+82" + String(cleaned.dropFirst())
        }

        return phone
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
