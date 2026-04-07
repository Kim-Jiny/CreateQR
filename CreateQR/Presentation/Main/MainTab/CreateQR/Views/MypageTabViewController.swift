//
//  MypageTabViewController.swift
//  CreateQR
//
//  Created by 김미진 on 10/8/24.
//
import UIKit

// MypageTabViewController는 마이 페이지에서 QR 목록을 보여주는 역할을 함
class MypageTabViewController: UIViewController, StoryboardInstantiable {
    private enum QRSection: Int, CaseIterable {
        case pinned
        case regular

        var title: String {
            switch self {
            case .pinned:
                return NSLocalizedString("Pinned", comment: "Pinned")
            case .regular:
                return NSLocalizedString("Others", comment: "Others")
            }
        }
    }
    
    // MainViewModel과 연동하기 위한 뷰모델 속성
    var viewModel: MainViewModel?
    
    // QR 목록을 보여줄 테이블 뷰 아웃렛
    @IBOutlet weak var myQRTableView: UITableView!
    @IBOutlet weak var adView: UIView!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var emptyLB: UILabel!
    private var isKeyboardVisible = false
    @IBOutlet weak var adViewHeightConstraints: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupTableView()
        setupAdView()
        // 뷰모델이 설정되어 있으면 바인딩 설정
        if let viewModel = viewModel {
            bind(to: viewModel)
        }
        // 키보드 알림 설정
        setupKeyboardObservers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel?.fetchMyQRList()
    }
    
    private func setupView() {
        // 배경 색상 설정
        view.backgroundColor = .speedMain3
        emptyLB.text = NSLocalizedString("There are no saved QR's.\nPlease generate or scan a QR.", comment: "")
    }
    
    private func setupAdView() {
        AdmobManager.shared.setMainBanner(adView, self, .list)
    }
    
    // 테이블 뷰 초기 설정 및 등록 메서드
    private func setupTableView() {
        myQRTableView.dragInteractionEnabled = true
        myQRTableView.dragDelegate = self
        myQRTableView.dropDelegate = self
        myQRTableView.delegate = self
        myQRTableView.dataSource = self
        myQRTableView.register(UINib(nibName: MyQRTableViewCell.id, bundle: nil), forCellReuseIdentifier: MyQRTableViewCell.id)
        
    }
    
    // 뷰모델의 데이터와 뷰를 바인딩
    private func bind(to viewModel: MainViewModel) {
        viewModel.myQRItems.observe(on: self) { [weak self] _ in self?.updateItems() }
        
        // 사진 저장 권한을 확인한 후에만 이미지 다운로드 수행
        viewModel.photoLibraryOnlyAddPermission.observe(on: self) { [weak self] hasPermission in
            guard let hasPermission = hasPermission, let img = self?.getQRImageFromQRDetailView() else { return }
            guard hasPermission else {
                DispatchQueue.main.async {
                    self?.showPermissionAlert()
                }
                return
            }
            
            // 권한이 있을 경우 이미지 다운로드 후 완료 알림 표시
            viewModel.downloadImage(image: img) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(true):
                        self?.showSaveAlert()
                    case .success(false):
                        self?.showSaveFailureAlert()
                    case .failure:
                        self?.showSaveFailureAlert()
                    }
                }
            }
        }
    }
    
    // 테이블 뷰의 데이터를 업데이트
    private func updateItems() {
        emptyView.isHidden = viewModel?.myQRItems.value.count != 0
        myQRTableView.reloadData()
    }

    private func items(in section: QRSection) -> [QRItem] {
        let items = viewModel?.myQRItems.value ?? []
        switch section {
        case .pinned:
            return items.filter(\.isPinned)
        case .regular:
            return items.filter { !$0.isPinned }
        }
    }

    private func qrSection(at index: Int) -> QRSection? {
        QRSection(rawValue: index)
    }

    private func section(for item: QRItem) -> QRSection {
        item.isPinned ? .pinned : .regular
    }

    private func item(at indexPath: IndexPath) -> QRItem? {
        guard let section = qrSection(at: indexPath.section) else { return nil }
        let sectionItems = items(in: section)
        guard sectionItems.indices.contains(indexPath.row) else { return nil }
        return sectionItems[indexPath.row]
    }

    private func flatIndex(for indexPath: IndexPath) -> Int? {
        guard let item = item(at: indexPath) else { return nil }
        return viewModel?.myQRItems.value.firstIndex(where: { $0.id == item.id })
    }

    private func insertionFlatIndex(for indexPath: IndexPath) -> Int? {
        guard let section = qrSection(at: indexPath.section), let viewModel else { return nil }
        let allItems = viewModel.myQRItems.value
        let sectionItems = items(in: section)
        let safeRow = min(indexPath.row, sectionItems.count)

        if safeRow < sectionItems.count, let targetItem = item(at: IndexPath(row: safeRow, section: indexPath.section)) {
            return allItems.firstIndex(where: { $0.id == targetItem.id })
        }

        switch section {
        case .pinned:
            return allItems.firstIndex(where: { !$0.isPinned }) ?? allItems.count
        case .regular:
            return allItems.count
        }
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
            $0.top.bottom.leading.trailing.equalToSuperview()
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
        let alert = UIAlertController(title: NSLocalizedString("Download Complete", comment:"Download Complete"),
                                      message: NSLocalizedString("The QR image has been saved to the gallery.", comment:"The QR image has been saved to the gallery."),
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment:"OK"), style: .default))
        present(alert, animated: true)
    }

    private func showSaveFailureAlert() {
        let alert = UIAlertController(
            title: NSLocalizedString("Save Failed", comment: "Save Failed"),
            message: NSLocalizedString("The QR image could not be saved. Please try again.", comment: "The QR image could not be saved. Please try again."),
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default))
        present(alert, animated: true)
    }
    
    // 사진 접근 권한 요청 알림 표시 메서드
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
    

    // 키보드 등장 및 사라짐에 대한 알림 처리
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // 키보드가 나타날 때 호출
    @objc private func keyboardWillShow(_ notification: Notification) {
        // 키보드 높이 가져오기
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            let keyboardHeight = keyboardFrame.height
            let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval ?? 0.25
            
            isKeyboardVisible = true // 키보드 상태 업데이트
            // 필요한 UI 업데이트 수행
            
            for subview in view.subviews {
                if let qrDetailView = subview as? QRDetailView {
                    qrDetailView.snp.updateConstraints {
                        $0.bottom.equalToSuperview().inset(keyboardHeight)
                    }
                    UIView.animate(withDuration: duration) { [weak self] in
                        self?.view.layoutIfNeeded()
                    }
                    
                    return
                }
            }
        }
    }

    // 키보드가 사라질 때 호출
    @objc private func keyboardWillHide(_ notification: Notification) {
        isKeyboardVisible = false // 키보드 상태 업데이트
        let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval ?? 0.25
        for subview in view.subviews {
            if let qrDetailView = subview as? QRDetailView {
                qrDetailView.snp.updateConstraints {
                    $0.bottom.equalToSuperview()
                }
                UIView.animate(withDuration: duration) { [weak self] in
                    self?.view.layoutIfNeeded()
                }
                
                return
            }
        }
    }
}

// 테이블 뷰 데이터 소스 및 델리게이트 구현
extension MypageTabViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        QRSection.allCases.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let currentSection = qrSection(at: section) else { return 0 }
        return items(in: currentSection).count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MyQRTableViewCell.id, for: indexPath) as? MyQRTableViewCell,
              let item = item(at: indexPath) else {
            return UITableViewCell()
        }
        cell.fill(with: item)
        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let currentSection = qrSection(at: section), !items(in: currentSection).isEmpty else { return nil }
        return currentSection.title
    }
    
    // 테이블 셀 클릭 시 QR 상세 뷰를 표시
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let data = item(at: indexPath) {
            showQRDetailView(data)
        }
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let item = item(at: indexPath) else { return nil }

        let pinTitle = item.isPinned
            ? NSLocalizedString("Unpin", comment: "Unpin")
            : NSLocalizedString("Pin", comment: "Pin")

        let pinAction = UIContextualAction(style: .normal, title: pinTitle) { [weak self] _, _, completion in
            self?.viewModel?.togglePinned(item)
            completion(true)
        }
        pinAction.backgroundColor = item.isPinned ? .systemGray : .systemOrange

        let configuration = UISwipeActionsConfiguration(actions: [pinAction])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }
}

// 테이블 뷰 드래그 및 드롭 기능 구현
extension MypageTabViewController: UITableViewDragDelegate, UITableViewDropDelegate {

    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        guard let item = item(at: indexPath) else { return [] }
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
               sourceIndexPath.section == destinationIndexPath.section,
               let sourceFlatIndex = flatIndex(for: sourceIndexPath),
               let destinationFlatIndex = insertionFlatIndex(for: destinationIndexPath) {

                let sourceItem = viewModel.myQRItems.value.remove(at: sourceFlatIndex)
                let adjustedDestinationIndex = sourceFlatIndex < destinationFlatIndex
                    ? max(destinationFlatIndex - 1, 0)
                    : destinationFlatIndex
                let safeDestinationIndex = min(adjustedDestinationIndex, viewModel.myQRItems.value.count)
                viewModel.myQRItems.value.insert(sourceItem, at: safeDestinationIndex)

                updateItems()
            }
        }
        
        viewModel.saveMyQRList() // 변경된 순서를 저장
    }

    func tableView(_ tableView: UITableView, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: NSString.self)
    }

    func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
        if let destinationIndexPath,
           let draggedItem = session.localDragSession?.items.first?.localObject as? QRItem,
           let destinationSection = qrSection(at: destinationIndexPath.section),
           section(for: draggedItem) != destinationSection {
            return UITableViewDropProposal(operation: .cancel)
        }
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
    
    func removeData(_ data: QRItem) {
        self.viewModel?.removeMyQR(data)
        // QRDetailView가 있는지 확인하고, 있다면 제거
        if let qrDetailView = view.subviews.first(where: { $0 is QRDetailView }) {
            qrDetailView.removeFromSuperview()
        }
    }
    
    func readData(_ data: QRItem) {
        qrDataAlert(data.qrData)
    }
    
    func qrDataAlert(_ qrCode: String) {
        // 알림 또는 화면에 표시할 수도 있습니다.
        let alert = UIAlertController(title: NSLocalizedString("View QR Content", comment:"View QR Content"), message: qrCode, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment:"OK"), style: .default, handler: { _ in
            self.viewModel?.scannedResult.value = ""
        }))
        
        if let url = URL(string: qrCode), UIApplication.shared.canOpenURL(url) {
            alert.addAction(UIAlertAction(title: NSLocalizedString("Open in Safari", comment:"Open in Safari"), style: .default, handler: { _ in
                self.viewModel?.scannedResult.value = ""
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }))
        }
        present(alert, animated: true, completion: nil)
    }
}
