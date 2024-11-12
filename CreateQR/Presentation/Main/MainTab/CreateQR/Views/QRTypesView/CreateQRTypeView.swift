//
//  CreateQRTypeView.swift
//  CreateQR
//
//  Created by 김미진 on 11/8/24.
//

import Foundation
import UIKit

protocol QRTypeDelegate: AnyObject {
    func createQR(img: UIImage)
    func saveImage()
}

class CreateQRTypeView: UIView {
    weak var delegate: QRTypeDelegate?
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    // MARK: - XIB 로드 및 설정
    
    func commonInit() {
        // XIB 로드
        let nib = UINib(nibName: String(describing: Self.self), bundle: Bundle(for: type(of: self)))
        guard let loadedView = nib.instantiate(withOwner: self, options: nil).first as? UIView else {
            return
        }
        
        // XIB에서 로드된 뷰를 현재 뷰에 추가
        loadedView.frame = self.bounds
        loadedView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(loadedView)
        setupUI()
    }
    
    func setupUI() {
        
    }
    
    func imageSaveCompleted() {
        
    }
}
