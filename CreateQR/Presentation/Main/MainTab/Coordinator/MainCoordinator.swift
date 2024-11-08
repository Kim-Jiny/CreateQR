//
//  MainCoordinator.swift
//  CreateQR
//
//  Created by 김미진 on 10/8/24.
//

import Foundation
import UIKit

protocol MainCoordinatorDependencies {
    func makeMainViewController(actions: MainViewModelActions) -> MainViewController
    func makeQRDetailsViewController(qr: QRTypeItem) -> QRDetailViewController
}


final class MainCoordinator {
    
    private weak var navigationController: UINavigationController?
    private let dependencies: MainCoordinatorDependencies
    
    private weak var mainVC: MainViewController?
    
    init(navigationController: UINavigationController,
         dependencies: MainCoordinatorDependencies) {
        self.navigationController = navigationController
        self.dependencies = dependencies
    }
    
    func start() {
        // Note: here we keep strong reference with actions, this way this flow do not need to be strong referenced
        let actions = MainViewModelActions(showDetail: showQRDetails)
        let vc = dependencies.makeMainViewController(actions: actions)
        
        navigationController?.pushViewController(vc, animated: false)
        mainVC = vc
    }
    
    private func showQRDetails(course: QRTypeItem) {
        let vc = dependencies.makeQRDetailsViewController(qr: course)
        navigationController?.pushViewController(vc, animated: true)
    }
    
}
