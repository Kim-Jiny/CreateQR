//
//  PermissionRepositoryProtocol.swift
//  CreateQR
//
//  Clean Architecture - Repository Interface (Domain Layer)
//

import Foundation

protocol PermissionRepositoryProtocol {
    func requestCameraPermission(completion: @escaping (Bool) -> Void)
    func requestPhotoLibraryAddOnlyPermission(completion: @escaping (Bool) -> Void)
    func requestPhotoLibraryPermission(completion: @escaping (Bool) -> Void)
}
