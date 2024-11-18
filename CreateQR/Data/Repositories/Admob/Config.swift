//
//  Config.swift
//  CreateQR
//
//  Created by 김미진 on 11/18/24.
//

import Foundation

struct AdmobConfig {
    struct Banner {
        static let mainKey = "ca-app-pub-2707874353926722/8768235207"
        static let listKey = "ca-app-pub-2707874353926722/6824598149"
        static let testKey = "ca-app-pub-3940256099942544/2435281174"
    }
}

enum AdmobType {
    case main, list
}
