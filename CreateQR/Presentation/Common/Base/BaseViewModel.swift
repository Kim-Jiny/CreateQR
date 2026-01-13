//
//  BaseViewModel.swift
//  CreateQR
//
//  Clean Architecture - Base ViewModel
//

import Foundation

class BaseViewModel {

    // MARK: - Properties

    private var disposeBag: [Any] = []

    // MARK: - Lifecycle

    deinit {
        disposeBag.removeAll()
    }
}
