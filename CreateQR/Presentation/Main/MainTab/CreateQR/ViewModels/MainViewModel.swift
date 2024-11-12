//
//  ViewModel.swift
//  CreateQR
//
//  Created by 김미진 on 10/8/24.
//

import Foundation
import AVFoundation
import UIKit

struct MainViewModelActions {
    let showDetail: (QRTypeItem) -> Void
}

protocol MainViewModelInput {
    func viewDidLoad()
    func didSelectItem(at index: Int)
    func downloadImage(image: UIImage, completion: @escaping (Bool) -> Void)
    func checkCameraPermission()
    func checkPhotoLibraryOnlyAddPermission()
    func checkPhotoLibraryPermission()
    func startScanning(previewLayer: AVCaptureVideoPreviewLayer)
    func stopScanning()
}

protocol MainViewModelOutput {
    var items: Observable<[MainItemViewModel]> { get } /// Also we can calculate view model items on demand:  https://github.com/kudoleh/iOS-Clean-Architecture-MVVM/pull/10/files
//    var loading: Observable<MoviesListViewModelLoading?> { get }
    var error: Observable<String> { get }
    var scannedResult: Observable<String> { get }
    var cameraPermission: Observable<Bool?> { get }
    var photoLibraryPermission: Observable<Bool?> { get }
    var photoLibraryOnlyAddPermission: Observable<Bool?> { get }
    var qrImg: Observable<UIImage?> { get }
    var isEmpty: Bool { get }
    var screenTitle: String { get }
    var errorTitle: String { get }
}

typealias MainViewModel = MainViewModelInput & MainViewModelOutput

final class DefaultMainViewModel: MainViewModel {
    
    private let permissionUseCase: PermissionUseCase
    private let getQRListUseCase: GetQRListUseCase
    private let qrScannerUseCase: QRScannerUseCase
    private let downloadImageUseCase: DownloadImageUseCase
    private let actions: MainViewModelActions?
    private let mainQueue: DispatchQueueType
    
    private var List: [QRTypeItem] = []
    private var ListLoadTask: Cancellable? { willSet { ListLoadTask?.cancel() } }
    
    // MARK: - OUTPUT

    let items: Observable<[MainItemViewModel]> = Observable([])
//    let loading: Observable<MoviesListViewModelLoading?> = Observable(.none)
    let error: Observable<String> = Observable("")
    let scannedResult: Observable<String> = Observable("")
    let cameraPermission: Observable<Bool?> = Observable(nil)
    let photoLibraryPermission: Observable<Bool?> = Observable(nil)
    let photoLibraryOnlyAddPermission: Observable<Bool?> = Observable(nil)
    var qrImg: Observable<UIImage?> = Observable(nil)
    var isEmpty: Bool { return items.value.isEmpty }
    let screenTitle = NSLocalizedString(" List", comment: "")
    let errorTitle = NSLocalizedString("Error", comment: "")
    
    // MARK: - Init
    
    init(
        permissionUseCase: PermissionUseCase,
        getQRListUseCase: GetQRListUseCase,
        qrScannerUseCase: QRScannerUseCase,
        downloadImageUseCase: DownloadImageUseCase,
        actions: MainViewModelActions? = nil,
        mainQueue: DispatchQueueType = DispatchQueue.main
    ) {
        self.permissionUseCase = permissionUseCase
        self.getQRListUseCase = getQRListUseCase
        self.qrScannerUseCase = qrScannerUseCase
        self.downloadImageUseCase = downloadImageUseCase
        self.actions = actions
        self.mainQueue = mainQueue
    }

    // MARK: - Private
    
    private func load() {
        ListLoadTask = getQRListUseCase.execute(
            completion: { [weak self] result in
                self?.mainQueue.async {
                    switch result {
                    case .success(let courses):
                        self?.fetchList(courses)
                    case .failure(let error):
                        self?.handle(error: error)
                }
            }
        })
    }
    
    private func fetchList(_ courses: [QRTypeItem]) {
        items.value = courses.map(MainItemViewModel.init)
        List = courses
    }
    
    
    private func handle(error: Error) {
        self.error.value = NSLocalizedString("Failed get data", comment: "")
    }
    
    func checkPhotoLibraryPermission() {
        permissionUseCase.checkPhotoLibraryPermission {[weak self] isPermission in
            self?.photoLibraryPermission.value = isPermission
        }
    }
    
    //MARK: - Image Download
    
     func checkPhotoLibraryOnlyAddPermission() {
         permissionUseCase.checkPhotoLibraryAddOnlyPermission {[weak self] isPermission in
             self?.photoLibraryOnlyAddPermission.value = isPermission
         }
     }
    
    func downloadImage(image: UIImage, completion: @escaping (Bool) -> Void) {
        downloadImageUseCase.execute(image: image) { result in
            switch result {
            case .success(let success):
                completion(success)
            case .failure:
                completion(false)
            }
        }
    }
   
    //MARK: - QRScan
    func checkCameraPermission() {
        permissionUseCase.checkCameraPermission {[weak self] isPermission in
            self?.cameraPermission.value = isPermission
        }
    }

    func startScanning(previewLayer: AVCaptureVideoPreviewLayer) {
        qrScannerUseCase.startScanning(previewLayer: previewLayer) { [weak self] result in
            self?.mainQueue.async {
                self?.scannedResult.value = result
            }
        }
    }

    func stopScanning() {
        qrScannerUseCase.stopScanning()
    }
}

// MARK: - INPUT. View event methods

extension DefaultMainViewModel {
    
    func viewDidLoad() {
        load()
    }
    
    func didSelectItem(at index: Int) {
        actions?.showDetail(List[index])
    }
}
