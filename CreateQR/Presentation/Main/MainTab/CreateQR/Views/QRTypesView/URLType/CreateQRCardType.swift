//
//  CreateQRCardType.swift
//  CreateQR
//
//  Created by 김미진 on 11/12/24.
//

import UIKit

class CreateQRCardType: CreateQRTypeView {
    
    @IBOutlet weak var noticeLB: UILabel!
    override func setupUI() {
        //TODO: - 공사중 안내 
        noticeLB.text = "현재 공사중입니다.\n다음 버전에 공개됩니다."
    }
}
