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
    private let completionLock = NSLock()
    private var saveCompletions: [UUID: (Result<Bool, Error>) -> Void] = [:]

    func saveImage(_ image: UIImage, completion: @escaping (Result<Bool, Error>) -> Void) {
        let token = UUID()
        completionLock.lock()
        saveCompletions[token] = completion
        completionLock.unlock()

        let context = Unmanaged.passRetained(SaveContext(token: token)).toOpaque()
        UIImageWriteToSavedPhotosAlbum(
            image,
            self,
            #selector(imageSaveCompleted(_:didFinishSavingWithError:contextInfo:)),
            context
        )
    }
    
    @objc private func imageSaveCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeMutableRawPointer?) {
        guard let contextInfo else { return }
        let context = Unmanaged<SaveContext>.fromOpaque(contextInfo).takeRetainedValue()
        completionLock.lock()
        let completion = saveCompletions.removeValue(forKey: context.token)
        completionLock.unlock()

        if let error = error {
            completion?(.failure(error))
        } else {
            completion?(.success(true))
        }
    }
}

private final class SaveContext {
    let token: UUID

    init(token: UUID) {
        self.token = token
    }
}
