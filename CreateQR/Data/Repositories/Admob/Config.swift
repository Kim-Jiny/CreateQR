//
//  Config.swift
//  CreateQR
//
//  Created by 김미진 on 11/18/24.
//

import Foundation
import GoogleMobileAds
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

class AdmobManager: NSObject {
    private let isFreeApp = true
    static let shared : AdmobManager = AdmobManager()
    
    func setMainBanner(_ adView: UIView,_ sender: UIViewController,_ type: AdmobType) {
        adView.backgroundColor = .red // FOR Test
        guard isFreeApp else {
            if let st = adView.superview as? UIStackView {
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
        switch type {
        case .main:
            bannerView.adUnitID = AdmobConfig.Banner.testKey
        case .list:
            bannerView.adUnitID = AdmobConfig.Banner.testKey
        }
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
