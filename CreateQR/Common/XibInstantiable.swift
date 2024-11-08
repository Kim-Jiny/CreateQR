//
//  XibInstantiable.swift
//  CreateQR
//
//  Created by 김미진 on 10/8/24.
//

import Foundation
import UIKit

protocol XibInstantiable: NSObjectProtocol {
    associatedtype T
    static var defaultFileName: String { get }
    static func instantiateViewController(_ bundle: Bundle?) -> T
}

extension XibInstantiable where Self: UIViewController {
    static var defaultFileName: String {
        return NSStringFromClass(Self.self).components(separatedBy: ".").last!
    }
    
    static func instantiateViewController(_ bundle: Bundle? = nil) -> Self {
        let fileName = defaultFileName
           return Self(nibName: fileName, bundle: bundle)
    }
    
//    static func instantiateViewController(_ bundle: Bundle? = nil) -> Self {
//        let fileName = defaultFileName
//        let nib = UINib(nibName: fileName, bundle: bundle)
//        guard let view = nib.instantiate(withOwner: self, options: nil).first as? UIView else {
//            fatalError("Cannot instantiate view from xib file with name \(fileName)")
//        }
//        
//        let viewController = Self() // UIViewController의 인스턴스를 생성
//        viewController.view = view // xib에서 가져온 UIView를 viewController의 view로 설정
//        
//        return viewController
//    }
}
