//
//  CreateQRCalendarType.swift
//  CreateQR
//
//  Multi-field calendar-event QR type. Built programmatically (no XIB) and emits a
//  VCALENDAR/VEVENT payload that scanners offer to add to the calendar.
//

import UIKit

final class CreateQRCalendarType: CreateQRTypeView, QRActionHandling {

    // MARK: - Inputs
    private let titleField = CreateQRCalendarType.makeField()
    private let locationField = CreateQRCalendarType.makeField()
    private let startPicker = CreateQRCalendarType.makePicker()
    private let endPicker = CreateQRCalendarType.makePicker()

    // MARK: - Actions / preview (QRActionHandling)
    private let generateButton = UIButton(type: .system)
    private let saveButton = UIButton(type: .system)
    private let shareButton = UIButton(type: .system)
    private let colorButton = UIButton(type: .system)
    private let logoButton = UIButton(type: .system)
    private let previewImage = UIImageView()
    private let previewContainer = UIStackView()
    var saveActivityIndicator: UIActivityIndicatorView!

    var qrPreviewImageView: UIImageView { previewImage }
    var qrPreviewStackView: UIStackView { previewContainer }
    var primaryActionButton: UIButton? { generateButton }
    var saveActionButton: UIButton! { saveButton }
    var shareActionButton: UIButton! { shareButton }
    var colorActionButton: UIButton! { colorButton }
    var logoActionButton: UIButton! { logoButton }

    // MARK: - Build (programmatic, replaces XIB loading)
    override func commonInit() {
        buildUI()
        setupUI()
    }

    override func setupUI() {
        configureQRActionButtons(primaryTitle: NSLocalizedString("Generate", comment: ""))
        configureSaveIndicator()
        previewContainer.isHidden = true

        generateButton.addTarget(self, action: #selector(generateTapped), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        shareButton.addTarget(self, action: #selector(shareTapped), for: .touchUpInside)
        colorButton.addTarget(self, action: #selector(colorTapped), for: .touchUpInside)
        logoButton.addTarget(self, action: #selector(logoTapped), for: .touchUpInside)

        // Keep end >= start.
        endPicker.minimumDate = startPicker.date
        startPicker.addTarget(self, action: #selector(startChanged), for: .valueChanged)
    }

    private func buildUI() {
        backgroundColor = .speedMain3

        let scrollView = UIScrollView()
        scrollView.keyboardDismissMode = .interactive
        addSubview(scrollView)
        scrollView.snp.makeConstraints { $0.edges.equalToSuperview() }

        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 14
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(top: 24, left: 20, bottom: 24, right: 20)
        scrollView.addSubview(stack)
        stack.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }

        titleField.placeholder = NSLocalizedString("Event title", comment: "")
        locationField.placeholder = NSLocalizedString("Location (optional)", comment: "")

        stack.addArrangedSubview(label(NSLocalizedString("Event title", comment: "")))
        stack.addArrangedSubview(titleField)
        stack.addArrangedSubview(label(NSLocalizedString("Location (optional)", comment: "")))
        stack.addArrangedSubview(locationField)
        stack.addArrangedSubview(label(NSLocalizedString("Starts", comment: "")))
        stack.addArrangedSubview(startPicker)
        stack.addArrangedSubview(label(NSLocalizedString("Ends", comment: "")))
        stack.addArrangedSubview(endPicker)
        stack.addArrangedSubview(generateButton)
        generateButton.snp.makeConstraints { $0.height.equalTo(48) }

        // Preview + action buttons (hidden until generated).
        previewImage.contentMode = .scaleAspectFit
        previewImage.snp.makeConstraints { $0.height.equalTo(220) }

        let buttonRow = UIStackView(arrangedSubviews: [saveButton, shareButton, colorButton, logoButton])
        buttonRow.axis = .horizontal
        buttonRow.distribution = .fillEqually
        buttonRow.spacing = 8
        buttonRow.snp.makeConstraints { $0.height.equalTo(44) }

        previewContainer.axis = .vertical
        previewContainer.spacing = 12
        previewContainer.addArrangedSubview(previewImage)
        previewContainer.addArrangedSubview(buttonRow)
        stack.addArrangedSubview(previewContainer)
    }

    // MARK: - Actions
    @objc private func startChanged() {
        endPicker.minimumDate = startPicker.date
        if endPicker.date < startPicker.date { endPicker.date = startPicker.date }
    }

    @objc private func generateTapped() {
        guard let title = trimmedText(from: titleField) else {
            showInputAlert(message: NSLocalizedString("Please enter an event title.", comment: ""))
            return
        }
        delegate?.generateQR(url: makeVEvent(title: title))
    }

    @objc private func saveTapped() { handleSaveTap() }
    @objc private func shareTapped() { handleShareTap() }
    @objc private func colorTapped() { handleColorTap() }
    @objc private func logoTapped() { handleLogoTap() }

    override func imageSaveCompleted() { finishSaveAction() }

    // MARK: - Payload
    private func makeVEvent(title: String) -> String {
        let location = locationField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        var lines = [
            "BEGIN:VCALENDAR",
            "VERSION:2.0",
            "BEGIN:VEVENT",
            "SUMMARY:\(Self.escape(title))",
            "DTSTART:\(Self.iCalDate(startPicker.date))",
            "DTEND:\(Self.iCalDate(endPicker.date))"
        ]
        if !location.isEmpty {
            lines.append("LOCATION:\(Self.escape(location))")
        }
        lines.append("END:VEVENT")
        lines.append("END:VCALENDAR")
        return lines.joined(separator: "\n")
    }

    private static func escape(_ value: String) -> String {
        var out = ""
        for ch in value {
            switch ch {
            case "\\": out += "\\\\"
            case ";": out += "\\;"
            case ",": out += "\\,"
            case "\n": out += "\\n"
            default: out.append(ch)
            }
        }
        return out
    }

    private static let icalFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "yyyyMMdd'T'HHmmss"
        return f
    }()

    private static func iCalDate(_ date: Date) -> String {
        icalFormatter.string(from: date)
    }

    // MARK: - Factory helpers
    private static func makeField() -> UITextField {
        let field = UITextField()
        field.borderStyle = .roundedRect
        field.backgroundColor = .white
        field.textColor = .black
        field.snp.makeConstraints { $0.height.equalTo(44) }
        return field
    }

    private static func makePicker() -> UIDatePicker {
        let picker = UIDatePicker()
        picker.datePickerMode = .dateAndTime
        picker.preferredDatePickerStyle = .compact
        return picker
    }

    private func label(_ text: String) -> UILabel {
        let l = UILabel()
        l.text = text
        l.font = .systemFont(ofSize: 14, weight: .semibold)
        l.textColor = .speedMain0
        return l
    }
}
