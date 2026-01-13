//
//  ImageDownloadUseCaseProtocol.swift
//  CreateQR
//
//  Clean Architecture - UseCase Protocol
//

import Foundation
import UIKit

protocol ImageDownloadUseCaseProtocol {
    func execute(image: UIImage, completion: @escaping (Result<Bool, Error>) -> Void)
}
