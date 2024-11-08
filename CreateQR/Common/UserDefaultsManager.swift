//
//  UserDefaultsManager.swift
//  CreateQR
//
//  Created by 김미진 on 10/11/24.
//

import Foundation

class UserDefaultsManager {
    static let shared = UserDefaultsManager()
    
    private init() {}
    
    func getData<T>(forKey key: String) -> T? {
        return UserDefaults.standard.object(forKey: key) as? T
    }
    
    func setData<T>(_ value: T, forKey key: String) {
        UserDefaults.standard.set(value, forKey: key)
        UserDefaults.standard.synchronize()
    }
}
