//
//  CreateQRPhoneType.swift
//  CreateQR
//
//  Single-field phone QR type. Reuses the URL layout and emits a `tel:` payload.
//

import UIKit

final class CreateQRPhoneType: CreateQRURLType {

    override class var nibName: String { "CreateQRURLType" }

    override var inputPlaceholder: String {
        NSLocalizedString("+1 234 567 8900", comment: "Phone number placeholder")
    }

    override var emptyInputMessage: String {
        NSLocalizedString("Please enter a phone number.", comment: "")
    }

    override var inputKeyboardType: UIKeyboardType { .phonePad }

    override func makePayload(from input: String) -> String {
        // tel: — keep leading + and digits, strip spaces/dashes/parentheses that some scanners reject.
        let allowed = CharacterSet(charactersIn: "+0123456789")
        let cleaned = input.unicodeScalars.filter { allowed.contains($0) }.map(String.init).joined()
        let number = cleaned.isEmpty ? input : cleaned
        return "tel:\(number)"
    }
}
