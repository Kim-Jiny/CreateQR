//
//  QRStatus.swift
//  CreateQR
//
//  Created by 김미진 on 11/11/24.
//
import Foundation

enum QRStatus {
    case success(_ code: String?)
    case fail
    case stop(_ isButtonTap: Bool)
}
