//
//  MainViewModel.swift
//  CreateQR
//
//  Created by 김미진 on 10/8/24.
//

import Foundation
import AVFoundation
import UIKit

// MARK: - Actions (ViewModel에서 호출될 액션 정의)
struct MainViewModelActions {
    let showDetail: (QRItem) -> Void // QR 항목 세부 사항을 보여주는 액션
}

// MARK: - MainViewModel의 Input, Output 정의

// Input 프로토콜: 뷰에서 호출되는 메서드들
protocol MainViewModelInput {
    func viewDidLoad()
    func didSelectItem(at index: Int)
    func downloadImage(image: UIImage, completion: @escaping (Bool) -> Void)
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
    func loadLatestVersion(completion: @escaping (String?) -> Void)
    func generateQR(from string: String, color: UIColor, backgroundColor: UIColor, logo: UIImage?, logoStyle: LogoStyle) -> UIImage?
}

// Output 프로토콜: 뷰모델에서 뷰로 전달될 데이터들
protocol MainViewModelOutput {
    var typeItems: Observable<[QRTypeItemViewModel]> { get }
    var myQRItems: Observable<[QRItem]> { get }
    var error: Observable<String> { get }
    var scannedResult: Observable<String> { get }
    var cameraPermission: Observable<Bool?> { get }
    var photoLibraryPermission: Observable<Bool?> { get }
    var photoLibraryOnlyAddPermission: Observable<Bool?> { get }
    var createQRItem: Observable<QRItem?> { get }
    var selectedQRColor: Observable<UIColor?> { get }
    var selectedBackColor: Observable<UIColor?> { get }
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
    private let actions: MainViewModelActions?
    private let mainQueue: DispatchQueueType
    
    private var ListLoadTask: Cancellable? { willSet { ListLoadTask?.cancel() } } // QR 항목 로딩을 위한 Cancellable 객체
    
    // MARK: - Output (출력 프로퍼티)
    let typeItems: Observable<[QRTypeItemViewModel]> = Observable([]) // QR 항목 뷰모델 리스트
    let myQRItems: Observable<[QRItem]> = Observable([]) // QR 항목 데이터
    let error: Observable<String> = Observable("") // 오류 메시지
    let scannedResult: Observable<String> = Observable("") // 스캔된 결과
    let cameraPermission: Observable<Bool?> = Observable(nil) // 카메라 권한 상태
    let photoLibraryPermission: Observable<Bool?> = Observable(nil) // 사진 라이브러리 권한 상태
    let photoLibraryOnlyAddPermission: Observable<Bool?> = Observable(nil) // 사진 라이브러리 추가 권한 상태
    var createQRItem: Observable<QRItem?> = Observable(nil) // QR 이미지
    var selectedQRColor: Observable<UIColor?> = Observable(nil) // QR 컬러
    var selectedBackColor: Observable<UIColor?> = Observable(nil) // QR 컬러
    
    // MARK: - Init (초기화)
    init(
        permissionUseCase: PermissionUseCase,
        getQRListUseCase: GetQRListUseCase,
        qrScannerUseCase: QRScannerUseCase,
        downloadImageUseCase: DownloadImageUseCase,
        qrItemUseCase: QRItemUseCase,
        fetchAppVersionUseCase: FetchAppVersionUseCase,
        actions: MainViewModelActions? = nil,
        mainQueue: DispatchQueueType = DispatchQueue.main
    ) {
        self.permissionUseCase = permissionUseCase
        self.getQRListUseCase = getQRListUseCase
        self.qrScannerUseCase = qrScannerUseCase
        self.downloadImageUseCase = downloadImageUseCase
        self.qrItemUseCase = qrItemUseCase
        self.fetchAppVersionUseCase = fetchAppVersionUseCase
        self.actions = actions
        self.mainQueue = mainQueue
    }

    // MARK: - Private Methods (비공개 메서드)

    // QR 항목 로딩
    private func load() {
        ListLoadTask = getQRListUseCase.execute(
            completion: { [weak self] result in
                self?.mainQueue.async {
                    switch result {
                    case .success(let qrTypes):
                        self?.fetchList(qrTypes) // 항목을 성공적으로 가져온 경우
                    case .failure(let error):
                        self?.handle(error: error) // 실패 시 오류 처리
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
        myQRItems.value = qrItemUseCase.getQRItems() ?? []
    }
    
    func updateQRItem(_ item: QRItem) {
        if let index = myQRItems.value.firstIndex(where: { $0.id == item.id }) {
            myQRItems.value[index] = item // 기존 항목을 새로운 항목으로 업데이트
            qrItemUseCase.updateQRItem(item) // 저장소에서도 업데이트
        }
    }
    
    // 오류 처리
    private func handle(error: Error) {
        
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
    func downloadImage(image: UIImage, completion: @escaping (Bool) -> Void) {
        downloadImageUseCase.execute(image: image) { result in
            switch result {
            case .success(let success):
                completion(success) // 성공 시 완료 핸들러 호출
            case .failure:
                completion(false) // 실패 시 완료 핸들러 호출
            }
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
    
    // QR 코드 생성 함수 (색상 변경 및 커스텀 이미지 추가 포함)
    func generateQR(from string: String, color: UIColor, backgroundColor: UIColor, logo: UIImage?, logoStyle: LogoStyle) -> UIImage? {
        // QR 코드 문자열을 CIImage로 변환
        let data = string.data(using: .utf8)
        
        guard let filter = CIFilter(name: "CIQRCodeGenerator") else {
            return nil
        }
        
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue("Q", forKey: "inputCorrectionLevel")
        
        guard let qrImage = filter.outputImage else {
            return nil
        }
        
        // 색상 변경을 위한 필터 적용
        let colorFilter = CIFilter(name: "CIFalseColor")
        colorFilter?.setValue(qrImage, forKey: kCIInputImageKey)
        colorFilter?.setValue(CIColor(color: color), forKey: "inputColor0")
        colorFilter?.setValue(CIColor(color: backgroundColor), forKey: "inputColor1")
        
        guard let coloredQRImage = colorFilter?.outputImage else {
            return nil
        }
        
        // 이미지를 표시할 크기로 스케일 조정
        let transform = CGAffineTransform(scaleX: 10, y: 10)
        let scaledQRImage = coloredQRImage.transformed(by: transform)
        
        // UIImage로 변환
        let qrUIImage = convert(scaledQRImage)
        
        // 로고가 있는 경우 QR 코드 중앙에 추가
        if let qrUIImage = qrUIImage, let logo = logo {
            switch logoStyle {
            case .circle:
                return overlayCircularLogo(on: qrUIImage, logo: logo)
            case .square:
                return overlayLogo(on: qrUIImage, logo: logo)
            }
        }
        
        func convert(_ cmage:CIImage) -> UIImage? {
            let context:CIContext = CIContext(options: nil)
            guard let cgImage:CGImage = context.createCGImage(cmage, from: cmage.extent) else { return nil }
            let image:UIImage = UIImage(cgImage: cgImage)
            return image
        }
        
        return qrUIImage
    }

    // QR 코드 위에 로고를 추가하는 함수
    private func overlayLogo(on qrImage: UIImage, logo: UIImage) -> UIImage? {
        let qrSize = qrImage.size
        let logoSize = CGSize(width: qrSize.width / 4, height: qrSize.height / 4) // 로고 크기 조정
        let logoOrigin = CGPoint(x: (qrSize.width - logoSize.width) / 2, y: (qrSize.height - logoSize.height) / 2)
        
        // UIGraphicsImageRenderer로 고해상도 이미지 렌더링
        let renderer = UIGraphicsImageRenderer(size: qrSize)
        let combinedImage = renderer.image { context in
            // QR 코드 그리기
            qrImage.draw(in: CGRect(origin: .zero, size: qrSize))
            
            // 로고 그리기
            logo.draw(in: CGRect(origin: logoOrigin, size: logoSize))
        }
        
        return combinedImage
    }
    
    //QR 코드 위에 원형 로고를 추가 하는 함수
    private func overlayCircularLogo(on qrImage: UIImage, logo: UIImage) -> UIImage? {
        let qrSize = qrImage.size
        let logoSize = CGSize(width: qrSize.width / 4, height: qrSize.height / 4) // 로고 크기 조정
        let logoOrigin = CGPoint(x: (qrSize.width - logoSize.width) / 2, y: (qrSize.height - logoSize.height) / 2)
        
        // 원형 마스크 만들기
        let renderer = UIGraphicsImageRenderer(size: logoSize)
        let circularLogo = renderer.image { context in
            // 원형 마스크를 그린다.
            let path = UIBezierPath(ovalIn: CGRect(origin: .zero, size: logoSize))
            path.addClip()
            
            // 원형 마스크로 로고 그리기
            logo.draw(in: CGRect(origin: .zero, size: logoSize))
        }
        
        // 고해상도 컨텍스트로 QR 코드와 원형 로고를 결합
        let combinedRenderer = UIGraphicsImageRenderer(size: qrSize)
        let combinedImage = combinedRenderer.image { context in
            // QR 코드 그리기
            qrImage.draw(in: CGRect(origin: .zero, size: qrSize))
            
            // 원형 로고 그리기
            circularLogo.draw(in: CGRect(origin: logoOrigin, size: logoSize))
        }
        
        return combinedImage
    }
}

// MARK: - Input (뷰 이벤트 처리)

extension DefaultMainViewModel {
    
    // 뷰 로드 시 호출
    func viewDidLoad() {
        load()
    }
    
    // 항목 선택 시 호출
    func didSelectItem(at index: Int) {
        actions?.showDetail(myQRItems.value[index]) // 선택된 항목에 대한 세부 정보 표시
    }
}
