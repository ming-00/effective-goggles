//
//  AppDelegate.swift
//  LiquidTabBar
//
//  Made by Cuberto.
//  http://cuberto.com
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        CBLiquidTabBar.appearance().tintColor = UIColor(named: "BarIButtonTint")
        CBLiquidTabBar.appearance().barTintColor = .white
        return true
    }


}

