//
//  AppDIContainer.swift
//  CreateQR
//
//  Clean Architecture - Dependency Injection Container
//

import Foundation

final class AppDIContainer {

    // MARK: - Shared Instance

    static let shared = AppDIContainer()

    private init() {}

    // MARK: - Data Sources

    lazy var cameraPermissionDataSource: CameraPermissionDataSource = {
        CameraPermissionDataSource()
    }()

    lazy var photoLibraryPermissionDataSource: PhotoLibraryPermissionDataSource = {
        PhotoLibraryPermissionDataSource()
    }()

    // MARK: - Repositories

    lazy var permissionRepository: PermissionRepository = {
        PermissionRepositoryImpl(
            cameraPermissionDataSource: cameraPermissionDataSource,
            photoLibraryPermissionDataSource: photoLibraryPermissionDataSource
        )
    }()

    lazy var qrListRepository: QRListRepository = {
        DefaultRQListRepository()
    }()

    lazy var qrScannerRepository: QRScannerRepository = {
        QRScannerRepositoryImpl()
    }()

    lazy var imageDownloadRepository: ImageDownloadRepository = {
        ImageDownloadRepositoryImpl()
    }()

    lazy var qrItemRepository: QRItemRepository = {
        QRItemRepository()
    }()

    lazy var appVersionRepository: AppVersionRepository = {
        DefaultAppVersionRepository()
    }()

    // MARK: - Use Cases

    func makePermissionUseCase() -> PermissionUseCase {
        PermissionUseCaseImpl(repository: permissionRepository)
    }

    func makeGetQRListUseCase() -> GetQRListUseCase {
        DefaultGetQRListUseCase(qrListRepository: qrListRepository)
    }

    func makeQRScannerUseCase() -> QRScannerUseCase {
        QRScannerUseCaseImpl(repository: qrScannerRepository)
    }

    func makeDownloadImageUseCase() -> DownloadImageUseCase {
        DownloadImageUseCase(repository: imageDownloadRepository)
    }

    func makeQRItemUseCase() -> QRItemUseCase {
        QRItemUseCase(repository: qrItemRepository)
    }

    func makeFetchAppVersionUseCase() -> FetchAppVersionUseCase {
        DefaultFetchAppVersionUseCase(repository: appVersionRepository)
    }

    // MARK: - Scene DIContainers

    func makeMainSceneDIContainer() -> MainSceneDIContainer {
        MainSceneDIContainer(appDIContainer: self)
    }
}

// MARK: - Main Scene DI Container

final class MainSceneDIContainer {

    private let appDIContainer: AppDIContainer

    init(appDIContainer: AppDIContainer) {
        self.appDIContainer = appDIContainer
    }

    // MARK: - View Models

    func makeMainViewModel() -> MainViewModel {
        DefaultMainViewModel(
            permissionUseCase: appDIContainer.makePermissionUseCase(),
            getQRListUseCase: appDIContainer.makeGetQRListUseCase(),
            qrScannerUseCase: appDIContainer.makeQRScannerUseCase(),
            downloadImageUseCase: appDIContainer.makeDownloadImageUseCase(),
            qrItemUseCase: appDIContainer.makeQRItemUseCase(),
            fetchAppVersionUseCase: appDIContainer.makeFetchAppVersionUseCase()
        )
    }

    func makeQRDetailViewModel(qrData: QRItem) -> QRDetailViewModel {
        DefaultQRDetailViewModel(qrData: qrData)
    }

    // MARK: - View Controllers

    func makeMainViewController() -> MainViewController {
        MainViewController.create(with: makeMainViewModel())
    }

    func makeQRDetailViewController(qr: QRItem) -> QRDetailViewController {
        QRDetailViewController.create(with: makeQRDetailViewModel(qrData: qr))
    }
}

extension MainSceneDIContainer: MainCoordinatorDependencies {}
