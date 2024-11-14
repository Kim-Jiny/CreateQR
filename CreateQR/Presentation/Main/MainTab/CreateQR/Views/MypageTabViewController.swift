//
//  MypageTabViewController.swift
//  CreateQR
//
//  Created by 김미진 on 10/8/24.
//
import UIKit

class MypageTabViewController: UIViewController, StoryboardInstantiable {
    
    var viewModel: MainViewModel?
    
    @IBOutlet weak var myQRTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCV()
        if let viewModel = viewModel {
            bind(to: viewModel)
        }
    }
    
    private func setupCV() {
        self.myQRTableView.dragInteractionEnabled = true
        self.myQRTableView.dragDelegate = self
        self.myQRTableView.dropDelegate = self
        self.myQRTableView.delegate = self
        self.myQRTableView.dataSource = self
        
        self.myQRTableView.register(UINib(nibName: MyQRTableViewCell.id, bundle: nil), forCellReuseIdentifier: MyQRTableViewCell.id)
        self.view.backgroundColor = .speedMain3
    }
    
    private func bind(to viewModel: MainViewModel) {
        viewModel.myQRItems.observe(on: self) { [weak self] _ in self?.updateItems() }
    }
    
    private func updateItems() {
        self.myQRTableView.reloadData()
    }
    
    private func showQRDetailView(_ data: QRItem) {
        // 이미 QRDetailView가 있는지 확인
        if view.subviews.contains(where: { $0 is QRDetailView }) {
            print("QRDetailView already exists.")
            return
        }
        
        // QRDetailView가 없으므로 새로 추가
        let qrDetailView = QRDetailView()
        qrDetailView.fill(with: data)
        view.addSubview(qrDetailView)
        
        // 레이아웃 설정
        qrDetailView.snp.makeConstraints {
            $0.top.bottom.leading.trailing.equalToSuperview()
        }
    }
}

extension MypageTabViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.myQRItems.value.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MyQRTableViewCell.id, for: indexPath) as? MyQRTableViewCell , let viewModel = viewModel else {
            return UITableViewCell()
        }
        cell.fill(with: viewModel.myQRItems.value[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let data = viewModel?.myQRItems.value[indexPath.row] {
            showQRDetailView(data)
        }
    }
}

extension MypageTabViewController: UITableViewDragDelegate, UITableViewDropDelegate {

    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        guard let viewModel = viewModel else { return [] }
        let item = viewModel.myQRItems.value[indexPath.row]
        let itemProvider = NSItemProvider(object: item.id as NSString)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = item
        return [dragItem]
    }
    
    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
        guard let viewModel = viewModel else { return }
        guard let destinationIndexPath = coordinator.destinationIndexPath else { return }

        for item in coordinator.items {
            if let sourceIndexPath = item.sourceIndexPath,
               let qrItem = item.dragItem.localObject as? QRItem {

                // 데이터 소스 배열에서 항목의 위치를 변경합니다.
                let sourceItem = viewModel.myQRItems.value.remove(at: sourceIndexPath.row)
                viewModel.myQRItems.value.insert(sourceItem, at: destinationIndexPath.row)

                // 테이블 뷰를 업데이트하여 항목의 순서를 반영합니다.
                tableView.moveRow(at: sourceIndexPath, to: destinationIndexPath)
            }
        }
        
        self.viewModel?.saveMyQRList()
    }

    func tableView(_ tableView: UITableView, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: NSString.self)
    }

    func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
        if tableView.hasActiveDrag {
            return UITableViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
        } else {
            return UITableViewDropProposal(operation: .forbidden)
        }
    }
}
