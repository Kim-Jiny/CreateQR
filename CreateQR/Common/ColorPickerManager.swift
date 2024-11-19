//
//  ColorPickerManager.swift
//  CreateQR
//
//  Created by 김미진 on 11/18/24.
//

import Foundation
import UIKit

class ColorPickerManager: NSObject, UIColorPickerViewControllerDelegate {
    
    var completion: ((UIColor?) -> Void)? = nil
    
    deinit {
        print("ColorPickerManager deinit")
    }
    
    func showColorPicker(_ sender: UIViewController, completion: @escaping (UIColor?) -> Void ) {
        self.completion = completion
        // UIColorPickerViewController 인스턴스 생성
        let colorPicker = UIColorPickerViewController()
        
        // 현재 색상을 선택하도록 설정 (기본값은 흰색)
        colorPicker.selectedColor = .white
        
        // 컬러 피커의 delegate 설정
        colorPicker.delegate = self
        
        // 컬러 피커 표시
        sender.present(colorPicker, animated: true, completion: nil)
    }
    
    // 색상 선택 후 호출되는 델리게이트 메서드
    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        // 선택된 색상 받아오기
        let selectedColor = viewController.selectedColor
        // 선택된 색상을 사용 (예: 배경색 변경)
        if let completion = completion {
            completion(selectedColor)
        }
        completion = nil
    }

    // 사용자가 취소했을 때 호출되는 델리게이트 메서드
    func colorPickerViewControllerDidCancel(_ viewController: UIColorPickerViewController) {
        print("컬러 피커에서 취소했습니다.")
        if let completion = completion {
            completion(nil)
        }
    }
}
