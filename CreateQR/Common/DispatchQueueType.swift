//
//  DispatchQueueType.swift
//  CreateQR
//
//  Created by 김미진 on 10/8/24.
//

import Foundation

/// Used to easily mock main and background queues in tests
protocol DispatchQueueType {
    func async(execute work: @escaping () -> Void)
}

extension DispatchQueue: DispatchQueueType {
    func async(execute work: @escaping () -> Void) {
        async(group: nil, execute: work)
    }
}
