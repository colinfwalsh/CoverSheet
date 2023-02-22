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
    var manager: ViewManager
    
    private var useBlurEffect: Bool
    
    private var sheetColor: UIColor
    
    @ViewBuilder
    public var inner: () -> Inner
    
    @ViewBuilder
    public var sheet: (CGFloat) -> Sheet
    
    public init(_ manager: ViewManager,
                useBlurEffect: Bool = true,
                sheetColor: UIColor = .white,
                _ inner: @escaping () -> Inner,
                sheet: @escaping (CGFloat) -> Sheet) {
        _manager = ObservedObject(wrappedValue: manager)
        self.useBlurEffect = useBlurEffect
        self.sheetColor = sheetColor
        self.inner = inner
        self.sheet = sheet
    }
    
    public func makeUIViewController(context: Context) -> CoverSheetController {
        let vc = CoverSheetController(manager: manager,
                                      states: manager.states,
                                      shouldUseEffect: useBlurEffect,
                                      sheetColor: sheetColor)
        vc.configure(inner: inner(), sheet: sheet(vc.getAdjustedHeight()))
        return vc
    }
    
    public func updateUIViewController(_ uiViewController: CoverSheetController, context: Context) {
        uiViewController.updateViews(inner: inner(), sheet: sheet(uiViewController.getAdjustedHeight()))
        uiViewController.updateSheet(shouldBlur: useBlurEffect, backgroundColor: sheetColor)
    }
}

public extension CoverSheetView {
    func enableBlurEffect(_ bool: Bool) -> Self {
        var view = self
        view.useBlurEffect = bool
        return view
    }
    
    func sheetBackgroundColor(_ color: Color) -> Self {
        var view = self
        view.sheetColor = color.uiColor()
        return view
    }
}
