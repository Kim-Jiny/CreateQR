//
//  TimestampProvider.swift
//  CreateQR
//
//  Created by 김미진 on 11/13/24.
//

import Foundation
class TimestampProvider {
    func getCurrentTimestamp() -> Double {
        return Date().timeIntervalSince1970
    }
    
    func getFormattedDate(_ time: Double) -> String {
        let date = Date(timeIntervalSince1970: time)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd_HH:mm:ss"
        let formattedDate = dateFormatter.string(from: date)
        
        return formattedDate
    }
}
