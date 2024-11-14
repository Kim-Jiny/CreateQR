//
//  QRDetailViewModel.swift
//  CreateQR
//
//  Created by 김미진 on 10/11/24.
//

import Foundation

protocol QRDetailViewModelInput {
    
}

protocol QRDetailViewModelOutput {
    var title: String { get }
}

protocol QRDetailViewModel: QRDetailViewModelInput, QRDetailViewModelOutput { }

final class DefaultQRDetailViewModel: QRDetailViewModel {
    
    let title: String
    private let mainQueue: DispatchQueueType
    
    init(
        qrData: QRItem,
        mainQueue: DispatchQueueType = DispatchQueue.main
    ) {
        self.title = qrData.title
        self.mainQueue = mainQueue
    }
}
