//
//  BackButtonEmptyTitleNavigationBarBehavior.swift
//  CreateQR
//
//  Created by 김미진 on 10/8/24.
//

import Foundation
import UIKit

struct BackButtonEmptyTitleNavigationBarBehavior: ViewControllerLifecycleBehavior {

    func viewDidLoad(viewController: UIViewController) {

        viewController.navigationItem.backBarButtonItem = UIBarButtonItem(
            title: "",
            style: .plain,
            target: nil,
            action: nil
        )
    }
}
