//
//  CreateQRTypeView.swift
//  CreateQR
//
//  Created by 김미진 on 11/8/24.
//

import Foundation
import UIKit

class CreateQRTypeView: UIView {

    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
//        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
//        commonInit()
    }
    
    // MARK: - XIB 로드 및 설정
    
    private func commonInit() {
        // XIB 로드
        let nib = UINib(nibName: String(describing: CreateQRURLType.self), bundle: Bundle(for: type(of: self)))
        guard let loadedView = nib.instantiate(withOwner: self, options: nil).first as? UIView else {
            return
        }
        
        // XIB에서 로드된 뷰를 현재 뷰에 추가
        loadedView.frame = self.bounds
        loadedView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(loadedView)
    }
}
