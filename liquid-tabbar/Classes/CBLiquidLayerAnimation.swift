//
//  LiquidLayerAnimation.swift
//  LiquidTabBar
//
//  Made by Cuberto.
//  http://cuberto.com
//

import UIKit

class CBLiquidLayerAnimation: NSObject {

    static func animate(layer: CALayer, params: CBLiquidAnimationParams, completion: (() -> Void)?) {
        let mask = CAShapeLayer()
        layer.mask = mask

        let opacityAnimation = makeBgOpacityAnimation(params: params)
        let bubbleCreate = makeBubbleCreateAnimation(layer: layer, params: params)
        let bubbleDismiss = makeBubbleDismissAnimation(layer: layer, params: params)
        let barRestore = makeBarRestoreAnimation(layer: layer, params: params)

        let maskAnimation = CAAnimationGroup()
        maskAnimation.duration = params.duration
        maskAnimation.animations = [bubbleCreate, bubbleDismiss, barRestore]

        CATransaction.begin()
        CATransaction.setCompletionBlock {
            completion?()
        }
        mask.add(maskAnimation, forKey: "path")
        layer.add(opacityAnimation, forKey: "opacity")
        CATransaction.commit()

    }

    private static func makeBgOpacityAnimation(params: CBLiquidAnimationParams) -> CAAnimation {
        let show = CABasicAnimation(keyPath: "opacity")
        let timings = params.timings.background
        show.timingFunction = CAMediaTimingFunction(name: .linear)
        show.beginTime = 0
        show.duration = params.duration * timings.show
        show.fromValue = 0
        show.toValue = 1.0

        let hide = CABasicAnimation(keyPath: "opacity")
        hide.timingFunction = CAMediaTimingFunction(name: .linear)
        hide.beginTime = params.duration * (1.0 - timings.hide)
        hide.duration = params.duration * timings.hide
        hide.fromValue = 1.0
        hide.toValue = 0

        let opacityAnimation = CAAnimationGroup()
        opacityAnimation.duration = params.duration
        opacityAnimation.isRemovedOnCompletion = false
        opacityAnimation.fillMode = .forwards
        opacityAnimation.animations = [show, hide]

        return opacityAnimation
    }

    private static func makeBubbleCreateAnimation(layer: CALayer, params: CBLiquidAnimationParams) -> CAAnimation {

        let timings = params.timings.background
        let firstPart = CAAnimationGroup()
        firstPart.duration = params.duration * timings.bubbleCreate
        firstPart.timingFunction = CAMediaTimingFunction.easeOutSine

        let firstPartStart = CABasicAnimation(keyPath: "path")
        firstPartStart.timingFunction = CAMediaTimingFunction(name: .linear)
        firstPartStart.beginTime = 0
        firstPartStart.duration = params.duration * 0.25 * timings.bubbleCreate
        firstPartStart.fromValue = startPath(for: layer, params: params)
        firstPartStart.toValue = firstPartMidPath(for: layer, params: params)

        let firstPartFinish = CABasicAnimation(keyPath: "path")
        firstPartFinish.timingFunction = CAMediaTimingFunction(name: .linear)
        firstPartFinish.beginTime = params.duration * 0.25 * timings.bubbleCreate
        firstPartFinish.duration = params.duration * 0.75 * timings.bubbleCreate
        firstPartFinish.fromValue = firstPartMidPath(for: layer, params: params)
        firstPartFinish.toValue = firstPartEndPath(for: layer, params: params)

        firstPart.animations = [firstPartStart, firstPartFinish]
        return firstPart
    }

    private static func makeBubbleDismissAnimation(layer: CALayer, params: CBLiquidAnimationParams) -> CAAnimation {

        let timings = params.timings.background
        let secondPart = CABasicAnimation(keyPath: "path")
        secondPart.timingFunction = CAMediaTimingFunction(name: .easeIn)
        secondPart.duration = params.duration * timings.bubbleDismiss
        secondPart.beginTime = params.duration * timings.bubbleCreate
        secondPart.fromValue = secondPartStartPath(for: layer, params: params)
        secondPart.toValue = secondPartEndPath(for: layer, params: params)
        return secondPart
    }

    private static func makeBarRestoreAnimation(layer: CALayer, params: CBLiquidAnimationParams) -> CAAnimation {

        let timings = params.timings.background
        let thirdPart = CABasicAnimation(keyPath: "path")
        thirdPart.timingFunction = CAMediaTimingFunction(name: .easeOut)
        thirdPart.duration = params.duration * timings.restore
        thirdPart.beginTime = params.duration * (timings.bubbleCreate + timings.bubbleDismiss)
        thirdPart.fromValue = thirdPartStartPath(for: layer, params: params)
        thirdPart.toValue = thirdPartEndPath(for: layer, params: params)
        return thirdPart
    }


    private static func configureStart(
        forPath path: UIBezierPath,
        layer: CALayer,
        params: CBLiquidAnimationParams,
        offset: CGPoint) -> UIBezierPath {

        if params.shouldIgnoreLeftCorner(forLayer: layer) {
            path.move(to: CGPoint(x: 0, y: layer.bounds.maxY))
            path.addLine(to: CGPoint(x: 0, y: layer.bounds.maxY - params.barHeight + offset.y))
            path.addLine(to: CGPoint(x: 0, y: layer.bounds.maxY - params.barHeight + offset.y))
        } else {
            path.move(to: CGPoint(x: offset.x, y: layer.bounds.maxY))
            path.addLine(to: CGPoint(
                x: offset.x,
                y: layer.bounds.maxY - params.barHeight + params.cornerRound + offset.y))
            path.addQuadCurve(
                to: CGPoint(x: offset.x + params.cornerRound, y: layer.bounds.maxY - params.barHeight + offset.y),
                controlPoint: CGPoint(x: offset.x, y: layer.bounds.maxY - params.barHeight + offset.y))
        }

        return path
    }

    private static func configureEnding(
        forPath path: UIBezierPath,
        layer: CALayer,
        params: CBLiquidAnimationParams,
        offset: CGPoint) -> UIBezierPath {
        
        if params.shouldIgnoreRightCorner(forLayer: layer) {
            path.addLine(
                to: CGPoint(
                    x: layer.bounds.maxX,
                    y: layer.bounds.maxY - params.barHeight + offset.y))
            path.addLine(
                to: CGPoint(
                    x: layer.bounds.maxX,
                    y: layer.bounds.maxY - params.barHeight + offset.y))
            path.addLine(to: CGPoint(x: layer.bounds.maxX, y: layer.bounds.maxY))
            path.addLine(to: CGPoint(x: 0, y: layer.bounds.maxY))
        } else {
            path.addLine(
                to: CGPoint(
                    x: layer.bounds.maxX - params.cornerRound - offset.x,
                    y: layer.bounds.maxY - params.barHeight + offset.y))
            path.addQuadCurve(
                to: CGPoint(
                    x: layer.bounds.maxX - offset.x,
                    y: layer.bounds.maxY - params.barHeight + params.cornerRound + offset.y),
                controlPoint: CGPoint(
                    x: layer.bounds.maxX - offset.x,
                    y: layer.bounds.maxY - params.barHeight + offset.y))
            path.addLine(to: CGPoint(x: layer.bounds.maxX - offset.x, y: layer.bounds.maxY))
            path.addLine(to: CGPoint(x: offset.x, y: layer.bounds.maxY))
        }
        return path
    }

    static func startPath(for layer: CALayer, params: CBLiquidAnimationParams) -> CGPath {

        let pt1 = CGPoint(x: params.bubbleCenter - params.curveStartOffset, y: layer.bounds.maxY - params.barHeight)
        let pt2 = CGPoint(x: params.bubbleCenter - params.bubbleRadius, y: layer.bounds.maxY - params.barHeight)
        let pt3 = CGPoint(x: params.bubbleCenter, y: layer.bounds.maxY - params.barHeight)
        let pt4 = CGPoint(x: params.bubbleCenter + params.bubbleRadius, y: layer.bounds.maxY - params.barHeight)
        let pt5 = CGPoint(x: params.bubbleCenter + params.curveStartOffset, y: layer.bounds.maxY - params.barHeight)

        var path = UIBezierPath()
        path = configureStart(forPath: path, layer: layer, params: params, offset: .zero)
        path.addLine(to: pt1)
        path.addCurve(
            to: pt2,
            controlPoint1: pt1.offsetBy(dx: 1),
            controlPoint2: pt2.offsetBy(dx: -params.bubbleControlPointOffset)
        )

        path.addCurve(
            to: pt3,
            controlPoint1: pt2.offsetBy(dx: params.bubbleRadius),
            controlPoint2: pt3.offsetBy(dx: -params.bubbleControlPointOffset * 0.2)
        )

        path.addCurve(
            to: pt4,
            controlPoint1: pt3.offsetBy(dx: params.bubbleControlPointOffset * 0.2),
            controlPoint2: pt4.offsetBy(dx: -params.bubbleControlPointOffset)
        )

        path.addCurve(
            to: pt5,
            controlPoint1: pt4.offsetBy(dx: params.bubbleControlPointOffset),
            controlPoint2: pt5.offsetBy(dx: -1)
        )

        path = configureEnding(forPath: path, layer: layer, params: params, offset: .zero)
        return path.cgPath
    }

    static func firstPartMidPath(for layer: CALayer, params: CBLiquidAnimationParams) -> CGPath {
        let stepOffset: CGFloat = params.offset * 0.3
        let pt1 = CGPoint(x: params.bubbleCenter - params.curveStartOffset, y: layer.bounds.maxY - params.barHeight)
        let pt2 = CGPoint(
            x: params.bubbleCenter - params.bubbleRadius,
            y: layer.bounds.maxY - params.barHeight - params.bubbleControlPointOffset)
        let pt3 = CGPoint(x: params.bubbleCenter, y: layer.bounds.maxY - params.barHeight - params.bubbleRadius)
        let pt4 = CGPoint(
            x: params.bubbleCenter + params.bubbleRadius,
            y: layer.bounds.maxY - params.barHeight - params.bubbleControlPointOffset)
        let pt5 = CGPoint(x: params.bubbleCenter + params.curveStartOffset, y: layer.bounds.maxY - params.barHeight)

        var path = UIBezierPath()
        path = configureStart(forPath: path, layer: layer, params: params, offset: CGPoint(x: stepOffset, y: 0))

        path.addLine(to: pt1)
        path.addCurve(
            to: pt2,
            controlPoint1: pt1.offsetBy(dx: params.bubbleControlPointOffset),
            controlPoint2: pt2.offsetBy(
                dx: -params.bubbleControlPointOffset * sin(.pi / 4.0),
                dy: params.bubbleControlPointOffset * cos(.pi / 4.0)
            )
        )

        path.addCurve(
            to: pt3,
            controlPoint1: pt2.offsetBy(
                dx: params.bubbleControlPointOffset * sin(.pi / 4.0),
                dy: -params.bubbleControlPointOffset * 0.5 * cos(.pi / 4.0)
            ),
            controlPoint2: pt3.offsetBy(dx: -params.bubbleControlPointOffset)
        )

        path.addCurve(
            to: pt4,
            controlPoint1: pt3.offsetBy(dx: params.bubbleControlPointOffset),
            controlPoint2: pt4.offsetBy(
                dx: -params.bubbleControlPointOffset * sin(.pi / 4.0),
                dy: -params.bubbleControlPointOffset * cos(.pi / 4.0)
            )
        )

        path.addCurve(
            to: pt5,
            controlPoint1: pt4.offsetBy(
                dx: +params.bubbleControlPointOffset * sin(.pi / 4.0),
                dy: +params.bubbleControlPointOffset * cos(.pi / 4.0)
            ),
            controlPoint2: pt5.offsetBy(dx: -params.bubbleControlPointOffset)
        )

        path = configureEnding(forPath: path, layer: layer, params: params, offset: CGPoint(x: stepOffset, y: 0))

        return path.cgPath
    }

    private static func firstPartEndPath(for layer: CALayer, params: CBLiquidAnimationParams) -> CGPath {

        let pt1 = CGPoint(
            x: params.bubbleCenter - params.curveStartOffset * 0.75,
            y: layer.bounds.maxY - params.barHeight)
        let pt2 = CGPoint(
            x: params.bubbleCenter - params.bubbleRadius,
            y: layer.bounds.maxY - params.barHeight - params.bubbleTop + params.bubbleRadius)
        let pt3 = CGPoint(
            x: params.bubbleCenter,
            y: layer.bounds.maxY - params.barHeight - params.bubbleTop)
        let pt4 = CGPoint(
            x: params.bubbleCenter + params.bubbleRadius,
            y: layer.bounds.maxY - params.barHeight - params.bubbleTop + params.bubbleRadius)
        let pt5 = CGPoint(x: params.bubbleCenter + params.curveStartOffset * 0.75, y: layer.bounds.maxY - params.barHeight)

        var path = UIBezierPath()
        path = configureStart(forPath: path, layer: layer, params: params, offset: CGPoint(x: params.offset, y: 0))

        path.addLine(to: pt1)
        path.addCurve(
            to: pt2,
            controlPoint1: pt1.offsetBy(dx: params.curveStartOffset * 1.25),
            controlPoint2: pt2.offsetBy(dy: params.bubbleRadius)
        )

        path.addCurve(
            to: pt3,
            controlPoint1: pt2.offsetBy(dy: -params.bubbleControlPointOffset),
            controlPoint2: pt3.offsetBy(dx: -params.bubbleControlPointOffset)
        )

        path.addCurve(
            to: pt4,
            controlPoint1: pt3.offsetBy(dx: params.bubbleControlPointOffset),
            controlPoint2: pt4.offsetBy(dy: -params.bubbleControlPointOffset)
        )

        path.addCurve(
            to: pt5,
            controlPoint1: pt4.offsetBy(dy: params.bubbleRadius),
            controlPoint2: pt5.offsetBy(dx: -params.curveStartOffset * 1.25))

        path = configureEnding(forPath: path, layer: layer, params: params, offset: CGPoint(x: params.offset, y: 0))
        return path.cgPath
    }

    private static func secondPartStartPath(for layer: CALayer, params: CBLiquidAnimationParams) -> CGPath {

        let pt1 = CGPoint(
            x: params.bubbleCenter - params.curveStartOffset * 0.75,
            y: layer.bounds.maxY - params.barHeight)
        let pt2 = CGPoint(
            x: params.bubbleCenter,
            y: layer.bounds.maxY - params.barHeight - params.bubbleRadius * 0.2)
        let pt3 = CGPoint(
            x: params.bubbleCenter + params.curveStartOffset * 0.75,
            y: layer.bounds.maxY - params.barHeight)

        let bubbleCenter = CGPoint(
            x: params.bubbleCenter,
            y: layer.bounds.maxY - params.barHeight - params.bubbleTop + params.bubbleRadius
        )


        var path = UIBezierPath()
        path = configureStart(forPath: path, layer: layer, params: params, offset: CGPoint(x: params.offset, y: 0))

        path.addLine(to: pt1)
        path.addCurve(
            to: pt2,
            controlPoint1: pt1.offsetBy(dx: params.curveStartOffset * 0.5),
            controlPoint2: pt2.offsetBy(dx: -params.bubbleControlPointOffset * 0.5)
        )

        path.addCurve(
            to: pt3,
            controlPoint1: pt2.offsetBy(dx: params.bubbleControlPointOffset * 0.5),
            controlPoint2: pt3.offsetBy(dx: -params.curveStartOffset * 0.5)
        )

        path = configureEnding(forPath: path, layer: layer, params: params, offset: CGPoint(x: params.offset, y: 0))

        path.move(to: bubbleCenter.offsetBy(dx: -params.bubbleRadius))
        path.addCurve(
            to: bubbleCenter.offsetBy(dy: -params.bubbleRadius),
            controlPoint1: bubbleCenter.offsetBy(dx: -params.bubbleRadius, dy: -params.bubbleControlPointOffset),
            controlPoint2: bubbleCenter.offsetBy(dx: -params.bubbleControlPointOffset, dy: -params.bubbleRadius)
        )
        path.addCurve(
            to: bubbleCenter.offsetBy(dx: params.bubbleRadius),
            controlPoint1: bubbleCenter.offsetBy(dx: params.bubbleControlPointOffset, dy: -params.bubbleRadius),
            controlPoint2: bubbleCenter.offsetBy(dx: params.bubbleRadius, dy: -params.bubbleControlPointOffset)
        )
        path.addCurve(
            to: bubbleCenter.offsetBy(dy: params.bubbleRadius * 1.2),
            controlPoint1: bubbleCenter.offsetBy(dx: params.bubbleRadius, dy: params.bubbleControlPointOffset),
            controlPoint2: bubbleCenter.offsetBy(dx: params.bubbleControlPointOffset, dy: params.bubbleRadius * 1.2)
        )
        path.addCurve(
            to: bubbleCenter.offsetBy(dx: -params.bubbleRadius),
            controlPoint1: bubbleCenter.offsetBy(dx: -params.bubbleControlPointOffset, dy: params.bubbleRadius * 1.2),
            controlPoint2: bubbleCenter.offsetBy(dx: -params.bubbleRadius, dy: params.bubbleControlPointOffset)
        )
        return path.cgPath
    }

    static func secondPartEndPath(for layer: CALayer, params: CBLiquidAnimationParams) -> CGPath {

        let vertOffset = params.offset * 0.5
        let pt1 = CGPoint(
            x: params.bubbleCenter - params.curveStartOffset * 0.75,
            y: layer.bounds.maxY - params.barHeight - vertOffset)
        let pt2 = CGPoint(
            x: params.bubbleCenter,
            y: layer.bounds.maxY - params.barHeight - vertOffset)
        let pt3 = CGPoint(
            x: params.bubbleCenter + params.curveStartOffset * 0.75,
            y: layer.bounds.maxY - params.barHeight - vertOffset)

        let bubbleCenter = CGPoint(
            x: params.bubbleCenter,
            y: layer.bounds.maxY - params.barHeight - params.bubbleTop + params.bubbleRadius
        )

        var path = UIBezierPath()
        path = configureStart(
            forPath: path,
            layer: layer,
            params: params,
            offset: CGPoint(x: -params.offset * 0.5, y: -vertOffset)
        )

        path.addLine(to: pt1)
        path.addCurve(
            to: pt2,
            controlPoint1: pt1.offsetBy(dx: params.curveStartOffset * 0.5),
            controlPoint2: pt2.offsetBy(dx: -params.bubbleControlPointOffset * 0.2)
        )

        path.addCurve(
            to: pt3,
            controlPoint1: pt2.offsetBy(dx: params.bubbleControlPointOffset * 0.2),
            controlPoint2: pt3.offsetBy(dx: -params.curveStartOffset * 0.5)
        )

        path = configureEnding(
            forPath: path,
            layer: layer,
            params: params,
            offset: CGPoint(x: -params.offset * 0.5, y: -vertOffset)
        )

        let collapseCoeff: CGFloat = 0.001
        let collapsedRadius: CGFloat = collapseCoeff * params.bubbleRadius
        let collapsedControlOffset: CGFloat = collapseCoeff * params.bubbleControlPointOffset
        path.move(to: bubbleCenter.offsetBy(dx: -collapsedRadius))
        path.addCurve(
            to: bubbleCenter.offsetBy(dy: -collapsedRadius),
            controlPoint1: bubbleCenter.offsetBy(dx: -collapsedRadius, dy: -collapsedControlOffset),
            controlPoint2: bubbleCenter.offsetBy(dx: -collapsedControlOffset, dy: -collapsedRadius)
        )
        path.addCurve(
            to: bubbleCenter.offsetBy(dx: collapsedRadius),
            controlPoint1: bubbleCenter.offsetBy(dx: collapsedControlOffset, dy: -collapsedRadius),
            controlPoint2: bubbleCenter.offsetBy(dx: collapsedRadius, dy: -collapsedControlOffset)
        )
        path.addCurve(
            to: bubbleCenter.offsetBy(dy: collapsedRadius),
            controlPoint1: bubbleCenter.offsetBy(dx: collapsedRadius, dy: collapsedControlOffset),
            controlPoint2: bubbleCenter.offsetBy(dx: collapsedControlOffset, dy: collapsedRadius)
        )
        path.addCurve(
            to: bubbleCenter.offsetBy(dx: -collapsedRadius),
            controlPoint1: bubbleCenter.offsetBy(dx: -collapsedControlOffset, dy: collapsedRadius),
            controlPoint2: bubbleCenter.offsetBy(dx: -collapsedRadius, dy: collapsedControlOffset)
        )

        return path.cgPath
    }

    private static func thirdPartStartPath(for layer: CALayer, params: CBLiquidAnimationParams) -> CGPath {
        var path = UIBezierPath()
        path = configureStart(
            forPath: path,
            layer: layer,
            params: params,
            offset: CGPoint(x: -params.offset * 0.5, y: -params.offset * 0.5)
        )

        path = configureEnding(
            forPath: path,
            layer: layer,
            params: params,
            offset: CGPoint(x: -params.offset * 0.5, y: -params.offset * 0.5)
        )

        return path.cgPath
    }

    private static func thirdPartEndPath(for layer: CALayer, params: CBLiquidAnimationParams) -> CGPath {
        var path = UIBezierPath()
        path = configureStart(
            forPath: path,
            layer: layer,
            params: params,
            offset: .zero
        )

        path = configureEnding(
            forPath: path,
            layer: layer,
            params: params,
            offset: .zero
        )

        return path.cgPath
    }

}
