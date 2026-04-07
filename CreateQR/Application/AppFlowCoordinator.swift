//
//  AppFlowCoordinator.swift
//  CreateQR
//
//  Created by 김미진 on 10/8/24.
//

import Foundation
import UIKit

final class AppFlowCoordinator {

    private let navigationController: UINavigationController
    private let mainSceneDIContainer: MainSceneDIContainer
    
    init(
        navigationController: UINavigationController,
        diContainer: AppDIContainer = .shared
    ) {
        self.navigationController = navigationController
        self.mainSceneDIContainer = diContainer.makeMainSceneDIContainer()
    }

    func start() {
        let flow = makeMainCoordinator(navigationController: navigationController)
        flow.start()
    }
    
    func makeMainCoordinator(navigationController: UINavigationController) -> MainCoordinator {
        MainCoordinator(
            navigationController: navigationController,
            dependencies: mainSceneDIContainer
        )
    }
}
