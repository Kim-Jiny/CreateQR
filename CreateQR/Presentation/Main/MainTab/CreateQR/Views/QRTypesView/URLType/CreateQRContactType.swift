//
//  CreateQRContactType.swift
//  CreateQR
//
//  Created for Contact (vCard) QR Code
//

import UIKit

class CreateQRContactType: CreateQRTypeView, QRActionHandling {

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
        nameLabel.text = NSLocalizedString("Name", comment: "Name") + " *"
        phoneLabel.text = NSLocalizedString("Phone", comment: "Phone") + " *"
        emailLabel.text = NSLocalizedString("Email", comment: "Email")
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
            string: NSLocalizedString("010-1234-5678", comment: "Phone number placeholder"),
            attributes: [.foregroundColor: placeholderColor]
        )
        phoneTextField.keyboardType = .phonePad

        emailTextField.attributedPlaceholder = NSAttributedString(
            string: NSLocalizedString("example@email.com (Optional)", comment: ""),
            attributes: [.foregroundColor: placeholderColor]
        )
        emailTextField.keyboardType = .emailAddress

        companyTextField.attributedPlaceholder = NSAttributedString(
            string: NSLocalizedString("Company Name (Optional)", comment: ""),
            attributes: [.foregroundColor: placeholderColor]
        )

        snsTextField.attributedPlaceholder = NSAttributedString(
            string: NSLocalizedString("instagram.com/username", comment: "SNS URL placeholder"),
            attributes: [.foregroundColor: placeholderColor]
        )
        snsTextField.keyboardType = .URL
    }

    // MARK: - Actions
    @IBAction func generateBtn(_ sender: Any) {
        guard let name = trimmedText(from: nameTextField) else {
            showInputAlert(message: NSLocalizedString("Please enter a name.", comment: ""))
            return
        }

        guard let phone = trimmedText(from: phoneTextField) else {
            showInputAlert(message: NSLocalizedString("Please enter a phone number.", comment: ""))
            return
        }

        let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let company = companyTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let sns = snsTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

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
        """

        if !email.isEmpty {
            vCard += "\nEMAIL:\(email)"
        }

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
