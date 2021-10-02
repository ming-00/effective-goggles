//
//  CBLiquidAnimationParams.swift
//  LiquidTabBar
//
//  Made by Cuberto.
//  http://cuberto.com
//

import UIKit

struct CBLiquidAnimationTimings {
    struct Background {
        let show: Double
        let hide: Double

        let bubbleCreate: Double
        let bubbleDismiss: Double
        let restore: Double

        static var standard: Background {
            return Background(
                show: 0.15,
                hide: 0.2,
                bubbleCreate: 0.4,
                bubbleDismiss: 0.3,
                restore: 0.3)
        }
    }

    struct Buttons {
        let collapse: Double
        let expand: Double
        let restore: Double

        let centralHide: Double
        let centralOffset: Double
        let centralScaleOut: (delay: Double, duration: Double)
        let centralShow: Double

        static var standard: Buttons {
            return Buttons(
                collapse: 0.5,
                expand: 0.2,
                restore: 0.2,
                centralHide: 0.6,
                centralOffset: 0.4,
                centralScaleOut: (delay: 0.4, duration: 0.2),
                centralShow: 0.15
            )
        }
    }

    let background: Background

    static var standard: CBLiquidAnimationTimings {
        return CBLiquidAnimationTimings(background: Background.standard)
    }

}

struct CBLiquidAnimationParams {
    let barHeight: CGFloat
    let duration: Double
    let bubbleCenter: CGFloat
    let cornerRound: CGFloat
    let bubbleRadius: CGFloat
    let timings: CBLiquidAnimationTimings

    var offset: CGFloat {
        return bubbleRadius
    }

    var curveStartOffset: CGFloat {
        return bubbleRadius * 1.5
    }

    var bubbleControlPointOffset: CGFloat {
        return bubbleRadius * 0.5
    }

    var bubbleTop: CGFloat {
        return bubbleRadius * 3
    }

    func shouldIgnoreLeftCorner(forLayer layer: CALayer) -> Bool {
        return bubbleCenter - curveStartOffset < offset
    }

    func shouldIgnoreRightCorner(forLayer layer: CALayer) -> Bool {
        return bubbleCenter + curveStartOffset > layer.bounds.maxX - offset
    }

    static func defaultParams(forBarHeight barHeight: CGFloat, bubbleCenter: CGFloat) -> CBLiquidAnimationParams {
        return CBLiquidAnimationParams(
            barHeight: barHeight,
            duration: 0.9,
            bubbleCenter: bubbleCenter,
            cornerRound: 40,
            bubbleRadius: 30,
            timings: CBLiquidAnimationTimings.standard
        )
    }
}
