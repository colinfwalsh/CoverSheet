//
//  CoverSheetView.swift
//  CoverSheet
//
//  Created by Colin Walsh on 2/22/23.
//

import Foundation
import UIKit
import SwiftUI

// MARK: SwiftUI ViewRepresentable
public struct CoverSheetView<Inner: View, Sheet: View, ViewManager: Manager>: UIViewControllerRepresentable {
    @ObservedObject
    private var manager: ViewManager
    
    private var useBlurEffect: Bool
    
    private var sheetColor: UIColor
    
    private var animationConfig: AnimationConfig
    
    @ViewBuilder
    public var inner: () -> Inner
    
    @ViewBuilder
    public var sheet: (CGFloat) -> Sheet
    
    public init(_ manager: ViewManager,
                states: [SheetState] = [],
                _ inner: @escaping () -> Inner,
                sheet: @escaping (CGFloat) -> Sheet) {
        manager.states = states
        _manager = ObservedObject(wrappedValue: manager)
        self.useBlurEffect = false
        self.sheetColor = .white
        self.animationConfig = AnimationConfig()
        self.inner = inner
        self.sheet = sheet
    }
    
    public func makeUIViewController(context: Context) -> CoverSheetController<ViewManager> {
        let updatedStates = manager.states.isEmpty ? [.collapsed, .normal, .full] : manager.states
        let vc = CoverSheetController(manager: manager,
                                      shouldUseEffect: useBlurEffect,
                                      sheetColor: sheetColor)
        vc.delegate = manager
        vc.configure(inner: inner(), sheet: sheet(vc.getAdjustedHeight()))
        vc.overrideAnimationConfig(animationConfig)
        return vc
    }
    
    public func updateUIViewController(_ uiViewController: CoverSheetController<ViewManager>, context: Context) {
        uiViewController.updateViews(inner: inner(), sheet: sheet(uiViewController.getAdjustedHeight()))
        uiViewController.updateSheet(shouldBlur: useBlurEffect, backgroundColor: sheetColor)
        uiViewController.overrideAnimationConfig(animationConfig)
    }
}

// MARK: View Modifiers
public extension CoverSheetView {
    func enableBlurEffect(_ bool: Bool) -> Self {
        var view = self
        view.useBlurEffect = bool
        return view
    }
    
    func animationOptions(_ timing: CGFloat,
                          options: UIView.AnimationOptions = [.curveLinear, .allowUserInteraction],
                          springDampening: CGFloat = 2.0,
                          springVelocity: CGFloat = 7.0) -> Self {
        var view = self
        view.animationConfig = AnimationConfig(timing: timing,
                                               options: options,
                                               springDamping: springDampening,
                                               springVelocity: springVelocity)
        return view
    }
    
    func sheetBackgroundColor(_ color: Color) -> Self {
        var view = self
        view.sheetColor = color.uiColor()
        return view
    }
}
