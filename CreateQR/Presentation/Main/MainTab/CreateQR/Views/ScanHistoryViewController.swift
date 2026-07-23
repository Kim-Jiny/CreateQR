//
//  ScanHistoryViewController.swift
//  CreateQR
//
//  Shows the automatically-saved history of scanned QR contents.
//

import UIKit

final class ScanHistoryViewController: UIViewController {

    var viewModel: MainViewModel?

    private let tableView = UITableView(frame: .zero, style: .plain)
    private let cellID = "ScanHistoryCell"

    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("No scan history yet.", comment: "")
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        return f
    }()

    private var records: [ScanRecord] { viewModel?.scanHistory.value ?? [] }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("Scan History", comment: "Scan History")
        view.backgroundColor = .speedMain3
        setupTableView()
        setupClearButton()

        viewModel?.scanHistory.observe(on: self) { [weak self] _ in self?.reload() }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel?.loadScanHistory()
        reload()
    }

    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .clear
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        tableView.tableFooterView = UIView()
        view.addSubview(tableView)
        view.addSubview(emptyLabel)
        tableView.snp.makeConstraints { $0.edges.equalTo(view.safeAreaLayoutGuide) }
        emptyLabel.snp.makeConstraints {
            $0.center.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview().inset(32)
        }
    }

    private func setupClearButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: NSLocalizedString("Clear", comment: "Clear"),
            style: .plain,
            target: self,
            action: #selector(clearTapped)
        )
    }

    private func reload() {
        emptyLabel.isHidden = !records.isEmpty
        navigationItem.rightBarButtonItem?.isEnabled = !records.isEmpty
        tableView.reloadData()
    }

    @objc private func clearTapped() {
        guard !records.isEmpty else { return }
        let alert = UIAlertController(
            title: NSLocalizedString("Clear Scan History", comment: ""),
            message: NSLocalizedString("All scan history will be deleted.", comment: ""),
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .cancel))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Delete", comment: "Delete"), style: .destructive) { [weak self] _ in
            self?.viewModel?.clearScanHistory()
        })
        present(alert, animated: true)
    }

    private func presentDetail(for record: ScanRecord) {
        let alert = UIAlertController(title: NSLocalizedString("View QR Content", comment: "View QR Content"), message: record.content, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Copy", comment: "Copy"), style: .default) { _ in
            UIPasteboard.general.string = record.content
        })
        if let url = URL(string: record.content), UIApplication.shared.canOpenURL(url) {
            alert.addAction(UIAlertAction(title: NSLocalizedString("Open in Safari", comment: "Open in Safari"), style: .default) { _ in
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            })
        }
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .cancel))
        present(alert, animated: true)
    }
}

extension ScanHistoryViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        records.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        guard records.indices.contains(indexPath.row) else { return cell }
        let record = records[indexPath.row]
        var config = cell.defaultContentConfiguration()
        config.text = record.content
        config.textProperties.numberOfLines = 1
        config.secondaryText = dateFormatter.string(from: Date(timeIntervalSince1970: record.scannedAt))
        config.secondaryTextProperties.color = .secondaryLabel
        cell.contentConfiguration = config
        cell.backgroundColor = .clear
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard records.indices.contains(indexPath.row) else { return }
        presentDetail(for: records[indexPath.row])
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard records.indices.contains(indexPath.row) else { return nil }
        let record = records[indexPath.row]
        let delete = UIContextualAction(style: .destructive, title: NSLocalizedString("Delete", comment: "Delete")) { [weak self] _, _, done in
            self?.viewModel?.deleteScanRecord(id: record.id)
            done(true)
        }
        return UISwipeActionsConfiguration(actions: [delete])
    }
}
