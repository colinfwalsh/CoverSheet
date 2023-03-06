//
//  SheetViewController.swift
//  KnightTransporter
//
//  Created by Colin Walsh on 2/8/23.
//  Copyright © 2023 Colin Walsh. All rights reserved.
//

import UIKit
import SwiftUI

class ContainerViewController: UIViewController, Containable {
    
    internal var hostingViewController: UIViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func configure(_ viewController: UIViewController) {
        setupViewController(viewController)
    }
    
    func configure(_ view: some View) {
        
        hostingViewController = UIHostingController(rootView: view)
        hostingViewController?.view.backgroundColor = .clear
        
        guard let vc = hostingViewController
        else { return }
        
        setupViewController(vc)
    }
    
    func update<Content: View>(_ view: Content) {
        guard let vc = hostingViewController as? UIHostingController<Content>
        else { return }
        
        vc.rootView = view
    }
    
    private func setupViewController(_ viewController: UIViewController) {
        viewController.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: view.frame.height)
        self.addChild(viewController)
        
        viewController.view.backgroundColor = .clear
        
        view.addSubview(viewController.view)
        
        viewController.didMove(toParent: self)
    }
}
