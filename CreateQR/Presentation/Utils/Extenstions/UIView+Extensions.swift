//
//  UIView+Extensions.swift
//  CreateQR
//
//  Created by 김미진 on 11/8/24.
//

import Foundation
import UIKit

extension UIView {
    func roundTopCorners(cornerRadius: CGFloat) {
        let maskPath = UIBezierPath(
            roundedRect: self.bounds,
            byRoundingCorners: [.topLeft, .topRight], // 위쪽 두 모서리만 둥글게
            cornerRadii: CGSize(width: cornerRadius, height: cornerRadius)
        )
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = maskPath.cgPath
        self.layer.mask = shapeLayer
    }
}
