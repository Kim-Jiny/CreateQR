//
//  PermissionUseCaseProtocol.swift
//  CreateQR
//
//  Clean Architecture - UseCase Protocol
//

import Foundation

protocol PermissionUseCaseProtocol {
    func openAppSettings()
    func checkCameraPermission(completion: @escaping (Bool) -> Void)
    func checkPhotoLibraryAddOnlyPermission(completion: @escaping (Bool) -> Void)
    func checkPhotoLibraryPermission(completion: @escaping (Bool) -> Void)
}
