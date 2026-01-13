//
//  MainCoordinator.swift
//  CreateQR
//
//  Clean Architecture - Main Scene Coordinator
//

import Foundation
import UIKit

protocol MainCoordinatorDependencies {
    func makeMainViewController(actions: MainViewModelActions) -> MainViewController
    func makeQRDetailViewController(qr: QRItem) -> QRDetailViewController
}

final class MainCoordinator: Coordinator {

    var navigationController: UINavigationController
    private let dependencies: MainCoordinatorDependencies

    private weak var mainVC: MainViewController?

    init(
        navigationController: UINavigationController,
        dependencies: MainCoordinatorDependencies
    ) {
        self.navigationController = navigationController
        self.dependencies = dependencies
    }

    func start() {
        let actions = MainViewModelActions(showDetail: showQRDetails)
        let vc = dependencies.makeMainViewController(actions: actions)

        navigationController.pushViewController(vc, animated: false)
        mainVC = vc
    }

    private func showQRDetails(qr: QRItem) {
        let vc = dependencies.makeQRDetailViewController(qr: qr)
        navigationController.pushViewController(vc, animated: true)
    }
}

// MARK: - MainSceneDIContainer Extension

extension MainSceneDIContainer: MainCoordinatorDependencies {}
