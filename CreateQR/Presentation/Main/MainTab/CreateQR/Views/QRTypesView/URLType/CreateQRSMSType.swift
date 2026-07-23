//
//  CreateQRSMSType.swift
//  CreateQR
//
//  Single-field SMS QR type. Reuses the URL layout and emits an `SMSTO:` payload.
//

import UIKit

final class CreateQRSMSType: CreateQRURLType {

    override class var nibName: String { "CreateQRURLType" }

    override var inputPlaceholder: String {
        NSLocalizedString("+1 234 567 8900", comment: "SMS number placeholder")
    }

    override var emptyInputMessage: String {
        NSLocalizedString("Please enter a phone number.", comment: "")
    }

    override var inputKeyboardType: UIKeyboardType { .phonePad }

    override func makePayload(from input: String) -> String {
        // SMSTO:<number> — the widely supported QR scheme for pre-filling the Messages app.
        let allowed = CharacterSet(charactersIn: "+0123456789")
        let cleaned = input.unicodeScalars.filter { allowed.contains($0) }.map(String.init).joined()
        let number = cleaned.isEmpty ? input : cleaned
        return "SMSTO:\(number)"
    }
}
