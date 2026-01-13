//
//  BaseViewController.swift
//  CreateQR
//
//  Clean Architecture - Base ViewController
//

import UIKit

class BaseViewController: UIViewController {

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        bindViewModel()
    }

    // MARK: - Setup Methods (Override in subclasses)

    func setupUI() {
        // Override in subclass
    }

    func setupConstraints() {
        // Override in subclass
    }

    func bindViewModel() {
        // Override in subclass
    }
}
