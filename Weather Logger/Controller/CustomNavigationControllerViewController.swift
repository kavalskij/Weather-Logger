//
//  CustomNavigationControllerViewController.swift
//  Weather Logger
//
//  Created by Aleksandrs Muravjovs on 14/02/2019.
//  Copyright © 2019 Aleksandrs Muravjovs. All rights reserved.
//

import UIKit

class CustomNavigationControllerViewController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let visualEffectView   = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.addSubview(visualEffectView)
    }
}
