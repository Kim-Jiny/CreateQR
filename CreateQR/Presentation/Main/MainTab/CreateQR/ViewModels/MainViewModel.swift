//
//  MainViewModel.swift
//  CreateQR
//
//  Created by 김미진 on 10/8/24.
//

import Foundation
import AVFoundation
import UIKit
import CoreImage.CIFilterBuiltins

/// QR error-correction level. Higher levels tolerate more damage/occlusion
/// (needed when a logo is overlaid) at the cost of denser codes.
enum QRCorrectionLevel: String {
    case low = "L"       // ~7%
    case medium = "M"    // ~15%
    case quartile = "Q"  // ~25%
    case high = "H"      // ~30%
}

protocol QRCodeImageGenerating {
    func generate(
        from string: String,
        color: UIColor,
        backgroundColor: UIColor,
        logo: UIImage?,
        logoStyle: LogoStyle
    ) -> UIImage?
}

struct QRCodeImageGenerator: QRCodeImageGenerating {
    private let context = CIContext()

    func generate(
        from string: String,
        color: UIColor,
        backgroundColor: UIColor,
        logo: UIImage?,
        logoStyle: LogoStyle
    ) -> UIImage? {
        // A logo occludes the center, so bump correction to High when one is present.
        let correctionLevel: QRCorrectionLevel = logo == nil ? .quartile : .high
        return generate(
            from: string,
            color: color,
            backgroundColor: backgroundColor,
            logo: logo,
            logoStyle: logoStyle,
            correctionLevel: correctionLevel
        )
    }

    func generate(
        from string: String,
        color: UIColor,
        backgroundColor: UIColor,
        logo: UIImage?,
        logoStyle: LogoStyle,
        correctionLevel: QRCorrectionLevel
    ) -> UIImage? {
        let qrFilter = CIFilter.qrCodeGenerator()
        qrFilter.message = Data(string.utf8)
        qrFilter.correctionLevel = correctionLevel.rawValue

        guard let qrImage = qrFilter.outputImage else {
            return nil
        }

        let colorFilter = CIFilter.falseColor()
        colorFilter.inputImage = qrImage
        colorFilter.color0 = CIColor(color: color)
        colorFilter.color1 = CIColor(color: backgroundColor)

        guard let coloredQRImage = colorFilter.outputImage else {
            return nil
        }

        let scaledQRImage = coloredQRImage.transformed(by: CGAffineTransform(scaleX: 10, y: 10))
        guard let qrUIImage = convertToUIImage(from: scaledQRImage) else {
            return nil
        }

        guard let logo else {
            return qrUIImage
        }

        switch logoStyle {
        case .circle:
            return overlayCircularLogo(on: qrUIImage, logo: logo)
        case .square:
            return overlayLogo(on: qrUIImage, logo: logo)
        }
    }

    private func convertToUIImage(from image: CIImage) -> UIImage? {
        guard let cgImage = context.createCGImage(image, from: image.extent) else { return nil }
        return UIImage(cgImage: cgImage)
    }

    private func overlayLogo(on qrImage: UIImage, logo: UIImage) -> UIImage? {
        let qrSize = qrImage.size
        let logoSize = CGSize(width: qrSize.width / 4, height: qrSize.height / 4)
        let logoOrigin = CGPoint(x: (qrSize.width - logoSize.width) / 2, y: (qrSize.height - logoSize.height) / 2)
        
        let renderer = UIGraphicsImageRenderer(size: qrSize)
        return renderer.image { _ in
            qrImage.draw(in: CGRect(origin: .zero, size: qrSize))
            logo.draw(in: CGRect(origin: logoOrigin, size: logoSize))
        }
    }

    private func overlayCircularLogo(on qrImage: UIImage, logo: UIImage) -> UIImage? {
        let qrSize = qrImage.size
        let logoSize = CGSize(width: qrSize.width / 4, height: qrSize.height / 4)
        let logoOrigin = CGPoint(x: (qrSize.width - logoSize.width) / 2, y: (qrSize.height - logoSize.height) / 2)
        
        let circularRenderer = UIGraphicsImageRenderer(size: logoSize)
        let circularLogo = circularRenderer.image { _ in
            UIBezierPath(ovalIn: CGRect(origin: .zero, size: logoSize)).addClip()
            logo.draw(in: CGRect(origin: .zero, size: logoSize))
        }
        
        let combinedRenderer = UIGraphicsImageRenderer(size: qrSize)
        return combinedRenderer.image { _ in
            qrImage.draw(in: CGRect(origin: .zero, size: qrSize))
            circularLogo.draw(in: CGRect(origin: logoOrigin, size: logoSize))
        }
    }
}

// Input 프로토콜: 뷰에서 호출되는 메서드들
protocol MainViewModelInput {
    func viewDidLoad()
    func downloadImage(image: UIImage, completion: @escaping (Result<Bool, Error>) -> Void)
    func openAppSettings()
    func checkCameraPermission()
    func checkPhotoLibraryOnlyAddPermission()
    func checkPhotoLibraryPermission()
    func startScanning(previewLayer: AVCaptureVideoPreviewLayer)
    func stopScanning()
    func addMyQR(_ item: QRItem?)
    func removeMyQR(_ item: QRItem)
    func saveMyQRList()
    func updateQRItem(_ item: QRItem)
    func fetchMyQRList()
    func togglePinned(_ item: QRItem)
    func loadLatestVersion(completion: @escaping (String?) -> Void)
    func generateQR(from string: String, color: UIColor, backgroundColor: UIColor, logo: UIImage?, logoStyle: LogoStyle) -> UIImage?
    // 폴더 정리
    func loadFolders()
    func addFolder(_ name: String)
    func renameFolder(_ old: String, to new: String)
    func deleteFolder(_ name: String)
    func moveItem(_ item: QRItem, toFolder folderName: String?)
    func itemCount(forFolder folderName: String?) -> Int
    // 스캔 기록
    func loadScanHistory()
    func addScanRecord(_ content: String)
    func deleteScanRecord(id: String)
    func clearScanHistory()
}

// Output 프로토콜: 뷰모델에서 뷰로 전달될 데이터들
protocol MainViewModelOutput {
    var typeItems: Observable<[QRTypeItemViewModel]> { get }
    var myQRItems: Observable<[QRItem]> { get }
    var scannedResult: Observable<String> { get }
    var cameraPermission: Observable<Bool?> { get }
    var photoLibraryPermission: Observable<Bool?> { get }
    var photoLibraryOnlyAddPermission: Observable<Bool?> { get }
    var createQRItem: Observable<QRItem?> { get }
    var folders: Observable<[String]> { get }
    var scanHistory: Observable<[ScanRecord]> { get }
}

// MainViewModel 타입: Input과 Output을 모두 결합한 타입
typealias MainViewModel = MainViewModelInput & MainViewModelOutput

// MARK: - MainViewModel 구현 (ViewModel)

final class DefaultMainViewModel: MainViewModel {
    
    // MARK: - Dependencies (필수 의존성들)
    private let permissionUseCase: PermissionUseCase
    private let getQRListUseCase: GetQRListUseCase
    private let qrScannerUseCase: QRScannerUseCase
    private let downloadImageUseCase: DownloadImageUseCase
    private let qrItemUseCase: QRItemUseCase
    private let fetchAppVersionUseCase: FetchAppVersionUseCase
    private let qrCodeImageGenerator: QRCodeImageGenerating
    private let mainQueue: DispatchQueueType
    
    private var listLoadTask: Cancellable? { willSet { listLoadTask?.cancel() } } // QR 항목 로딩을 위한 Cancellable 객체
    
    // MARK: - Output (출력 프로퍼티)
    let typeItems: Observable<[QRTypeItemViewModel]> = Observable([]) // QR 항목 뷰모델 리스트
    let myQRItems: Observable<[QRItem]> = Observable([]) // QR 항목 데이터
    let scannedResult: Observable<String> = Observable("") // 스캔된 결과
    let cameraPermission: Observable<Bool?> = Observable(nil) // 카메라 권한 상태
    let photoLibraryPermission: Observable<Bool?> = Observable(nil) // 사진 라이브러리 권한 상태
    let photoLibraryOnlyAddPermission: Observable<Bool?> = Observable(nil) // 사진 라이브러리 추가 권한 상태
    var createQRItem: Observable<QRItem?> = Observable(nil) // QR 이미지
    let folders: Observable<[String]> = Observable([]) // 사용자 폴더 목록
    let scanHistory: Observable<[ScanRecord]> = Observable([]) // 스캔 기록

    private let folderStore = FolderStore()
    private let scanHistoryStore = ScanHistoryStore()
    
    // MARK: - Init (초기화)
    init(
        permissionUseCase: PermissionUseCase,
        getQRListUseCase: GetQRListUseCase,
        qrScannerUseCase: QRScannerUseCase,
        downloadImageUseCase: DownloadImageUseCase,
        qrItemUseCase: QRItemUseCase,
        fetchAppVersionUseCase: FetchAppVersionUseCase,
        qrCodeImageGenerator: QRCodeImageGenerating = QRCodeImageGenerator(),
        mainQueue: DispatchQueueType = DispatchQueue.main
    ) {
        self.permissionUseCase = permissionUseCase
        self.getQRListUseCase = getQRListUseCase
        self.qrScannerUseCase = qrScannerUseCase
        self.downloadImageUseCase = downloadImageUseCase
        self.qrItemUseCase = qrItemUseCase
        self.fetchAppVersionUseCase = fetchAppVersionUseCase
        self.qrCodeImageGenerator = qrCodeImageGenerator
        self.mainQueue = mainQueue
    }

    // MARK: - Private Methods (비공개 메서드)

    // QR 항목 로딩
    private func load() {
        listLoadTask = getQRListUseCase.execute(
            completion: { [weak self] result in
                self?.mainQueue.async {
                    switch result {
                    case .success(let qrTypes):
                        self?.fetchList(qrTypes) // 항목을 성공적으로 가져온 경우
                    case .failure:
                        self?.typeItems.value = []
                    }
                }
            }
        )
    }
    
    // QR 항목 뷰모델로 변환하여 typeItems에 설정
    private func fetchList(_ qrTypes: [QRTypeItem]) {
        typeItems.value = qrTypes.map(QRTypeItemViewModel.init)
    }
    
    func addMyQR(_ item: QRItem?) {
        if let item = item {
            qrItemUseCase.addQRItem(item)
        }else {
            if let data = createQRItem.value {
                qrItemUseCase.addQRItem(data)
            }
        }
        fetchMyQRList()
    }
    
    func removeMyQR(_ item: QRItem) {
        qrItemUseCase.removeQRItem(item)
        fetchMyQRList()
    }
    
    func saveMyQRList() {
        qrItemUseCase.saveQRList(myQRItems.value)
    }
    
    // 저장된 내 QRList Fetch
    func fetchMyQRList() {
        myQRItems.value = orderedForDisplay(qrItemUseCase.getQRItems() ?? [])
    }
    
    func updateQRItem(_ item: QRItem) {
        if let index = myQRItems.value.firstIndex(where: { $0.id == item.id }) {
            myQRItems.value[index] = item // 기존 항목을 새로운 항목으로 업데이트
            qrItemUseCase.updateQRItem(item) // 저장소에서도 업데이트
            myQRItems.value = orderedForDisplay(myQRItems.value)
        }
    }

    func togglePinned(_ item: QRItem) {
        guard let index = myQRItems.value.firstIndex(where: { $0.id == item.id }) else { return }
        myQRItems.value[index].isPinned.toggle()
        let updatedItem = myQRItems.value[index]
        qrItemUseCase.updateQRItem(updatedItem)
        myQRItems.value = orderedForDisplay(myQRItems.value)
    }

    // MARK: - Folders (My QR 폴더 정리)

    /// Reloads the persisted folder list into `folders`.
    func loadFolders() {
        folders.value = folderStore.loadFolders()
    }

    func addFolder(_ name: String) {
        guard folderStore.addFolder(name) != nil else { return }
        loadFolders()
    }

    func renameFolder(_ old: String, to new: String) {
        guard let newName = folderStore.renameFolder(old, to: new) else { return }
        // Reassign every item currently in `old` to the new folder name.
        for item in myQRItems.value where item.folderName == old {
            var updated = item
            updated.folderName = newName
            updateQRItem(updated)
        }
        loadFolders()
    }

    /// Deletes a folder and moves its items back to Uncategorized.
    func deleteFolder(_ name: String) {
        folderStore.deleteFolder(name)
        for item in myQRItems.value where item.folderName == name {
            var updated = item
            updated.folderName = nil
            updateQRItem(updated)
        }
        loadFolders()
    }

    /// Moves a QR item into a folder (nil = Uncategorized).
    func moveItem(_ item: QRItem, toFolder folderName: String?) {
        var updated = item
        updated.folderName = folderName
        updateQRItem(updated)
    }

    /// Number of items in a folder (nil = Uncategorized, non-pinned).
    func itemCount(forFolder folderName: String?) -> Int {
        myQRItems.value.filter { $0.folderName == folderName }.count
    }

    // MARK: - Scan history

    func loadScanHistory() {
        scanHistory.value = scanHistoryStore.load()
    }

    func addScanRecord(_ content: String) {
        scanHistory.value = scanHistoryStore.add(content: content, at: TimestampProvider().getCurrentTimestamp())
    }

    func deleteScanRecord(id: String) {
        scanHistory.value = scanHistoryStore.delete(id: id)
    }

    func clearScanHistory() {
        scanHistoryStore.clear()
        scanHistory.value = []
    }
    
    // MARK: - Permissions Check (권한 확인)

    // 설정 화면으로 이동하는 메서드
    func openAppSettings() {
        permissionUseCase.openAppSettings()
    }
    
    // 사진 라이브러리 권한 확인
    func checkPhotoLibraryPermission() {
        permissionUseCase.checkPhotoLibraryPermission { [weak self] isPermission in
            self?.photoLibraryPermission.value = isPermission
        }
    }

    // 사진 라이브러리 추가 권한 확인
    func checkPhotoLibraryOnlyAddPermission() {
        permissionUseCase.checkPhotoLibraryAddOnlyPermission { [weak self] isPermission in
            self?.photoLibraryOnlyAddPermission.value = isPermission
        }
    }
    
    // 카메라 권한 확인
    func checkCameraPermission() {
        permissionUseCase.checkCameraPermission { [weak self] isPermission in
            self?.cameraPermission.value = isPermission
        }
    }

    // MARK: - Image Download (이미지 다운로드)
    
    // 이미지 다운로드 실행
    func downloadImage(image: UIImage, completion: @escaping (Result<Bool, Error>) -> Void) {
        downloadImageUseCase.execute(image: image) { result in
            completion(result)
        }
    }
   
    // MARK: - QR Scanning (QR 코드 스캔)

    // 카메라로 QR 코드 스캔 시작
    func startScanning(previewLayer: AVCaptureVideoPreviewLayer) {
        qrScannerUseCase.startScanning(previewLayer: previewLayer) { [weak self] result in
            self?.mainQueue.async {
                self?.scannedResult.value = result // 스캔된 결과 업데이트
            }
        }
    }

    // QR 코드 스캔 중지
    func stopScanning() {
        qrScannerUseCase.stopScanning()
    }
    
    // MARK: App Setting
    
    func loadLatestVersion(completion: @escaping (String?) -> Void) {
        fetchAppVersionUseCase.execute { [weak self] latestVersion in
            completion(latestVersion)
        }
    }
    
    // MARK: - Create QR
    
    func generateQR(from string: String, color: UIColor, backgroundColor: UIColor, logo: UIImage?, logoStyle: LogoStyle) -> UIImage? {
        qrCodeImageGenerator.generate(
            from: string,
            color: color,
            backgroundColor: backgroundColor,
            logo: logo,
            logoStyle: logoStyle
        )
    }

    private func orderedForDisplay(_ items: [QRItem]) -> [QRItem] {
        items.enumerated()
            .sorted { lhs, rhs in
                if lhs.element.isPinned != rhs.element.isPinned {
                    return lhs.element.isPinned && !rhs.element.isPinned
                }
                return lhs.offset < rhs.offset
            }
            .map(\.element)
    }
}

// MARK: - Input (뷰 이벤트 처리)

extension DefaultMainViewModel {
    
    // 뷰 로드 시 호출
    func viewDidLoad() {
        load()
    }
}
