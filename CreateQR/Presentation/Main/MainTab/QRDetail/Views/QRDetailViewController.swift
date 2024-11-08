//
//  QRDetailViewController.swift
//  CreateQR
//
//  Created by 김미진 on 10/11/24.
//

import UIKit

class QRDetailViewController: UIViewController, XibInstantiable {
    

    @IBOutlet weak var timeTitleLb: UILabel!
    @IBOutlet weak var trackStackView: UIStackView!
    @IBOutlet weak var startButton: UIButton!
    // MARK: - Lifecycle

    private var viewModel: QRDetailViewModel!
    
    static func create(with viewModel: QRDetailViewModel) -> QRDetailViewController {
        let view = QRDetailViewController.instantiateViewController()
        view.viewModel = viewModel
        return view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        bind(to: viewModel)
    }


    private func bind(to viewModel: QRDetailViewModel) {
        
    }
    
    // MARK: - Private
    
    private func setupViews() {
        title = viewModel.title
        view.accessibilityIdentifier = AccessibilityIdentifier.qrDetailsView
    }
    
}
