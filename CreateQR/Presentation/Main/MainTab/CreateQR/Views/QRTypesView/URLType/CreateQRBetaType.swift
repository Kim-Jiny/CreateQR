//
//  CreateQRBetaType.swift
//  CreateQR
//
//  Created by 김미진 on 11/12/24.
//

import UIKit

class CreateQRBetaType: CreateQRTypeView {
    
    @IBOutlet weak var noticeLB: UILabel!
    override func setupUI() {
        //TODO: - 공사중 안내
        noticeLB.text =  NSLocalizedString("The feature will be available in the next version.", comment: "")
    }
}
