//
//  ImageDownloadRepository.swift
//  CreateQR
//
//  Created by 김미진 on 11/11/24.
//

import Foundation
import UIKit

protocol ImageDownloadRepository {
    func saveImage(_ image: UIImage, completion: @escaping (Result<Bool, Error>) -> Void)
}

class ImageDownloadRepositoryImpl: NSObject, ImageDownloadRepository {
    func saveImage(_ image: UIImage, completion: @escaping (Result<Bool, Error>) -> Void) {
        print("이미지 저장 시도")
        
        // 이미지를 저장하려면 UIImageWriteToSavedPhotosAlbum에 메서드가 필요함
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(imageSaveCompleted(_:didFinishSavingWithError:contextInfo:)), nil)
        
        // 완료 콜백 호출
        completion(.success(true))
    }
    
    @objc private func imageSaveCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            print("이미지 저장 실패: \(error.localizedDescription)")
        } else {
            print("이미지가 성공적으로 저장되었습니다.")
        }
    }
}
