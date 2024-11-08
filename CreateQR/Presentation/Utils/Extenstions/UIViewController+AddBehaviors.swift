//
//  UIViewController+AddBehaviors.swift
//  CreateQR
//
//  Created by 김미진 on 10/8/24.
//

import UIKit

protocol ViewControllerLifecycleBehavior {
    func viewDidLoad(viewController: UIViewController)
    func viewWillAppear(viewController: UIViewController)
    func viewDidAppear(viewController: UIViewController)
    func viewWillDisappear(viewController: UIViewController)
    func viewDidDisappear(viewController: UIViewController)
    func viewWillLayoutSubviews(viewController: UIViewController)
    func viewDidLayoutSubviews(viewController: UIViewController)
}
// Default implementations
extension ViewControllerLifecycleBehavior {
    func viewDidLoad(viewController: UIViewController) {}
    func viewWillAppear(viewController: UIViewController) {}
    func viewDidAppear(viewController: UIViewController) {}
    func viewWillDisappear(viewController: UIViewController) {}
    func viewDidDisappear(viewController: UIViewController) {}
    func viewWillLayoutSubviews(viewController: UIViewController) {}
    func viewDidLayoutSubviews(viewController: UIViewController) {}
}


extension UIViewController {
    func addBehaviors(_ behaviors: [ViewControllerLifecycleBehavior]) {
        let behaviorHandler = LifecycleBehaviorHandler(behaviors: behaviors)
        behaviorHandler.apply(to: self)
    }

    private final class LifecycleBehaviorHandler {
        private let behaviors: [ViewControllerLifecycleBehavior]

        init(behaviors: [ViewControllerLifecycleBehavior]) {
            self.behaviors = behaviors
        }

        func apply(to viewController: UIViewController) {
            // Override each lifecycle method to apply behaviors
            swizzle(viewController: viewController, original: #selector(UIViewController.viewDidLoad), swizzled: #selector(viewController.swizzled_viewDidLoad))
            swizzle(viewController: viewController, original: #selector(UIViewController.viewWillAppear(_:)), swizzled: #selector(viewController.swizzled_viewWillAppear(_:)))
            swizzle(viewController: viewController, original: #selector(UIViewController.viewDidAppear(_:)), swizzled: #selector(viewController.swizzled_viewDidAppear(_:)))
            swizzle(viewController: viewController, original: #selector(UIViewController.viewWillDisappear(_:)), swizzled: #selector(viewController.swizzled_viewWillDisappear(_:)))
            swizzle(viewController: viewController, original: #selector(UIViewController.viewDidDisappear(_:)), swizzled: #selector(viewController.swizzled_viewDidDisappear(_:)))
            swizzle(viewController: viewController, original: #selector(UIViewController.viewWillLayoutSubviews), swizzled: #selector(viewController.swizzled_viewWillLayoutSubviews))
            swizzle(viewController: viewController, original: #selector(UIViewController.viewDidLayoutSubviews), swizzled: #selector(viewController.swizzled_viewDidLayoutSubviews))
        }

        private func swizzle(viewController: UIViewController, original: Selector, swizzled: Selector) {
            guard let originalMethod = class_getInstanceMethod(type(of: viewController), original),
                  let swizzledMethod = class_getInstanceMethod(type(of: viewController), swizzled) else {
                return
            }
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
    }
}

extension UIViewController {
    @objc func swizzled_viewDidLoad() {
        self.swizzled_viewDidLoad() // Call the original viewDidLoad
        applyBehaviors { $0.viewDidLoad(viewController: self) }
    }

    @objc func swizzled_viewWillAppear(_ animated: Bool) {
        self.swizzled_viewWillAppear(animated)
        applyBehaviors { $0.viewWillAppear(viewController: self) }
    }

    @objc func swizzled_viewDidAppear(_ animated: Bool) {
        self.swizzled_viewDidAppear(animated)
        applyBehaviors { $0.viewDidAppear(viewController: self) }
    }

    @objc func swizzled_viewWillDisappear(_ animated: Bool) {
        self.swizzled_viewWillDisappear(animated)
        applyBehaviors { $0.viewWillDisappear(viewController: self) }
    }

    @objc func swizzled_viewDidDisappear(_ animated: Bool) {
        self.swizzled_viewDidDisappear(animated)
        applyBehaviors { $0.viewDidDisappear(viewController: self) }
    }

    @objc func swizzled_viewWillLayoutSubviews() {
        self.swizzled_viewWillLayoutSubviews()
        applyBehaviors { $0.viewWillLayoutSubviews(viewController: self) }
    }

    @objc func swizzled_viewDidLayoutSubviews() {
        self.swizzled_viewDidLayoutSubviews()
        applyBehaviors { $0.viewDidLayoutSubviews(viewController: self) }
    }

    private func applyBehaviors(body: (_ behavior: ViewControllerLifecycleBehavior) -> Void) {
        // Apply each behavior manually
        if let behaviors = objc_getAssociatedObject(self, &AssociatedKeys.behaviors) as? [ViewControllerLifecycleBehavior] {
            for behavior in behaviors {
                body(behavior)
            }
        }
    }
}

private struct AssociatedKeys {
    static var behaviors = "behaviors"
}
