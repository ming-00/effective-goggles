//
//  CBLiquidButtonsAnimation.swift.swift
//  LiquidTabBar
//
//  Made by Cuberto.
//  http://cuberto.com
//

import UIKit

class CBLiquidButtonsAnimation: NSObject {

    static func animate(items: [CBLiquidTabBarButton], centralItem: CBLiquidTabBarButton, params: CBLiquidAnimationParams) {
        animate(centralItem: centralItem, params: params)

        let leftItems = items.prefix {
            $0 !== centralItem
        }
        let rightItems = items.reversed().prefix {
            $0 !== centralItem
        }

        CATransaction.begin()
        let leftItemsAnimation = buttonOffsetAnimations(withParams: params, referenceOffset: centralItem.frame.width)
        let rightItemsAnimation = buttonOffsetAnimations(withParams: params, referenceOffset: -centralItem.frame.width)
        for item in leftItems {
            item.setSelected(false, animated: true)
            item.layer.add(leftItemsAnimation, forKey: "offset")
        }
        for item in rightItems {
            item.setSelected(false, animated: true)
            item.layer.add(rightItemsAnimation, forKey: "offset")
        }
        CATransaction.commit()

    }

    private static func buttonOffsetAnimations(
        withParams params: CBLiquidAnimationParams,
        referenceOffset: CGFloat) -> CAAnimation {

        let animations = CAAnimationGroup()
        animations.duration = params.duration

        let step1 = CABasicAnimation(keyPath: "transform")
        step1.beginTime = 0
        step1.duration = params.duration * 0.5
        step1.timingFunction = CAMediaTimingFunction.easeOutSine
        step1.fromValue = CATransform3DIdentity
        step1.toValue = CATransform3DMakeTranslation(referenceOffset / 3.0, 0, 0)

        let step2 = CABasicAnimation(keyPath: "transform")
        step2.beginTime = params.duration * 0.5
        step2.duration = params.duration * 0.2
        step2.timingFunction = CAMediaTimingFunction(name: .easeIn)
        step2.fromValue = CATransform3DMakeTranslation(referenceOffset / 3.0, 0, 0)
        step2.toValue = CATransform3DMakeTranslation(-referenceOffset * 0.125, 0, 0)

        let step3 = CABasicAnimation(keyPath: "transform")
        step3.beginTime = params.duration * 0.7
        step3.duration = params.duration * 0.2
        step3.timingFunction = CAMediaTimingFunction(name: .easeOut)
        step3.fromValue = CATransform3DMakeTranslation(-referenceOffset * 0.125, 0, 0)
        step3.toValue = CATransform3DIdentity

        animations.animations = [step1, step2, step3]
        return animations
    }

    private static func animate(
        centralItem: CBLiquidTabBarButton,
        params: CBLiquidAnimationParams) {

        let centralItemMaxOffset = params.bubbleTop - params.bubbleRadius + centralItem.frame.height / 2.0
        let offsetTransform = CATransform3DMakeTranslation(0, -centralItemMaxOffset, 0)
        let offsetScaleTransform = CATransform3DScale(offsetTransform, 0.01, 0.01, 1.0)
        let scaleTransform = CATransform3DMakeScale(0.01, 0.01, 1.0)

        let centralHideAnimation = CAAnimationGroup()
        centralHideAnimation.duration = params.duration * 0.6
        centralHideAnimation.isRemovedOnCompletion = false
        centralHideAnimation.fillMode = .forwards

        let centralOffsetAnimation = CABasicAnimation(keyPath: "transform")
        centralOffsetAnimation.beginTime = 0
        centralOffsetAnimation.duration = params.duration * 0.4
        centralOffsetAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        centralOffsetAnimation.fromValue = CATransform3DIdentity
        centralOffsetAnimation.toValue = offsetTransform

        let centralScaleOutAnimation = CABasicAnimation(keyPath: "transform")
        centralScaleOutAnimation.beginTime = params.duration * 0.4
        centralScaleOutAnimation.duration = params.duration * 0.2
        centralScaleOutAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        centralScaleOutAnimation.fromValue = offsetTransform
        centralScaleOutAnimation.toValue = offsetScaleTransform
        centralScaleOutAnimation.isRemovedOnCompletion = false
        centralScaleOutAnimation.fillMode = .forwards

        centralHideAnimation.animations = [centralOffsetAnimation, centralScaleOutAnimation]

        let centralShowAnimation = CABasicAnimation(keyPath: "transform")
        centralShowAnimation.beginTime = 0
        centralShowAnimation.duration = params.duration * 0.15
        centralShowAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        centralShowAnimation.fromValue = scaleTransform
        centralShowAnimation.toValue = CATransform3DIdentity


        CATransaction.begin()
        CATransaction.setCompletionBlock {
            centralItem.isSelected = true
            CATransaction.begin()
            centralItem.layer.add(centralShowAnimation, forKey: "animate")
            CATransaction.commit()
        }
        centralItem.layer.add(centralHideAnimation, forKey: "animate")
        CATransaction.commit()
    }

}
