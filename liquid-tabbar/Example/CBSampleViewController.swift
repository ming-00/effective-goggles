//
//  CBSampleViewController.swift
//  CBFlashyTabBarController_Example
//
//  Made by Cuberto.
//  http://cuberto.com
//

import UIKit

class CBSampleViewController: UIViewController {

    var lblTitle: UILabel = {
        var label = UILabel()
        label.textColor = UIColor(named: "SampleControllerLabel")
        label.font = UIFont.systemFont(ofSize: 55.0, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        lblTitle.text = tabBarItem.title
        view.addSubview(lblTitle)
        lblTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        lblTitle.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        view.setNeedsLayout()

    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return view.backgroundColor == UIColor.white ? .default : .lightContent
    }
}
