//
//  DefaultRQListRepository.swift
//  CreateQR
//
//  Created by 김미진 on 10/11/24.
//

import Foundation
import UIKit

final class DefaultRQListRepository {
    init() { }
}

extension DefaultRQListRepository: QRListRepository {
    
    func fetchQRTypeList(
        completion: @escaping (Result<[QRTypeItem], Error>) -> Void
    ) -> Cancellable? {
        
        let task = RepositoryTask()
        
        //  MARK: - 추후 통신이 추가해야함.
        
        let urlType = QRTypeItem(id: "defaultType", title: "Text", titleImage: UIImage(systemName: "safari"), detailImage: nil, type: .url)
        let wifiType = QRTypeItem(id: "wifiType", title: "Wifi", titleImage: UIImage(systemName: "wifi.router"), detailImage: nil, type: .wifi)
        let contactType = QRTypeItem(id: "contactType", title: NSLocalizedString("Contact", comment: "Contact QR"), titleImage: UIImage(systemName: "person.crop.circle"), detailImage: nil, type: .contact)
        let instagramType = QRTypeItem(id: "instagramType", title: "Instagram", titleImage: UIImage(systemName: "dot.square"), detailImage: nil, type: .instagram)
        let youtubeType = QRTypeItem(id: "youtubeType", title: "YouTube", titleImage: UIImage(systemName: "play.rectangle"), detailImage: nil, type: .youtube)
        let tiktokType = QRTypeItem(id: "tiktokType", title: "TikTok", titleImage: UIImage(systemName: "music.note"), detailImage: nil, type: .tiktok)
        let emailType = QRTypeItem(id: "emailType", title: NSLocalizedString("Email", comment: "Email QR"), titleImage: UIImage(systemName: "envelope"), detailImage: nil, type: .email)
        let phoneType = QRTypeItem(id: "phoneType", title: NSLocalizedString("Phone", comment: "Phone QR"), titleImage: UIImage(systemName: "phone"), detailImage: nil, type: .phone)
        let smsType = QRTypeItem(id: "smsType", title: NSLocalizedString("Message", comment: "SMS QR"), titleImage: UIImage(systemName: "message"), detailImage: nil, type: .sms)
        let geoType = QRTypeItem(id: "geoType", title: NSLocalizedString("Location", comment: "Geo QR"), titleImage: UIImage(systemName: "mappin.and.ellipse"), detailImage: nil, type: .geo)
        let calendarType = QRTypeItem(id: "calendarType", title: NSLocalizedString("Event", comment: "Calendar QR"), titleImage: UIImage(systemName: "calendar"), detailImage: nil, type: .calendar)
        completion(.success([urlType, wifiType, contactType, emailType, phoneType, smsType, geoType, calendarType, instagramType, youtubeType, tiktokType]))
        
        return task
    }
}
