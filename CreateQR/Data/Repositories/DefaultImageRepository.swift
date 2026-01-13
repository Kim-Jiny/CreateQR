//
//  DefaultImageRepository.swift
//  CreateQR
//
//  Clean Architecture - Data Layer Repository Implementation
//

import Foundation
import UIKit

final class DefaultImageRepository: NSObject, ImageDownloadRepository {

    func saveImage(_ image: UIImage, completion: @escaping (Result<Bool, Error>) -> Void) {
        UIImageWriteToSavedPhotosAlbum(
            image,
            self,
            #selector(imageSaveCompleted(_:didFinishSavingWithError:contextInfo:)),
            nil
        )
        completion(.success(true))
    }

    @objc private func imageSaveCompleted(
        _ image: UIImage,
        didFinishSavingWithError error: Error?,
        contextInfo: UnsafeRawPointer
    ) {
        if let error = error {
            print("이미지 저장 실패: \(error.localizedDescription)")
        } else {
            print("이미지가 성공적으로 저장되었습니다.")
        }
    }
}
