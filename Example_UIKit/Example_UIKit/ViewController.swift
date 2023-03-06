//
//  ViewController.swift
//  Example_UIKit
//
//  Created by Colin Walsh on 3/6/23.
//

import UIKit
import CoverSheet

class ViewController: CoverSheetController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let innerVc = UIViewController()
        innerVc.view.translatesAutoresizingMaskIntoConstraints = false
        innerVc.view.backgroundColor = .gray
        let sheetVc = UIViewController()
        sheetVc.view.translatesAutoresizingMaskIntoConstraints = false
        
        configure(inner: innerVc, sheet: sheetVc)
    }
}

