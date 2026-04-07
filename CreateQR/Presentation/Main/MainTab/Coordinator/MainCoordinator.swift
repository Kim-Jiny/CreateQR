//
//  MainCoordinator.swift
//  CreateQR
//
//  Created by 김미진 on 10/8/24.
//

import Foundation
import UIKit

protocol MainCoordinatorDependencies {
    func makeMainViewController() -> MainViewController
}


final class MainCoordinator {
    
    private weak var navigationController: UINavigationController?
    private let dependencies: MainCoordinatorDependencies
    
    init(navigationController: UINavigationController,
         dependencies: MainCoordinatorDependencies) {
        self.navigationController = navigationController
        self.dependencies = dependencies
    }
    
    func start() {
        let vc = dependencies.makeMainViewController()
        
        navigationController?.pushViewController(vc, animated: false)
    }
}
