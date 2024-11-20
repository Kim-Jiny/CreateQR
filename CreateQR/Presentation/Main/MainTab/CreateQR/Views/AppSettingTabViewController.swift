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
    
    @IBOutlet weak var contactUsLB: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        setupCV()
    }
    
    private func setupCV() {
        contactUsLB.text = NSLocalizedString("Contact Us", comment:"")
        
        appUpdateBtn.setTitle(NSLocalizedString("Update to the Latest Version", comment: ""), for: .normal)
        appUpdateBtn.layer.cornerRadius = 20
        appUpdateBtn.layer.borderWidth = 2
        appUpdateBtn.layer.borderColor = UIColor.speedMain4.cgColor
        
        if let nowVersion = getNowVer() {
            nowAppVersion.isHidden = false
            self.nowAppVersion.text = String(format: NSLocalizedString("Current Version: %@", comment: ""), nowVersion)
            
            viewModel?.loadLatestVersion(completion: { [weak self] version in
                DispatchQueue.main.async {
                    if let version = version, nowVersion.compare(version, options: .numeric) == .orderedAscending {
                        // 현재 버전이 앱스토어 버전보다 낮은 경우
                        self?.newAppVersion.isHidden = false
                        self?.newAppVersion.text = String(format: NSLocalizedString("Latest version on store: %@", comment: ""), version)

                        self?.newAppVersion.font = .systemFont(ofSize: 12)
                        self?.newAppVersion.textColor = .speedMain0
                        
                        self?.appUpdateView.isHidden = false
                    } else {
                        // 최신 버전인 경우
                        self?.newAppVersion.isHidden = false
                        self?.newAppVersion.font = .systemFont(ofSize: 10)
                        self?.newAppVersion.textColor = .speedMain2
                        self?.newAppVersion.text = NSLocalizedString("This is the latest version.", comment: "")
                        
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
        if let url = URL(string: "https://apps.apple.com/app/id\(NSLocalizedString("appid", comment: "Appid"))") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    @IBAction func sendDeveloper(_ sender: Any) {
        
        // 이메일 지원 확인
        guard MFMailComposeViewController.canSendMail() else {
            self.showAlert(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString("Unable to send email.", comment: ""))
            return
        }
        
        // 메일 작성 창 설정
        let mailComposeVC = MFMailComposeViewController()
        mailComposeVC.mailComposeDelegate = self
        mailComposeVC.setToRecipients(["kjinyz@naver.com"]) // 수신인 설정
        mailComposeVC.setSubject(NSLocalizedString("[QR Controller] App Inquiry", comment: "")) // 메일 제목
        mailComposeVC.setMessageBody(NSLocalizedString("Please write your inquiry regarding the app.", comment: ""), isHTML: false) // 메일 본문
        
        // 메일 작성 창 표시
        present(mailComposeVC, animated: true, completion: nil)
    }
    
    // 메일 전송 후 결과 처리
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true) {switch result {
            case .sent:
                self.showAlert(title: NSLocalizedString("Mail Sent", comment: ""), message: NSLocalizedString("The email was successfully sent.", comment: "메일이 성공적으로 전송되었습니다."))
            case .saved:
                self.showAlert(title: NSLocalizedString("Mail Saved", comment: ""), message: NSLocalizedString("The email has been saved as a draft.", comment: "메일이 임시 저장되었습니다."))
            case .cancelled:
                self.showAlert(title: NSLocalizedString("Mail Canceled", comment: ""), message: NSLocalizedString("The email sending was canceled.", comment: "메일 전송이 취소되었습니다."))
            case .failed:
                self.showAlert(title: NSLocalizedString("Mail Failed", comment: ""), message: NSLocalizedString("Failed to send the email.", comment: "메일 전송에 실패하였습니다."))
            @unknown default:
                self.showAlert(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString("An unknown error occurred.", comment: "알 수 없는 오류가 발생했습니다."))
            }
        }
    }
    // 알림을 띄우는 메서드
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment:"OK"), style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
