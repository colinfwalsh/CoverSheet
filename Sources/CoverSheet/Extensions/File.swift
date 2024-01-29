//
//  File.swift
//  
//
//  Created by Colin Walsh on 1/26/24.
//

import Foundation
import UIKit

extension UIViewController {
    func configureChildViewController(childController: UIViewController, onView: UIView?) {
        guard var holderView = self.view
        else { return }
        
        if let onView = onView {
            holderView = onView
        }
        
        addChild(childController)
        holderView.addSubview(childController.view)
        constrainViewEqual(holderView: holderView, view: childController.view)
        childController.didMove(toParent: self)
        childController.willMove(toParent: self)
    }
    
    
    func constrainViewEqual(holderView: UIView, view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        //pin 100 points from the top of the super
        let pinTop = NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal,
                                        toItem: holderView, attribute: .top, multiplier: 1.0, constant: 0)
        let pinBottom = NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: .equal,
                                           toItem: holderView, attribute: .bottom, multiplier: 1.0, constant: 0)
        let pinLeft = NSLayoutConstraint(item: view, attribute: .left, relatedBy: .equal,
                                         toItem: holderView, attribute: .left, multiplier: 1.0, constant: 0)
        let pinRight = NSLayoutConstraint(item: view, attribute: .right, relatedBy: .equal,
                                          toItem: holderView, attribute: .right, multiplier: 1.0, constant: 0)
        
        holderView.addConstraints([pinTop, pinBottom, pinLeft, pinRight])
    }
}
