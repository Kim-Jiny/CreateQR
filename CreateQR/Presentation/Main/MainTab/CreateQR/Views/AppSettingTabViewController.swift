//
//  MyHistoryTabViewController.swift
//  CreateQR
//
//  Created by 김미진 on 10/11/24.
//

import Foundation
import UIKit
import MessageUI

class AppSettingTabViewController: UIViewController, StoryboardInstantiable, MFMailComposeViewControllerDelegate {
    
    var viewModel: MainViewModel?
    @IBOutlet weak var appUpdateView: UIView!
    @IBOutlet weak var appUpdateBtn: UIButton!
    @IBOutlet weak var nowAppVersion: UILabel!
    @IBOutlet weak var newAppVersion: UILabel!
    @IBOutlet weak var safeAreaTopConstraints: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupCV()
    }
    
    private func setupCV() {
        
        appUpdateBtn.layer.cornerRadius = 20
        appUpdateBtn.layer.borderWidth = 2
        appUpdateBtn.layer.borderColor = UIColor.speedMain4.cgColor
        
        if let nowVersion = getNowVer() {
            nowAppVersion.isHidden = false
            
            viewModel?.loadLatestVersion(completion: {[weak self] version in
                DispatchQueue.main.async {
                    if let version = version, nowVersion != version {
                        self?.nowAppVersion.text = "현재 버전 : \(nowVersion)"
                        
                        self?.newAppVersion.isHidden = false
                        self?.newAppVersion.text = "스토어 최신 버전 : \(version)"
                        self?.newAppVersion.font = .systemFont(ofSize: 12)
                        self?.newAppVersion.textColor = .speedMain0
                        
                        self?.appUpdateView.isHidden = false
                    }else {
                        self?.nowAppVersion.text = "현재 버전 : \(nowVersion)"
                        
                        self?.newAppVersion.isHidden = false
                        self?.newAppVersion.font = .systemFont(ofSize: 10)
                        self?.newAppVersion.textColor = .speedMain2
                        self?.newAppVersion.text = "최신 버전 입니다."
                        
                        self?.appUpdateView.isHidden = true
                    }
                }
            })
        }else {
            newAppVersion.isHidden = true
            nowAppVersion.isHidden = true
            appUpdateView.isHidden = true
        }
        
    }
    
    private func getNowVer() -> String? {
        if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            return appVersion
        }
        return nil
    }
    
    @IBAction func appUpdateBtn(_ sender: Any) {
        if let url = URL(string: "https://apps.apple.com/app/id6472643559") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    @IBAction func sendDeveloper(_ sender: Any) {
        
        // 이메일 지원 확인
        guard MFMailComposeViewController.canSendMail() else {
            self.showAlert(title: "오류", message: "메일을 보낼 수 없습니다.")
            return
        }
        
        // 메일 작성 창 설정
        let mailComposeVC = MFMailComposeViewController()
        mailComposeVC.mailComposeDelegate = self
        mailComposeVC.setToRecipients(["kjinyz@naver.com"]) // 수신인 설정
        mailComposeVC.setSubject("Inquiry about “QR Creation” app") // 메일 제목
        mailComposeVC.setMessageBody("앱 관련 문의 사항을 작성해 주세요.", isHTML: false) // 메일 본문
        
        // 메일 작성 창 표시
        present(mailComposeVC, animated: true, completion: nil)
    }
    
    // 메일 전송 후 결과 처리
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true) {
            switch result {
            case .sent:
                self.showAlert(title: "메일 전송", message: "메일이 성공적으로 전송되었습니다.")
            case .saved:
                self.showAlert(title: "메일 저장", message: "메일이 임시 저장되었습니다.")
            case .cancelled:
                self.showAlert(title: "전송 취소", message: "메일 전송이 취소되었습니다.")
            case .failed:
                self.showAlert(title: "전송 실패", message: "메일 전송에 실패하였습니다.")
            @unknown default:
                self.showAlert(title: "오류", message: "알 수 없는 오류가 발생했습니다.")
            }
        }
    }
    // 알림을 띄우는 메서드
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
