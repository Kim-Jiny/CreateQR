//
//  AppFlowCoordinator.swift
//  CreateQR
//
//  Created by 김미진 on 10/8/24.
//

import Foundation
import UIKit

final class AppFlowCoordinator {

    var navigationController: UINavigationController
    
    init(
        navigationController: UINavigationController
    ) {
        self.navigationController = navigationController
    }

    func start() {
        let flow = makeMainCoordinator(navigationController: navigationController)
        flow.start()
    }
    
    func makeMainCoordinator(navigationController: UINavigationController) -> MainCoordinator {
        MainCoordinator(navigationController: navigationController, dependencies: self)
    }
}

extension AppFlowCoordinator: MainCoordinatorDependencies {
    
    func makeMainViewController(actions: MainViewModelActions) -> MainViewController {
        MainViewController.create(with: makeMainViewModel(actions: actions))
    }
    
    func makeMainViewModel(actions: MainViewModelActions) -> MainViewModel {
        DefaultMainViewModel(
            getQRListUseCase: makeGetQRListUseCase(),
            actions: actions
        )
    }
    
    func makeQRDetailsViewController(qr: QRTypeItem) -> QRDetailViewController {
        QRDetailViewController.create(with: makeMoviesDetailsViewModel(qr: qr))
    }
    
    
    func makeMoviesDetailsViewModel(qr: QRTypeItem) -> QRDetailViewModel {
        DefaultQRDetailViewModel(course: qr)
    }
    
    
    // MARK: - Use Cases
    func makeGetQRListUseCase() -> GetQRListUseCase {
        DefaultGetQRListUseCase(qrListRepository: makeQRListRepository())
    }
    
    // MARK: - Repositories
    private func makeQRListRepository() -> QRListRepository {
        DefaultRQListRepository()
    }
}
