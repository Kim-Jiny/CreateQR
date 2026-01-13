//
//  CreateQRBankTransferType.swift
//  CreateQR
//
//  Created for Bank Transfer QR Code
//

import UIKit

class CreateQRBankTransferType: CreateQRTypeView {

    // MARK: - IBOutlets
    @IBOutlet weak var bankLabel: UILabel!
    @IBOutlet weak var bankTextField: UITextField!
    @IBOutlet weak var accountLabel: UILabel!
    @IBOutlet weak var accountTextField: UITextField!
    @IBOutlet weak var holderLabel: UILabel!
    @IBOutlet weak var holderTextField: UITextField!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var amountTextField: UITextField!

    @IBOutlet weak var qrImg: UIImageView!
    @IBOutlet weak var createBtn: UIButton!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var shareBtn: UIButton!
    @IBOutlet weak var colorBtn: UIButton!
    @IBOutlet weak var logoBtn: UIButton!
    @IBOutlet weak var qrStackView: UIStackView!

    private var saveBtnIndicator: UIActivityIndicatorView!

    // MARK: - Bank List
    private let bankList = [
        "KB국민은행", "신한은행", "하나은행", "우리은행", "NH농협은행",
        "IBK기업은행", "SC제일은행", "카카오뱅크", "토스뱅크", "케이뱅크",
        "새마을금고", "우체국", "수협은행", "대구은행", "부산은행",
        "경남은행", "광주은행", "전북은행", "제주은행"
    ]

    private var bankPickerView: UIPickerView!

    // MARK: - Setup
    override func setupUI() {
        setupLabels()
        setupTextFields()
        setupButtons()
        setupBankPicker()
        setupIndicator()
    }

    private func setupLabels() {
        bankLabel.text = NSLocalizedString("Bank", comment: "Bank")
        accountLabel.text = NSLocalizedString("Account Number", comment: "Account Number")
        holderLabel.text = NSLocalizedString("Account Holder", comment: "Account Holder")
        amountLabel.text = NSLocalizedString("Amount (Optional)", comment: "Amount")
    }

    private func setupTextFields() {
        let placeholderColor = UIColor.speedMain3

        bankTextField.attributedPlaceholder = NSAttributedString(
            string: NSLocalizedString("Select Bank", comment: ""),
            attributes: [.foregroundColor: placeholderColor]
        )

        accountTextField.attributedPlaceholder = NSAttributedString(
            string: "1234-567-890123",
            attributes: [.foregroundColor: placeholderColor]
        )
        accountTextField.keyboardType = .numberPad

        holderTextField.attributedPlaceholder = NSAttributedString(
            string: NSLocalizedString("Account Holder Name", comment: ""),
            attributes: [.foregroundColor: placeholderColor]
        )

        amountTextField.attributedPlaceholder = NSAttributedString(
            string: "0",
            attributes: [.foregroundColor: placeholderColor]
        )
        amountTextField.keyboardType = .numberPad
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

    private func setupBankPicker() {
        bankPickerView = UIPickerView()
        bankPickerView.delegate = self
        bankPickerView.dataSource = self
        bankTextField.inputView = bankPickerView

        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(
            title: NSLocalizedString("Done", comment: ""),
            style: .done,
            target: self,
            action: #selector(bankPickerDone)
        )
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.setItems([flexSpace, doneButton], animated: false)
        bankTextField.inputAccessoryView = toolbar
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

    @objc private func bankPickerDone() {
        bankTextField.resignFirstResponder()
    }

    // MARK: - Actions
    @IBAction func generateBtn(_ sender: Any) {
        guard let bank = bankTextField.text, !bank.isEmpty else {
            // TODO: Show alert for empty bank
            return
        }

        guard let account = accountTextField.text, !account.isEmpty else {
            // TODO: Show alert for empty account
            return
        }

        guard let holder = holderTextField.text, !holder.isEmpty else {
            // TODO: Show alert for empty holder
            return
        }

        let amount = amountTextField.text ?? ""

        var qrContent = """
        은행: \(bank)
        계좌: \(account)
        예금주: \(holder)
        """

        if !amount.isEmpty, let amountValue = Int(amount.replacingOccurrences(of: ",", with: "")), amountValue > 0 {
            qrContent += "\n금액: \(formatNumber(amountValue))원"
        }

        delegate?.generateQR(url: qrContent)
    }

    private func formatNumber(_ number: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
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

// MARK: - UIPickerViewDelegate, UIPickerViewDataSource
extension CreateQRBankTransferType: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return bankList.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return bankList[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        bankTextField.text = bankList[row]
    }
}
