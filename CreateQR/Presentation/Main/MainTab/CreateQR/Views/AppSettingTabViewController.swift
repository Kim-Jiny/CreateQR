//
//  MyHistoryTabViewController.swift
//  CreateQR
//
//  Created by 김미진 on 10/11/24.
//

import Foundation
import UIKit

class AppSettingTabViewController: UIViewController, StoryboardInstantiable {
    
    var viewModel: MainViewModel?
    @IBOutlet weak var appUpdateView: UIView!
    @IBOutlet weak var appUpdateBtn: UIButton!
    @IBOutlet weak var nowAppVersion: UILabel!
    @IBOutlet weak var newAppVersion: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupCV()
    }
    
    private func setupCV() {
        if let nowVersion = getNowVer() {
            nowAppVersion.isHidden = true
            nowAppVersion.text = "현재 앱 버전 : \(nowVersion)"
        }else {
            nowAppVersion.isHidden = false
        }
        
        viewModel?.loadLatestVersion(completion: {[weak self] version in
            print("new app version \(version)")
            DispatchQueue.main.async {
                if let version = version {
                    self?.newAppVersion.isHidden = false
                    self?.newAppVersion.text = "최신 버전 : \(version)"
                    if let nowVersion = self?.getNowVer() {
                    }
                }else {
                    self?.newAppVersion.isHidden = true
                }
            }
        })
    }
    
    private func getNowVer() -> String? {
        if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            return appVersion
        }
        return nil
    }
    
    @IBAction func appUpdateBtn(_ sender: Any) {
        
    }
    
}
