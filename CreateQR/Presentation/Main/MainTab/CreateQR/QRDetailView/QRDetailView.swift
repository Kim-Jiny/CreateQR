//
//  QRDetailView.swift
//  CreateQR
//
//  Created by 김미진 on 11/13/24.
//

import UIKit
protocol QRDetailDelegate: AnyObject {
    func saveImage()
    func shareImage()
    
    func backTab()
    func changeQRData(_ data: QRItem)
    func removeData(_ data: QRItem)
    func readData(_ data: QRItem)
}

class QRDetailView: UIView {
    weak var delegate: QRDetailDelegate?
    var data: QRItem? = nil
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var qrImg: UIImageView!
    @IBOutlet weak var timeLB: UILabel!
    @IBOutlet weak var titleTextView: UITextField!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var shareBtn: UIButton!
    @IBOutlet weak var removeBtn: UIButton!
    @IBOutlet weak var readBtn: UIButton!
    @IBOutlet weak var backDarkView: UIView!
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        viewInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        viewInit()
    }

    func viewInit() {
        // XIB 로드
        let nib = UINib(nibName: String(describing: Self.self), bundle: Bundle(for: type(of: self)))
        guard let loadedView = nib.instantiate(withOwner: self, options: nil).first as? UIView else {
            return
        }
        
        // XIB에서 로드된 뷰를 현재 뷰에 추가
        loadedView.frame = self.bounds
        loadedView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(loadedView)
        
        backView.layer.cornerRadius = 20
        backView.backgroundColor = .speedMain4
        
        saveBtn.setTitle(NSLocalizedString("Save", comment:"Save"), for: .normal)
        saveBtn.layer.cornerRadius = 10
        saveBtn.layer.borderWidth = 2
        saveBtn.layer.borderColor = UIColor.speedMain2.cgColor
        
        shareBtn.setTitle(NSLocalizedString("Share", comment:"Share"), for: .normal)
        shareBtn.layer.cornerRadius = 10
        shareBtn.layer.borderWidth = 2
        shareBtn.layer.borderColor = UIColor.speedMain2.cgColor
        
        readBtn.setTitle(NSLocalizedString("Read QR", comment:"Read QR"), for: .normal)
        readBtn.layer.cornerRadius = 10
        readBtn.layer.borderWidth = 2
        readBtn.layer.borderColor = UIColor.speedMain2.cgColor
        
        removeBtn.setTitle(NSLocalizedString("Remove", comment:"Remove"), for: .normal)
        removeBtn.layer.cornerRadius = 10
        removeBtn.layer.borderWidth = 2
        removeBtn.layer.borderColor = UIColor.speedMain2.cgColor
        
        qrImg.layer.borderWidth = 5
        qrImg.layer.borderColor = UIColor.speedMain3.cgColor
        
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backDarkViewTapped))
        backDarkView.isUserInteractionEnabled = true // 터치 이벤트를 받을 수 있게 설정
        backDarkView.addGestureRecognizer(tapGesture)
        
        titleTextView.delegate = self
    }
    
    func fill(
        with item: QRItem
    ) {
        self.data = item
        self.titleTextView.text = item.title
        let qrCreateType = item.qrType == .other ? NSLocalizedString("Scanned", comment: "Scanned") :  NSLocalizedString("Created", comment: "Created")
        self.timeLB.text = "\(TimestampProvider().getFormattedDate(item.createdAt)) \(qrCreateType)"
        if let imgdata = item.qrImageData, let img = UIImage(data: imgdata) {
            self.qrImg.image = img
        }else {
            self.qrImg.image = UIImage(systemName: "exclamationmark.octagon.fill")
        }
    }
    
    @IBAction func saveBtn(_ sender: Any) {
        self.delegate?.saveImage()
    }
    
    @IBAction func shareBtn(_ sender: Any) {
        self.delegate?.shareImage()
    }
    
    @IBAction func readBtn(_ sender: Any) {
        if self.data != nil {
            self.delegate?.readData(self.data!)
        }
    }
    
    @IBAction func removeBtn(_ sender: Any) {
        if self.data != nil {
            self.delegate?.removeData(self.data!)
        }
    }
    
    @objc private func backDarkViewTapped() {
        self.delegate?.backTab()
    }
}


extension QRDetailView: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        if self.data != nil {
            data?.title = textField.text ??  NSLocalizedString("Untitled", comment: "Untitled")
            self.delegate?.changeQRData(self.data!)
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.text ==  NSLocalizedString("Untitled", comment: "Untitled") {
            textField.text = ""
        }
    }
}
