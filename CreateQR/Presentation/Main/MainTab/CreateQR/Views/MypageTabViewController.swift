//
//  MypageTabViewController.swift
//  CreateQR
//
//  Created by 김미진 on 10/8/24.
//
import UIKit

// MypageTabViewController는 마이 페이지에서 QR 목록을 보여주는 역할을 함
class MypageTabViewController: UIViewController, StoryboardInstantiable {
    
    // MainViewModel과 연동하기 위한 뷰모델 속성
    var viewModel: MainViewModel?
    
    // QR 목록을 보여줄 테이블 뷰 아웃렛
    @IBOutlet weak var myQRTableView: UITableView!
    @IBOutlet weak var emptyView: UIView!
    private var isKeyboardVisible = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        
        // 뷰모델이 설정되어 있으면 바인딩 설정
        if let viewModel = viewModel {
            bind(to: viewModel)
        }
        // 키보드 알림 설정
        setupKeyboardObservers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        viewModel?.fetchMyQRList()
    }
    
    // 테이블 뷰 초기 설정 및 등록 메서드
    private func setupTableView() {
        myQRTableView.dragInteractionEnabled = true
        myQRTableView.dragDelegate = self
        myQRTableView.dropDelegate = self
        myQRTableView.delegate = self
        myQRTableView.dataSource = self
        myQRTableView.register(UINib(nibName: MyQRTableViewCell.id, bundle: nil), forCellReuseIdentifier: MyQRTableViewCell.id)
        
        // 배경 색상 설정
        view.backgroundColor = .speedMain3
    }
    
    // 뷰모델의 데이터와 뷰를 바인딩
    private func bind(to viewModel: MainViewModel) {
        viewModel.myQRItems.observe(on: self) { [weak self] _ in self?.updateItems() }
        
        // 사진 저장 권한을 확인한 후에만 이미지 다운로드 수행
        viewModel.photoLibraryOnlyAddPermission.observe(on: self) { [weak self] hasPermission in
            guard let hasPermission = hasPermission, let img = self?.getQRImageFromQRDetailView() else { return }
            guard hasPermission else {
                self?.showPermissionAlert()
                return
            }
            
            // 권한이 있을 경우 이미지 다운로드 후 완료 알림 표시
            viewModel.downloadImage(image: img) { [weak self] _ in
                self?.showSaveAlert()
            }
        }
    }
    
    // 테이블 뷰의 데이터를 업데이트
    private func updateItems() {
        emptyView.isHidden = viewModel?.myQRItems.value.count != 0
        myQRTableView.reloadData()
    }
    
    // QR 상세 뷰를 추가하고 이미 있는 경우 추가하지 않음
    private func showQRDetailView(_ data: QRItem) {
        if view.subviews.contains(where: { $0 is QRDetailView }) {
            print("QRDetailView already exists.")
            return
        }
        
        // QRDetailView 생성 후 데이터 설정 및 추가
        let qrDetailView = QRDetailView()
        qrDetailView.fill(with: data)
        qrDetailView.delegate = self
        view.addSubview(qrDetailView)
        
        // QRDetailView 전체화면에 추가
        qrDetailView.snp.makeConstraints {
            $0.top.bottom.leading.trailing.equalTo(myQRTableView)
        }
    }
    
    // QRDetailView의 QR 이미지를 가져오는 메서드
    func getQRImageFromQRDetailView() -> UIImage? {
        for subview in view.subviews {
            if let qrDetailView = subview as? QRDetailView {
                return qrDetailView.qrImg.image
            }
        }
        return nil
    }
    
    // 저장 완료 알림 표시 메서드
    private func showSaveAlert() {
        let alert = UIAlertController(title: "다운로드 완료",
                                      message: "QR 이미지를 갤러리에 저장했습니다.",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // 사진 접근 권한 요청 알림 표시 메서드
    private func showPermissionAlert() {
        let alert = UIAlertController(title: "사진 접근 권한 필요",
                                      message: "사진을 저장하기 위해 사진 접근 권한이 필요합니다. 설정에서 권한을 변경해 주세요.",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "설정으로 이동", style: .default, handler: { [weak self] _ in
            self?.viewModel?.openAppSettings()
        }))
        present(alert, animated: true)
    }
    

    // 키보드 등장 및 사라짐에 대한 알림 처리
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    // 키보드가 나타날 때 호출
    @objc private func keyboardWillShow(_ notification: Notification) {
        // 키보드 높이 가져오기
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            let keyboardHeight = keyboardFrame.height
            
            // 필요한 UI 업데이트 수행
            self.myQRTableView.snp.updateConstraints {
                $0.bottom.equalToSuperview().inset(keyboardHeight)
            }
            UIView.animate(withDuration: 5) { [weak self] in
                self?.view.layoutIfNeeded()
            }
        }
        isKeyboardVisible = true // 키보드 상태 업데이트
    }

    // 키보드가 사라질 때 호출
    @objc private func keyboardWillHide(_ notification: Notification) {
        self.myQRTableView.snp.updateConstraints {
            $0.bottom.equalToSuperview()
        }
        isKeyboardVisible = false // 키보드 상태 업데이트
        UIView.animate(withDuration: 5) { [weak self] in
            self?.view.layoutIfNeeded()
        }
    }
}

// 테이블 뷰 데이터 소스 및 델리게이트 구현
extension MypageTabViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.myQRItems.value.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MyQRTableViewCell.id, for: indexPath) as? MyQRTableViewCell, let viewModel = viewModel else {
            return UITableViewCell()
        }
        cell.fill(with: viewModel.myQRItems.value[indexPath.row])
        return cell
    }
    
    // 테이블 셀 클릭 시 QR 상세 뷰를 표시
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let data = viewModel?.myQRItems.value[indexPath.row] {
            showQRDetailView(data)
        }
    }
}

// 테이블 뷰 드래그 및 드롭 기능 구현
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

                // 데이터 소스 배열에서 항목의 위치 변경
                let sourceItem = viewModel.myQRItems.value.remove(at: sourceIndexPath.row)
                viewModel.myQRItems.value.insert(sourceItem, at: destinationIndexPath.row)

                // 테이블 뷰 업데이트
                updateItems()
            }
        }
        
        viewModel.saveMyQRList() // 변경된 순서를 저장
    }

    func tableView(_ tableView: UITableView, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: NSString.self)
    }

    func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
        return tableView.hasActiveDrag ? UITableViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath) : UITableViewDropProposal(operation: .forbidden)
    }
}

// QRDetailView에서 이미지를 저장하기 위한 델리게이트 구현
extension MypageTabViewController: QRDetailDelegate {
    func saveImage() {
        viewModel?.checkPhotoLibraryOnlyAddPermission()
    }
    
    func shareImage() {
        guard let qrImage = self.getQRImageFromQRDetailView() else {
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
    
    func backTab() {
        if isKeyboardVisible {
            view.endEditing(true) // 키보드가 올라와 있으면 내리기
        } else {
            // QRDetailView가 있는지 확인하고, 있다면 제거
            if let qrDetailView = view.subviews.first(where: { $0 is QRDetailView }) {
                qrDetailView.removeFromSuperview()
            }
        }
    }
    
    func changeQRData(_ data: QRItem) {
        self.viewModel?.updateQRItem(data)
    }
}
