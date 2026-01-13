//
//  ImageRepositoryProtocol.swift
//  CreateQR
//
//  Clean Architecture - Repository Interface (Domain Layer)
//

import Foundation
import UIKit

protocol ImageDownloadRepositoryProtocol {
    func saveImage(_ image: UIImage, completion: @escaping (Result<Bool, Error>) -> Void)
}
