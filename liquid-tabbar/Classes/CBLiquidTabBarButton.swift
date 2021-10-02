//
//  CBLiquidTabBarButton.swift
//  LiquidTabBar
//
//  Made by Cuberto.
//  http://cuberto.com
//

import UIKit

class CBLiquidTabBarItem: UITabBarItem {
    @IBInspectable var barAnimationColor: UIColor = .white
}

class CBLiquidTabBarButton: UIControl {

    var tabImage = UIImageView()
    var selectedTabImage = UIImageView()
    var badgeContainer = UIView()
    var badgeLabel = UILabel()
    
    private var _isSelected: Bool = false
    override var isSelected: Bool {
        get {
            return _isSelected
        }
        set {
            guard newValue != _isSelected else {
                return
            }
            setSelected(newValue, animated: false)
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureSubviews()
        addObservers()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureSubviews()
        addObservers()
    }

    required init(item: UITabBarItem) {
        super.init(frame: .zero)
        addObservers()
        configureSubviews()
        self.item = item
    }

    deinit {
        removeObserver(self, forKeyPath: #keyPath(_item.badgeValue))
        removeObserver(self, forKeyPath: #keyPath(_item.badgeColor))
    }

    private func addObservers() {
        addObserver(self, forKeyPath: #keyPath(_item.badgeValue), options: [.initial, .new], context: nil)
        addObserver(self, forKeyPath: #keyPath(_item.badgeColor), options: [.initial, .new], context: nil)
    }

    var item: UITabBarItem? {
        set {
            guard let item = newValue else { return }
            _item = item
        }
        get {
            return _item
        }
    }

    @objc dynamic var _item: UITabBarItem = UITabBarItem(){
        didSet {
            didUpdateItem()
        }
    }

    override var tintColor: UIColor! {
        didSet {
            tabImage.tintColor = tintColor
            badgeContainer.backgroundColor = item?.badgeColor ?? tintColor
        }
    }

    private func attributedText(fortitle title: String?) -> NSAttributedString {
        var attrs: [NSAttributedString.Key: Any] = [:]
        attrs[.kern] = -0.2
        attrs[.foregroundColor] = tintColor
        attrs[.font] = UIFont.systemFont(ofSize: 12, weight: .semibold)
        return NSAttributedString(string: title ?? "", attributes: attrs)
    }

    private func configureSubviews() {
        addSubview(tabImage)
        addSubview(selectedTabImage)
        selectedTabImage.alpha = 0
        badgeContainer.addSubview(badgeLabel)
        addSubview(badgeContainer)
        tabImage.contentMode = .center
        badgeContainer.isHidden = true
        badgeLabel.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        if #available(iOS 13.0, *) {
            badgeLabel.textColor = .systemBackground
        } else {
            badgeLabel.textColor = .white
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        tabImage.sizeToFit()
        tabImage.center = CGPoint(x: bounds.width/2.0, y: bounds.height/2.0)
        selectedTabImage.sizeToFit()
        selectedTabImage.center = CGPoint(x: bounds.width/2.0, y: bounds.height/2.0)

        let badgeMargin: CGFloat = 3
        badgeLabel.sizeToFit()
        let badgeWidth = max(20, min(badgeLabel.frame.width + 2 * badgeMargin, bounds.width - 2 * badgeMargin))
        badgeContainer.frame = CGRect(x: bounds.width - badgeWidth - badgeMargin,
                                      y: badgeMargin,
                                      width: badgeWidth,
                                      height: 20)
        let lblWidth = min(badgeLabel.frame.width, badgeWidth - 2 * badgeMargin)
        badgeLabel.frame = CGRect(x: (badgeContainer.frame.width - lblWidth)/2.0,
                                  y: badgeMargin,
                                  width: lblWidth,
                                  height: badgeContainer.frame.height - 2 * badgeMargin)
        badgeContainer.layer.cornerRadius = badgeContainer.frame.height/2.0
    }

    func setSelected(_ selected: Bool, animated: Bool) {
        guard _isSelected != selected else {
            return
        }
        _isSelected = selected
        let animations = {
            self.tabImage.alpha = self._isSelected ? 0 : 1
            self.selectedTabImage.alpha = self._isSelected ? 1 : 0
        }
        if animated {
            UIView.animate(withDuration: 0.5, animations: animations)
        } else {
            animations()
        }
    }

    private func updateImage() {
        if let image = _item.image {
            switch image.renderingMode {
            case .alwaysOriginal:
                tabImage.image = image
            default:
                tabImage.image = image.withRenderingMode(.alwaysTemplate)
            }
        } else {
            tabImage.image = nil
        }

        if let selectedImage = _item.selectedImage {
            switch selectedImage.renderingMode {
            case .alwaysOriginal:
                selectedTabImage.image = selectedImage
            default:
                selectedTabImage.image = selectedImage.withRenderingMode(.alwaysTemplate)
            }
        } else {
            selectedTabImage.image = tabImage.image
        }
    }

    private func didUpdateItem() {
        updateImage()
        badgeContainer.backgroundColor = item?.badgeColor ?? tintColor
        badgeLabel.text = item?.badgeValue
        if let badgeText = item?.badgeValue,
            let badgeTextAttrs =  item?.badgeTextAttributes(for: .normal) {
            badgeLabel.text = nil
            badgeLabel.attributedText = NSAttributedString(string: badgeText, attributes: badgeTextAttrs)
        } else {
            badgeLabel.text = item?.badgeValue
        }
        badgeContainer.isHidden = item?.badgeValue == nil
        setNeedsLayout()
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        switch keyPath {
        case #keyPath(_item.badgeValue), #keyPath(_item.badgeColor):
            didUpdateItem()
        default:
            break
        }
    }
}
