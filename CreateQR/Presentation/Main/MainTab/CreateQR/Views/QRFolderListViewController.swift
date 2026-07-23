//
//  QRFolderListViewController.swift
//  CreateQR
//
//  Drill-down folder list — the root screen of the My QR tab.
//  Shows Pinned, each user folder, and Uncategorized; tapping drills into
//  a filtered MypageTabViewController.
//

import UIKit

final class QRFolderListViewController: UIViewController {

    var viewModel: MainViewModel?

    private enum Row {
        case pinned
        case folder(String)
        case uncategorized
    }

    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let cellID = "FolderCell"

    private var rows: [Row] {
        let folders = viewModel?.folders.value ?? []
        return [.pinned] + folders.map { Row.folder($0) } + [.uncategorized]
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("My QR", comment: "My QR")
        view.backgroundColor = .speedMain3
        setupTableView()
        setupAddButton()

        if let viewModel {
            viewModel.myQRItems.observe(on: self) { [weak self] _ in self?.tableView.reloadData() }
            viewModel.folders.observe(on: self) { [weak self] _ in self?.tableView.reloadData() }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel?.loadFolders()
        viewModel?.fetchMyQRList()
        tableView.reloadData()
    }

    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .clear
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        view.addSubview(tableView)
        tableView.snp.makeConstraints { $0.edges.equalTo(view.safeAreaLayoutGuide) }
    }

    private func setupAddButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addFolderTapped)
        )
    }

    @objc private func addFolderTapped() {
        promptFolderName(title: NSLocalizedString("New Folder", comment: "New Folder")) { [weak self] name in
            self?.viewModel?.addFolder(name)
        }
    }

    private func promptFolderName(title: String, initial: String? = nil, completion: @escaping (String) -> Void) {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        alert.addTextField {
            $0.placeholder = NSLocalizedString("Folder name", comment: "Folder name")
            $0.text = initial
            $0.autocapitalizationType = .words
        }
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .cancel))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Save", comment: "Save"), style: .default) { _ in
            let name = alert.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            guard !name.isEmpty else { return }
            completion(name)
        })
        present(alert, animated: true)
    }

    private func pushContents(filter: FolderFilter, title: String) {
        let vc = MypageTabViewController.instantiateViewController(from: UIStoryboard(name: "MainViewController", bundle: nil))
        vc.viewModel = viewModel
        vc.folderFilter = filter
        vc.title = title
        navigationController?.pushViewController(vc, animated: true)
    }

    private func count(for row: Row) -> Int {
        guard let viewModel else { return 0 }
        switch row {
        case .pinned: return viewModel.myQRItems.value.filter(\.isPinned).count
        case .folder(let name): return viewModel.itemCount(forFolder: name)
        case .uncategorized: return viewModel.itemCount(forFolder: nil)
        }
    }
}

extension QRFolderListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        rows.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        let row = rows[indexPath.row]
        var config = cell.defaultContentConfiguration()

        switch row {
        case .pinned:
            config.text = NSLocalizedString("Pinned", comment: "Pinned")
            config.image = UIImage(systemName: "pin.fill")
        case .folder(let name):
            config.text = name
            config.image = UIImage(systemName: "folder.fill")
        case .uncategorized:
            config.text = NSLocalizedString("Uncategorized", comment: "Uncategorized")
            config.image = UIImage(systemName: "tray")
        }
        config.secondaryText = "\(count(for: row))"
        config.prefersSideBySideTextAndSecondaryText = true
        config.imageProperties.tintColor = .speedMain0
        cell.contentConfiguration = config
        cell.accessoryType = .disclosureIndicator
        cell.backgroundColor = .speedMain4
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch rows[indexPath.row] {
        case .pinned:
            pushContents(filter: .pinned, title: NSLocalizedString("Pinned", comment: "Pinned"))
        case .folder(let name):
            pushContents(filter: .folder(name), title: name)
        case .uncategorized:
            pushContents(filter: .uncategorized, title: NSLocalizedString("Uncategorized", comment: "Uncategorized"))
        }
    }

    // Rename / delete only for user folders.
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard case let .folder(name) = rows[indexPath.row] else { return nil }

        let rename = UIContextualAction(style: .normal, title: NSLocalizedString("Rename", comment: "Rename")) { [weak self] _, _, done in
            self?.promptFolderName(title: NSLocalizedString("Rename Folder", comment: "Rename Folder"), initial: name) { newName in
                self?.viewModel?.renameFolder(name, to: newName)
            }
            done(true)
        }
        rename.backgroundColor = .speedMain0

        let delete = UIContextualAction(style: .destructive, title: NSLocalizedString("Delete", comment: "Delete")) { [weak self] _, _, done in
            self?.confirmDeleteFolder(name)
            done(true)
        }

        return UISwipeActionsConfiguration(actions: [delete, rename])
    }

    private func confirmDeleteFolder(_ name: String) {
        let alert = UIAlertController(
            title: NSLocalizedString("Delete Folder", comment: "Delete Folder"),
            message: NSLocalizedString("Items in this folder will move to Uncategorized.", comment: ""),
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .cancel))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Delete", comment: "Delete"), style: .destructive) { [weak self] _ in
            self?.viewModel?.deleteFolder(name)
        })
        present(alert, animated: true)
    }
}
