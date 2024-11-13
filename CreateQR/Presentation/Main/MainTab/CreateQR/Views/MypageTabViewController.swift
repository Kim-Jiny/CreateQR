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
//        self.myQRTableView.dragInteractionEnabled = true
//        self.myQRTableView.dragDelegate = self
//        self.myQRTableView.dropDelegate = self
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
}

//extension MypageTabViewController: UITableViewDragDelegate, UITableViewDropDelegate {
//    
//    // 드래그가 시작될 때 호출
//    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
//        guard let item = viewModel?.myQRItems.value[indexPath.row] else { return [] }
//        let itemProvider = NSItemProvider(object: item as NSString)
//        let dragItem = UIDragItem(itemProvider: itemProvider)
//        dragItem.localObject = item
//        return [dragItem]
//    }
//    
//    // 드롭할 때 호출
//    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
//        guard let destinationIndexPath = coordinator.destinationIndexPath else { return }
//        
//        for item in coordinator.items {
//            if let sourceIndexPath = item.sourceIndexPath,
//               let draggedItem = item.dragItem.localObject as? String {
//                // ViewModel의 데이터 업데이트
//                viewModel?.myQRItems.value.remove(at: sourceIndexPath.row)
//                viewModel?.myQRItems.value.insert(draggedItem, at: destinationIndexPath.row)
//                
//                // 테이블 뷰 업데이트
//                tableView.performBatchUpdates({
//                    tableView.deleteRows(at: [sourceIndexPath], with: .automatic)
//                    tableView.insertRows(at: [destinationIndexPath], with: .automatic)
//                }, completion: nil)
//                
//                coordinator.drop(item.dragItem, toRowAt: destinationIndexPath)
//            }
//        }
//    }
//    
//    // 드래그할 셀의 스타일을 커스터마이즈할 수 있음
//    func tableView(_ tableView: UITableView, dragPreviewParametersForRowAt indexPath: IndexPath) -> UIDragPreviewParameters? {
//        let parameters = UIDragPreviewParameters()
//        parameters.backgroundColor = .clear
//        return parameters
//    }
//}
