//
//  StoryboardInstantiable.swift
//  CreateQR
//
//  Created by 김미진 on 10/8/24.
//

import Foundation
import UIKit

protocol StoryboardInstantiable: NSObjectProtocol {
    associatedtype T
    static var defaultFileName: String { get }
    // 파일 이름으로 뷰 컨트롤러를 인스턴스화하는 메서드
    static func instantiateViewController(_ bundle: Bundle?) -> T
    // 스토리보드 ID로 뷰 컨트롤러를 인스턴스화하는 메서드
    static func instantiateViewController(from storyboard: UIStoryboard) -> T
}

extension StoryboardInstantiable where Self: UIViewController {
    static var defaultFileName: String {
        return NSStringFromClass(Self.self).components(separatedBy: ".").last!
    }
    
    static func instantiateViewController(_ bundle: Bundle? = nil) -> Self {
        let fileName = defaultFileName
        let storyboard = UIStoryboard(name: fileName, bundle: bundle)
        guard let vc = storyboard.instantiateInitialViewController() as? Self else {
            
            fatalError("Cannot instantiate initial view controller \(Self.self) from storyboard with name \(fileName)")
        }
        return vc
    }
    
    static func instantiateViewController(from storyboard: UIStoryboard) -> Self {
        guard let vc = storyboard.instantiateViewController(withIdentifier: defaultFileName) as? Self else {
            fatalError("Cannot instantiate view controller \(Self.self) with identifier \(defaultFileName) from storyboard \(storyboard)")
        }
        return vc
    }
}
