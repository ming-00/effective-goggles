//
//  CBLiquidTabBar.swift
//  LiquidTabBar
//
//  Made by Cuberto.
//  http://cuberto.com
//

import UIKit

open class CBLiquidTabBar: UITabBar {

    public override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }

    open override var selectedItem: UITabBarItem? {
        willSet {
            guard let newValue = newValue else {
                buttons.forEach { $0.setSelected(false, animated: false) }
                return
            }

            let btnItems: [UITabBarItem?] = buttons.map { $0.item }
            for (index, value) in btnItems.enumerated() {
                if value === newValue {
                    select(itemAt: index, animated: false)
                }
            }
        }
    }

    open override var tintColor: UIColor! {
        didSet {
            buttons.forEach { button in
                button.tintColor = tintColor
            }
        }
    }

    open override var items: [UITabBarItem]? {
        didSet {
            reloadViews()
        }
    }

    @IBInspectable var barHeight: CGFloat = 70
    @IBInspectable var animationBackgroundColor: UIColor = #colorLiteral(red: 1, green: 0.8549019608, blue: 1, alpha: 1)


    private let animationSpaceHeight: CGFloat = 300
    private var shouldSelectOnTabBar = true
    private var buttons: [CBLiquidTabBarButton] = []
    private var animationBgLayer = CALayer()

    private func configure() {
        clipsToBounds = false
        if #available(iOS 13, *) {
            let appearance = standardAppearance
            appearance.configureWithOpaqueBackground()
            appearance.shadowImage = nil
            appearance.shadowColor = nil
            standardAppearance = appearance
        } else {
            shadowImage = UIImage()
            backgroundImage = UIImage()
        }
    }

    override open func sizeThatFits(_ size: CGSize) -> CGSize {
        var sizeThatFits = super.sizeThatFits(size)
        sizeThatFits.height = barHeight
        if #available(iOS 11.0, *) {
            sizeThatFits.height = sizeThatFits.height + safeAreaInsets.bottom
        }
        return sizeThatFits
    }

    open override func setItems(_ items: [UITabBarItem]?, animated: Bool) {
        super.setItems(items, animated: animated)
        reloadViews()
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        if buttons.isEmpty {
            return
        }
        animationBgLayer.frame = CGRect(
            x: 0,
            y: -animationSpaceHeight,
            width: bounds.width,
            height: bounds.height + animationSpaceHeight)

        let btnWidth = max(0, (bounds.width) / CGFloat(buttons.count))
        let bottomOffset: CGFloat = safeAreaInsets.bottom
        let btnHeight = bounds.height - bottomOffset

        var lastX: CGFloat = 0
        for button in buttons {
            button.frame = CGRect(x: lastX, y: 0, width: btnWidth, height: btnHeight)
            lastX = button.frame.maxX
            button.setNeedsLayout()
        }
    }

    private func reloadViews() {
        animationBgLayer.removeFromSuperlayer()
        animationBgLayer.isHidden = true
        layer.addSublayer(animationBgLayer)

        subviews.filter { String(describing: type(of: $0)) == "UITabBarButton" }.forEach { $0.removeFromSuperview() }
        buttons.forEach { $0.removeFromSuperview()}
        buttons = items?.map {
            CBLiquidTabBarButton(item: $0)
        } ?? []
        buttons.forEach { button in
            button.tintColor = tintColor
            if selectedItem != nil && button.item === selectedItem {
                button.setSelected(true, animated: false)
            }
            button.addTarget(self, action: #selector(btnPressed), for: .touchUpInside)
            addSubview(button)
        }
        setNeedsLayout()
    }

    @objc private func btnPressed(sender: UIControl) {
        guard let sender = sender as? CBLiquidTabBarButton else {
            return
        }
        defer {
            if let item = sender.item,
                let items = items,
                items.contains(item) {
                delegate?.tabBar?(self, didSelect: item)
            }
        }

        if !sender.isSelected {
            liquidAnimation(centerButton: sender)
            return
        }

        buttons.forEach { (button) in
            guard button !== sender else {
                return
            }
            button.setSelected(false, animated: true)
        }
        sender.setSelected(true, animated: true)
    }

    private var animating: Bool = false
    func liquidAnimation(centerButton: CBLiquidTabBarButton) {

        isUserInteractionEnabled = false
        let bgColor = (centerButton.item as? CBLiquidTabBarItem)?.barAnimationColor ?? animationBackgroundColor
        animationBgLayer.backgroundColor = bgColor.cgColor
        animating = true
        let params = CBLiquidAnimationParams.defaultParams(
            forBarHeight: bounds.height,
            bubbleCenter: centerButton.center.x)
        animationBgLayer.isHidden = false

        CBLiquidButtonsAnimation.animate(
            items: buttons,
            centralItem: centerButton,
            params: params)

        CBLiquidLayerAnimation.animate(layer: animationBgLayer, params: params) {
            self.animationBgLayer.isHidden = true
            self.isUserInteractionEnabled = true
            self.animating = false
        }
    }

    func select(itemAt index: Int, animated: Bool = false) {
        guard !animating else {
            return
        }
        guard index < buttons.count else {
            return
        }
        let selectedbutton = buttons[index]
        buttons.forEach { (button) in
            guard button !== selectedbutton else {
                return
            }
            button.setSelected(false, animated: animated)
        }
        selectedbutton.setSelected(true, animated: animated)
    }
}

