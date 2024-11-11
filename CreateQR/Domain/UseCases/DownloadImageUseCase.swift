//
//  DownloadImageUseCase.swift
//  CreateQR
//
//  Created by 김미진 on 11/11/24.
//

import Foundation
import UIKit
class DownloadImageUseCase {
    private let repository: ImageDownloadRepository

    init(repository: ImageDownloadRepository) {
        self.repository = repository
    }

    func execute(image: UIImage, completion: @escaping (Result<Bool, Error>) -> Void) {
        repository.saveImage(image) { result in
            completion(result)
        }
    }
}
