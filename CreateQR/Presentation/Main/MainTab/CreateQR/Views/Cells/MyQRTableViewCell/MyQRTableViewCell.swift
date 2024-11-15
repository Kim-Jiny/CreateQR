//
//  MyQRTableViewCell.swift
//  CreateQR
//
//  Created by 김미진 on 11/13/24.
//

import UIKit

class MyQRTableViewCell: UITableViewCell {
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var timeLB: UILabel!
    @IBOutlet weak var titleLB: UILabel!
    @IBOutlet weak var subtitleLB: UILabel!
    @IBOutlet weak var qrImg: UIImageView!
    static var id: String {
        return NSStringFromClass(Self.self).components(separatedBy: ".").last!
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.selectionStyle = .none
        // Configure the view for the selected state
    }
    
    func fill(
        with item: QRItem
    ) {
        self.backView.roundLeftCorners(cornerRadius: 30)
        self.backView.backgroundColor = .speedMain4
        self.titleLB.text = item.title
        self.timeLB.text = TimestampProvider().getFormattedDate(item.createdAt)
        self.subtitleLB.text = item.qrType == .other ? NSLocalizedString("Saved by Scan", comment: "Saved by Scan") : NSLocalizedString("App Created", comment: "App Created")
        if let imgdata = item.qrImageData, let img = UIImage(data: imgdata) {
            self.qrImg.image = img
        }else {
            self.qrImg.image = UIImage(systemName: "exclamationmark.octagon.fill")
        }
        
    }
}
