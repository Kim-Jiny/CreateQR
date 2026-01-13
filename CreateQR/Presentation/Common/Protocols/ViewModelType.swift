//
//  ViewModelType.swift
//  CreateQR
//
//  Clean Architecture - ViewModel Protocol
//

import Foundation

protocol ViewModelType {
    associatedtype Input
    associatedtype Output

    func transform(input: Input) -> Output
}
