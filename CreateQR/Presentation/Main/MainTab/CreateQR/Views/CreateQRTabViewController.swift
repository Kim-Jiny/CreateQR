//
//  CreateQRTabViewController.swift
//  CreateQR
//
//  Created by 김미진 on 10/8/24.
//

import UIKit
import GoogleMobileAds

class CreateQRTabViewController: UIViewController, StoryboardInstantiable {
    var viewModel: MainViewModel?
    
    @IBOutlet weak var mainStackView: UIStackView!
    @IBOutlet weak var adView: UIView!
    @IBOutlet weak var qrTypeCollectionView: UICollectionView!
    @IBOutlet weak var qrTypeView: UIView!
    
    var typeView: CreateQRTypeView? = nil
    private var isFirstSelectionDone = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCV()
        if let viewModel = viewModel {
            bind(to: viewModel)
        }
        setupAdView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard !isFirstSelectionDone && qrTypeCollectionView.numberOfItems(inSection: 0) > 0 else { return }
        let firstIndexPath = IndexPath(item: 0, section: 0)
        qrTypeCollectionView.selectItem(at: firstIndexPath, animated: false, scrollPosition: .top)
        qrTypeCollectionView.delegate?.collectionView?(qrTypeCollectionView, didSelectItemAt: firstIndexPath)
        isFirstSelectionDone = true
    }
    
    private func setupCV() {
        self.navigationController?.navigationBar.isHidden = true
        self.qrTypeCollectionView.delegate = self
        self.qrTypeCollectionView.dataSource = self
        
        qrTypeCollectionView.register(UINib(nibName: QRTypeCollectionViewCell.id, bundle: .main), forCellWithReuseIdentifier: QRTypeCollectionViewCell.id)
    }
    
    private func setupAdView() {
        AdmobManager.shared.setMainBanner(adView, self, .main)
    }
     
    private func selecteTypeView(_ qrType: QRTypeItemViewModel) {
        qrTypeView.subviews.forEach {
            $0.removeFromSuperview()
        }
        
        typeView = getTypeClass(qrType.qrType)
        guard let typeView = self.typeView else { return }
        typeView.delegate = self
        qrTypeView.addSubview(typeView)
        print(qrTypeView.subviews)
        typeView.snp.makeConstraints {
            $0.top.bottom.leading.trailing.equalToSuperview()
        }
        
        typeView.layoutIfNeeded()
        typeView.roundTopCorners(cornerRadius: 30)
        typeView.backgroundColor = .speedMain3
    }
    
    private func bind(to viewModel: MainViewModel) {
        viewModel.typeItems.observe(on: self) { [weak self] _ in self?.updateItems() }
        
        
        viewModel.photoLibraryOnlyAddPermission.observe(on: self) { [weak self] hasPermission in
            guard let hasPermission = hasPermission, let imgData = self?.viewModel?.createQRItem.value?.qrImageData, let img = UIImage(data: imgData) else { return }
            guard hasPermission else {
                DispatchQueue.main.async {
                    self?.showPermissionAlert()
                }
                return
            }
            
            viewModel.downloadImage(image: img, completion: {
                print("is download complete? \($0)")
                DispatchQueue.main.async {
                    self?.showSaveAlert()
                }
            })
        }
        
    }
    
    private func updateItems() {
        self.qrTypeCollectionView.reloadData()
    }
    
    private func showSaveAlert() {
        let alert = UIAlertController(title: NSLocalizedString("Download Complete", comment: "Download Complete"),
                                      message: NSLocalizedString("The QR image has been saved to the gallery.", comment: "The QR image has been saved to the gallery."),
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment:"OK"), style: .default) {_ in
            self.typeView?.imageSaveCompleted()
        })
        present(alert, animated: true)
    }
    
    private func showPermissionAlert() {
        let alert = UIAlertController(title: NSLocalizedString("Photo Access Permission Required", comment:"Photo Access Permission Required"),
                                      message: NSLocalizedString("Photo access permission is required to save the photo. Please change the permission in Settings.", comment:"Photo access permission is required to save the photo. Please change the permission in Settings."),
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment:"Cancel"), style: .cancel))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Go to Settings", comment:"Go to Settings"), style: .default, handler: { [weak self] _ in
            self?.viewModel?.openAppSettings()
        }))
        present(alert, animated: true)
    }
    
    func getTypeClass(_ type: CreateType) -> CreateQRTypeView {
        switch type {
        case .url:
            return CreateQRURLType()
        case .card:
            return CreateQRCardType()
        case .other:
            return CreateQRCardType()
        }
    }
}


extension CreateQRTabViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16) // 원하는 마진 설정
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel?.typeItems.value.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: QRTypeCollectionViewCell.id, for: indexPath) as? QRTypeCollectionViewCell, let viewModel = viewModel else { return UICollectionViewCell() }
        cell.fill(with: viewModel.typeItems.value[indexPath.row])
        return cell
    }
    
    
    // 셀이 선택되었을 때 호출
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as? QRTypeCollectionViewCell
        cell?.setSelectedAppearance(true) // 선택된 상태 테두리 설정
        if let viewModel = viewModel {
            selecteTypeView(viewModel.typeItems.value[indexPath.row])
        }
    }

    // 셀이 선택 해제되었을 때 호출
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as? QRTypeCollectionViewCell
        cell?.setSelectedAppearance(false) // 선택 해제된 상태 테두리 제거
    }
}


extension CreateQRTabViewController: QRTypeDelegate {
    func shareImage() {
        
        guard let imageData = self.viewModel?.createQRItem.value?.qrImageData, let qrImage = UIImage(data: imageData) else {
            print("공유할 이미지가 없습니다.")
            return
        }
        
        let activityViewController = UIActivityViewController(activityItems: [qrImage], applicationActivities: nil)
        
        // iPad에서의 팝오버 설정 (iPad에서는 이 설정이 없으면 앱이 충돌할 수 있음)
        if let popoverController = activityViewController.popoverPresentationController {
            popoverController.sourceView = self.view // 공유 버튼이 있는 뷰를 기준으로 팝오버 표시
        }
        
        present(activityViewController, animated: true, completion: nil)
    }
    
    func saveImage() {
        // TODO: - 권한을 체크하기전에 앱에 저장할지 디바이스 이미지로 저장할지를 선택하는 액션시트 구현
        let actionSheet = UIAlertController(title: nil, message: NSLocalizedString("Choose how to save the QR.", comment:"Choose how to save the QR."), preferredStyle: .actionSheet)
        
        let option1 = UIAlertAction(title: NSLocalizedString("Save QR Image to Gallery", comment:"Save QR Image to Gallery"), style: .default) { action in
            self.viewModel?.checkPhotoLibraryOnlyAddPermission()
        }
        let option2 = UIAlertAction(title: NSLocalizedString("Save to My QR", comment:"Save to My QR"), style: .default) { action in
            self.viewModel?.addMyQR(nil)
            self.typeView?.imageSaveCompleted()
            // TODO: - 저장완료된 이펙트 개발필요
        }
        let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment:"Cancel"), style: .cancel) { action in
            self.typeView?.imageSaveCompleted()
        }
        
        actionSheet.addAction(option1)
        actionSheet.addAction(option2)
        actionSheet.addAction(cancel)
        
        // iPad에서 Action Sheet가 팝오버로 나타나도록 설정 (iPad에서는 필수)
        if let popoverController = actionSheet.popoverPresentationController {
            popoverController.sourceView = self.view // 액션시트가 나타날 뷰 설정
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 1, height: 1) // 팝오버의 위치를 화면 중앙으로 설정
            popoverController.permittedArrowDirections = [] // 화살표 방향을 없애는 설정 (선택 사항)
        }
        
        present(actionSheet, animated: true, completion: nil)
    }
    
    func generateQR(url: String) -> UIImage? {
        let qrImg = self.viewModel?.generateQR(from: url, color: .black, backgroundColor: .white, logo: nil)
        let item = QRItem(title: NSLocalizedString("Untitled", comment:"Untitled"), qrImageData: qrImg?.pngData(), qrType: .url, qrData: url)
        
        viewModel?.createQRItem.value = item
        return qrImg
    }
}
