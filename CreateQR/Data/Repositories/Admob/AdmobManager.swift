//
//  AdmobManager.swift
//  CreateQR
//
//  Created by 김미진 on 11/18/24.
//

import Foundation
import GoogleMobileAds
import AdSupport
import AppTrackingTransparency

class AdmobManager: NSObject {
    private let isFreeApp = true
    static let shared : AdmobManager = AdmobManager()
    
    func setATT(completion: @escaping (Bool) -> Void) {
        // ATT 권한 요청
        ATTrackingManager.requestTrackingAuthorization { status in
            switch status {
            case .authorized:
                print("사용자가 광고 추적을 허용했습니다.")
                completion(true)
                return
            case .denied:
                print("사용자가 광고 추적을 거부했습니다.")
            case .notDetermined:
                print("사용자가 아직 광고 추적 권한을 결정하지 않았습니다.")
            case .restricted:
                print("광고 추적 권한이 제한되었습니다.")
            @unknown default:
                print("알 수 없는 상태")
            }
            
            completion(false)
            return
        }
    }
    
    func setMainBanner(_ adView: UIView,_ sender: UIViewController,_ type: AdmobType) {
        guard isFreeApp else {
            if let _ = adView.superview as? UIStackView {
                adView.isHidden = true
            }else {
                adView.snp.updateConstraints {
                    $0.height.equalTo(0)
                }
            }
            return
        }
        var bannerView: GADBannerView
        let viewWidth = adView.frame.inset(by: adView.safeAreaInsets).width
        let adaptiveSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(viewWidth)
        bannerView = GADBannerView(adSize: adaptiveSize)
        adView.addSubview(bannerView)
        if let st = adView.superview as? UIStackView {
            adView.isHidden = false
            st.setCustomSpacing(10, after: adView)
        }else {
            adView.snp.updateConstraints {
                $0.height.equalTo(55)
            }
        }
        bannerView.snp.makeConstraints {
            $0.top.bottom.leading.trailing.equalToSuperview()
        }
        bannerView.delegate = self
#if DEBUG
        bannerView.adUnitID = AdmobConfig.Banner.testKey
#else
        switch type {
        case .main:
            bannerView.adUnitID = AdmobConfig.Banner.mainKey
        case .list:
            bannerView.adUnitID = AdmobConfig.Banner.listKey
        }
#endif
        bannerView.rootViewController = sender
        bannerView.load(GADRequest())
    }
    
    deinit {
        print("종료")
    }
}

extension AdmobManager : GADBannerViewDelegate {
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("bannerViewDidReceiveAd")
    }
    
    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        print("bannerView:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }
    
    func bannerViewDidRecordImpression(_ bannerView: GADBannerView) {
        print("bannerViewDidRecordImpression")
    }
    
    func bannerViewWillPresentScreen(_ bannerView: GADBannerView) {
        print("bannerViewWillPresentScreen")
    }
    
    func bannerViewWillDismissScreen(_ bannerView: GADBannerView) {
        print("bannerViewWillDIsmissScreen")
    }
    
    func bannerViewDidDismissScreen(_ bannerView: GADBannerView) {
        print("bannerViewDidDismissScreen")
    }
    
}
