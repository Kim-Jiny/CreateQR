//
//  CreateQRGeoType.swift
//  CreateQR
//
//  Single-field geo-location QR type. Reuses the URL layout and emits a `geo:` payload.
//  Accepts "latitude, longitude" (comma- or space-separated).
//

import UIKit

final class CreateQRGeoType: CreateQRURLType {

    override class var nibName: String { "CreateQRURLType" }

    override var inputPlaceholder: String {
        NSLocalizedString("37.5665, 126.9780", comment: "Latitude, longitude placeholder")
    }

    override var emptyInputMessage: String {
        NSLocalizedString("Please enter a location as latitude, longitude.", comment: "")
    }

    override var inputKeyboardType: UIKeyboardType { .numbersAndPunctuation }

    override func makePayload(from input: String) -> String {
        // Accept comma- or whitespace-separated coordinates; fall back to raw input.
        let parts = input
            .replacingOccurrences(of: ",", with: " ")
            .split(separator: " ")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }

        if parts.count >= 2, Double(parts[0]) != nil, Double(parts[1]) != nil {
            return "geo:\(parts[0]),\(parts[1])"
        }
        return "geo:\(input.trimmingCharacters(in: .whitespaces))"
    }
}
