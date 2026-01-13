//
//  AppCoordinator.swift
//  CreateQR
//
//  Clean Architecture - App Flow Coordinator
//

import Foundation
import UIKit

protocol Coordinator: AnyObject {
    var navigationController: UINavigationController { get set }
    func start()
}

final class AppCoordinator: Coordinator {

    var navigationController: UINavigationController
    private let diContainer: AppDIContainer

    init(
        navigationController: UINavigationController,
        diContainer: AppDIContainer = .shared
    ) {
        self.navigationController = navigationController
        self.diContainer = diContainer
    }

    func start() {
        let mainSceneDIContainer = diContainer.makeMainSceneDIContainer()
        let mainCoordinator = MainCoordinator(
            navigationController: navigationController,
            dependencies: mainSceneDIContainer
        )
        mainCoordinator.start()
    }
}
