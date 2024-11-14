//
//  AppVersionRepository.swift
//  CreateQR
//
//  Created by 김미진 on 11/14/24.
//

import Foundation

protocol AppVersionRepository {
    func fetchLatestAppStoreVersion(completion: @escaping (String?) -> Void)
    func fetchCurrentAppVersion() -> String?
}

final class DefaultAppVersionRepository: AppVersionRepository {
    func fetchLatestAppStoreVersion(completion: @escaping (String?) -> Void) {
        guard let bundleId = Bundle.main.bundleIdentifier else {
            completion(nil)
            return
        }
        
//        let urlString = "https://itunes.apple.com/lookup?bundleId=\(bundleId)"
        let appStoreUrl = "https://itunes.apple.com/lookup?id=6472643559" // 앱의 ID를 정확히 입력하세요.
            
        guard let url = URL(string: appStoreUrl) else {
            completion(nil)
            return
        }
            
            
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(nil)
                return
            }
            
            guard let data = data else {
                completion(nil)
                return
            }
            
            do {
                // JSON 파싱
                if let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] {
                    if let results = json["results"] as? [[String: Any]],
                       let appStoreVersion = results.first?["version"] as? String {
                        completion(appStoreVersion)
                    } else {
                        print("Version not found in results.")
                        completion(nil)
                    }
                } else {
                    print("Failed to parse JSON.")
                    completion(nil)
                }
            } catch {
                print("Error parsing JSON: \(error.localizedDescription)")
                completion(nil)
            }
        }.resume()
    }
    
    // 현재 앱 버전 가져오기
    func fetchCurrentAppVersion() -> String? {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    }
}
