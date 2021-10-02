//
//  CGPoint+offset.swift
//  LiquidTabBar
//
//  Made by Cuberto.
//  http://cuberto.com
//

import UIKit

extension CGPoint {
    func offsetBy(dx: CGFloat = 0, dy: CGFloat = 0) -> CGPoint {
        return CGPoint(x: x + dx, y: y + dy)
    }
}
