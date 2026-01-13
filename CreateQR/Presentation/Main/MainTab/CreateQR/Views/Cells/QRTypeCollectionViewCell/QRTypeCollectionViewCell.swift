//
//  QRTypeCollectionViewCell.swift
//  CreateQR
//
//  Created by 김미진 on 11/8/24.
//

import UIKit

class QRTypeCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var typeImg: UIImageView!
    @IBOutlet weak var typeLB: UILabel!

    static var id: String {
        return NSStringFromClass(Self.self).components(separatedBy: ".").last!
    }
    private var viewModel: QRTypeItemViewModel!

    func fill(
        with viewModel: QRTypeItemViewModel
    ) {
        self.viewModel = viewModel
        self.typeImg.image = viewModel.titleImage
        self.typeLB.text = viewModel.title
        self.layer.cornerRadius = 20
        self.backgroundColor = .speedMain3
    }

    func setSelectedAppearance(_ selected: Bool) {
        if selected {
            self.layer.borderWidth = 2.0
            self.layer.borderColor = UIColor.speedMain2.cgColor
        } else {
            self.layer.borderWidth = 0.0
            self.layer.borderColor = nil
        }
    }

    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let attributes = super.preferredLayoutAttributesFitting(layoutAttributes)

        // 텍스트 너비 계산
        let labelWidth = typeLB.intrinsicContentSize.width + 24 // 좌우 패딩 12 * 2
        let imageWidth: CGFloat = 40 + 6 // 이미지 40 + 좌우 패딩 3 * 2

        // 최소 너비는 이미지 기준, 텍스트가 길면 텍스트 기준
        let minWidth = max(labelWidth, imageWidth)

        attributes.size = CGSize(width: minWidth, height: 71)
        return attributes
    }
}
