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
    }
    
    private func updateItems() {
        self.qrTypeCollectionView.reloadData()
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
