//
//  DefaultAppVersionRepository.swift
//  CreateQR
//
//  Clean Architecture - Data Layer Repository Implementation
//

import Foundation

final class DefaultAppVersionRepository: AppVersionRepository {

    func fetchLatestAppStoreVersion(completion: @escaping (String?) -> Void) {
        let appID = NSLocalizedString("appid", comment: "Appid")
        let appStoreUrl = "https://itunes.apple.com/lookup?id=\(appID)"

        guard let url = URL(string: appStoreUrl) else {
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if error != nil {
                completion(nil)
                return
            }

            guard let data = data else {
                completion(nil)
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] {
                    if let results = json["results"] as? [[String: Any]],
                       let appStoreVersion = results.first?["version"] as? String {
                        completion(appStoreVersion)
                    } else {
                        completion(nil)
                    }
                } else {
                    completion(nil)
                }
            } catch {
                completion(nil)
            }
        }.resume()
    }

    func fetchCurrentAppVersion() -> String? {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    }
}
