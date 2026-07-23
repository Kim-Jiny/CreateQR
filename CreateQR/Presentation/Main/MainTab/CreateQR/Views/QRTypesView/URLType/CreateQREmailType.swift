//
//  CreateQREmailType.swift
//  CreateQR
//
//  Single-field email QR type. Reuses the URL layout and emits a `mailto:` payload.
//

import UIKit

final class CreateQREmailType: CreateQRURLType {

    // Reuse the single-field URL layout.
    override class var nibName: String { "CreateQRURLType" }

    override var inputPlaceholder: String {
        NSLocalizedString("name@example.com", comment: "Email address placeholder")
    }

    override var emptyInputMessage: String {
        NSLocalizedString("Please enter an email address.", comment: "")
    }

    override var inputKeyboardType: UIKeyboardType { .emailAddress }

    override func makePayload(from input: String) -> String {
        // mailto: — RFC 6068. Percent-encode the address so unusual characters survive.
        let encoded = input.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? input
        return "mailto:\(encoded)"
    }
}
