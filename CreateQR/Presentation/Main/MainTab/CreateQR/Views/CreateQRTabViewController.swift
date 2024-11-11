//
//  CreateQRTabViewController.swift
//  CreateQR
//
//  Created by 김미진 on 10/8/24.
//

import UIKit

class CreateQRTabViewController: UIViewController, StoryboardInstantiable {
    var viewModel: MainViewModel?
    
    @IBOutlet weak var qrTypeCollectionView: UICollectionView!
    @IBOutlet weak var qrTypeView: UIView!
    
    private var isFirstSelectionDone = false
    var img : UIImage? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCV()
        if let viewModel = viewModel {
            bind(to: viewModel)
        }
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
        self.qrTypeCollectionView.delegate = self
        self.qrTypeCollectionView.dataSource = self
        
        qrTypeCollectionView.register(UINib(nibName: QRTypeCollectionViewCell.id, bundle: .main), forCellWithReuseIdentifier: QRTypeCollectionViewCell.id)
    }
    
    private func selecteTypeView(_ qrType: MainItemViewModel) {
        qrTypeView.subviews.forEach {
            $0.removeFromSuperview()
        }
        
        let typeView = qrType.typeView
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
        viewModel.items.observe(on: self) { [weak self] _ in self?.updateItems() }
        
        
        viewModel.photoLibraryOnlyAddPermission.observe(on: self) { [weak self] hasPermission in
            guard let hasPermission = hasPermission, let img = self?.img else { return }
            guard hasPermission else {
                self?.showPermissionAlert()
                return
            }
            
            UIImageWriteToSavedPhotosAlbum(img, self, #selector(self?.saveError), nil)
//            viewModel.downloadImage(image: img, completion: {
//                print(img)
//                print("is download complete? \($0)")
//                self?.img = nil
//            })
        }
        
    } 
    @objc func saveError(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            print("error: \(error.localizedDescription)")
        } else {
            print("Save completed!")
        }
    }
    
    private func updateItems() {
        self.qrTypeCollectionView.reloadData()
    }
    
    private func showPermissionAlert() {
        let alert = UIAlertController(title: "사진 접근 권한 필요",
                                      message: "사진을 저장하기 위해 사진 접근 권한이 필요합니다. 설정에서 권한을 변경해 주세요.",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}


extension CreateQRTabViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16) // 원하는 마진 설정
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel?.items.value.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: QRTypeCollectionViewCell.id, for: indexPath) as? QRTypeCollectionViewCell, let viewModel = viewModel else { return UICollectionViewCell() }
        cell.fill(with: viewModel.items.value[indexPath.row])
        return cell
    }
    
    
    // 셀이 선택되었을 때 호출
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as? QRTypeCollectionViewCell
        cell?.setSelectedAppearance(true) // 선택된 상태 테두리 설정
        if let viewModel = viewModel {
            selecteTypeView(viewModel.items.value[indexPath.row])
        }
    }

    // 셀이 선택 해제되었을 때 호출
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as? QRTypeCollectionViewCell
        cell?.setSelectedAppearance(false) // 선택 해제된 상태 테두리 제거
    }
}


extension CreateQRTabViewController: QRTypeDelegate {
    func saveImage(img: UIImage) {
        //TODO: - 권한을 먼저 체크 하고 다운로드 시도~
        self.img = img
        viewModel?.checkPhotoLibraryOnlyAddPermission()
    }
}
