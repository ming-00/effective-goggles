//
//  CBFlashyTabBarController.swift
//  LiquidTabBar
//
//  Made by Cuberto.
//  http://cuberto.com
//

import UIKit

open class CBTabBarController: UITabBarController {

    fileprivate var shouldSelectOnTabBar = true

    open override var selectedViewController: UIViewController? {
        willSet {
            guard shouldSelectOnTabBar,
                let newValue = newValue else {
                    shouldSelectOnTabBar = true
                    return
            }
            guard let tabBar = tabBar as? CBLiquidTabBar,
                  let index = viewControllers?.firstIndex(of: newValue) else {
                return
            }
            tabBar.select(itemAt: index, animated: false)
        }
    }

    open override var selectedIndex: Int {
        willSet {
            guard shouldSelectOnTabBar else {
                shouldSelectOnTabBar = true
                return
            }
            guard let tabBar = tabBar as? CBLiquidTabBar else {
                return
            }
            tabBar.select(itemAt: selectedIndex, animated: false)
        }
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        guard self.tabBar as? CBLiquidTabBar == nil else {
            return
        }
        let tabBar = CBLiquidTabBar()
        if let barTint = self.tabBar.barTintColor {
            tabBar.barTintColor = barTint
        }
        self.modalPresentationStyle = .custom
        self.setValue(tabBar, forKey: "tabBar")
    }

    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    open var barHeight: CGFloat {
        get {
            return (tabBar as? CBLiquidTabBar)?.barHeight ?? tabBar.frame.height
        }
        set {
            (tabBar as? CBLiquidTabBar)?.barHeight = newValue
            self.setValue(tabBar, forKey: "tabBar")
        }
    }

    open override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        guard let idx = tabBar.items?.firstIndex(of: item) else {
            return
        }
        if let controller = viewControllers?[idx] {
            shouldSelectOnTabBar = false
            selectedIndex = idx
            delegate?.tabBarController?(self, didSelect: controller)
        }
    }

    private func updateTabBarFrame() {
        var tabFrame = tabBar.frame
        tabFrame.size.height = barHeight + view.safeAreaInsets.bottom
        tabFrame.origin.y = self.view.frame.size.height - tabFrame.size.height
        tabBar.frame = tabFrame
        tabBar.setNeedsLayout()
    }

    @available(iOS 11.0, *)
    open override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        updateTabBarFrame()
    }
}
