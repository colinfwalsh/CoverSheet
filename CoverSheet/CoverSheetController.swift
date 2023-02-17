//
//  ContentViewController.swift
//  KnightTransporter
//
//  Created by Colin Walsh on 2/6/23.
//  Copyright © 2023 Colin Walsh. All rights reserved.
//

import UIKit
import SwiftUI
import Combine

public class CoverSheetController: UIViewController, UIGestureRecognizerDelegate {
    
    private let manager: any Manager
    
    private var isTransitioning: Bool = false
    
    private var cancellables: Set<AnyCancellable> = []
    
    init(manager: some Manager, states: [SheetState] = [.minimized, .normal, .full]) {
        self.manager = manager
        self.manager.states = states
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        self.manager = DefaultSheetManager()
        self.manager.states = []
        super.init(coder: coder)
    }
    
    private var insets: UIEdgeInsets {
        return UIApplication
            .shared
            .connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .compactMap { $0 as? UIWindowScene }
            .first?
            .windows
            .filter { $0.isKeyWindow }
            .first?
            .safeAreaInsets ?? .zero
    }
    
    private var offset: CGFloat {
        let maxHeight = self.view.frame.height - 100
        return maxHeight - (maxHeight * manager.stateConstant)
    }
    
    private lazy var handlePadding: UIView = {
        return UIView()
    }()
    
    private lazy var handle: UIView = {
        let view = UIView()
        view.backgroundColor = .red
        view.layer.cornerRadius = 5
        view.clipsToBounds = true
        
        return view
    }()
    
    private lazy var blurEffect: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .dark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        
        return blurView
    }()
    
    private lazy var sheetView: UIView = {
        let view = UIView(frame: .zero)
        
        view.insertSubview(blurEffect, at: 0)
        
        blurEffect.translatesAutoresizingMaskIntoConstraints = false
        
        let constraints = [
            blurEffect.topAnchor.constraint(equalTo: view.topAnchor),
            blurEffect.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            blurEffect.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            blurEffect.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
        
        view.layer.cornerRadius = 16.0
        blurEffect.layer.cornerRadius = 16.0
        blurEffect.clipsToBounds = true
        
        setupHandleBar(in: view)
        
        self.addChild(sheetContentViewController)
        
        view.insertSubview(sheetContentViewController.view, at: 1)
        
        setupSheetControllerConst(for: view)
        
        sheetContentViewController.didMove(toParent: self)
        
        setupGestureRecognizer(for: view)
        
        return view
    }()
    
    private lazy var innerContentViewController: ContainerViewController = {
        let vc = ContainerViewController()
        vc.view.backgroundColor = .clear
        
        return vc
    }()
    
    private lazy var sheetContentViewController: ContainerViewController = {
        let vc = ContainerViewController()
        vc.view.backgroundColor = .clear
        
        return vc
    }()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        setupInnerView()
        setupBottomSheet()
        
        manager
            .sheetPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self = self,
                      !self.isTransitioning
                else { return }
                
                self.animateSheet()
        }
        .store(in: &cancellables)
    }
}

// MARK: Public methods
extension CoverSheetController {
    public func configure(inner: UIViewController, sheet: UIViewController) {
        innerContentViewController.configure(inner)
        sheetContentViewController.configure(sheet)
    }
    
    public func configure(inner: some View, sheet: some View) {
        innerContentViewController.configure(inner)
        sheetContentViewController.configure(sheet)
    }
    
    public func updateViews(inner: some View, sheet: some View) {
        innerContentViewController.update(inner)
        sheetContentViewController.update(sheet)
    }
    
    public func getAdjustedHeight() -> CGFloat {
        return manager.stateConstant * view.frame.height
    }
}

// MARK: Gesture Recognizer Logic
extension CoverSheetController {
    private func setupGestureRecognizer(for view: UIView) {
        let gesture = UIPanGestureRecognizer(target: self,
                                             action: #selector(panGesture))
        view.addGestureRecognizer(gesture)
        gesture.delegate = self
    }
    
    @objc private func panGesture(_ recognizer: UIPanGestureRecognizer) {
        let point = recognizer.translation(in: self.view)
        let velocity = recognizer.velocity(in: self.view)
        
        if recognizer.state != .cancelled || recognizer.state != .ended {
            let offset = sheetView.frame.minY + point.y
            
            let frameHeight = view.frame.height
            let maxHeight = abs(frameHeight - (frameHeight * (manager.states.last?.rawValue ?? 0.0)))
            let minHeight = abs(frameHeight - (frameHeight * (manager.states.first?.rawValue ?? 0.0)))
            
            print(minHeight, maxHeight)
            guard offset >= maxHeight && offset <= minHeight
            else {
                let sheetPoint = CGPoint(x: sheetView.frame.minX, y: view.frame.height - sheetView.frame.minY)
                findNearestState(sheetPoint)
                return }
            
            sheetView.frame = CGRect(x: 0, y: offset, width: view.frame.width, height: view.frame.height)
            recognizer.setTranslation(.zero, in: self.view)
        }
        
        guard recognizer.state == .ended
        else { return }
        
        let absVelocity = abs(velocity.y)
        guard absVelocity <= 500
        else {
            cycleStates(velocity)
            return }
        
        let sheetPoint = CGPoint(x: sheetView.frame.minX, y: view.frame.height - sheetView.frame.minY)
        findNearestState(sheetPoint)
    }
    
    private func cycleStates(_ velocity: CGPoint) {
        let direction = velocity.y
        
        var position = manager.states.firstIndex(of: manager.sheetState) ?? 0
        
        if direction < 0 {
            position = position == manager.states.count-1 ? position : (position+1)
        } else {
            position = position == 0 ? position : (position-1)
        }
        
        manager.sheetState = manager.states[position]
    }
    
    private func findNearestState(_ point: CGPoint) {
        var min: CGFloat = CGFloat(Int.max)
        var finalState: SheetState = manager.sheetState
        
        manager.states.forEach {
            let height = view.frame.height * $0.rawValue
            
            let diff = abs(height - point.y)
            
            if diff < min {
                min = diff
                finalState = $0
            }
        }
        
        manager.sheetState = finalState
    }
}

// MARK: Animations
extension CoverSheetController {
    private func animateSheet() {
        isTransitioning = true
        
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn) { [manager, sheetView, superFrame = view.frame] in
            let finalHeight = (superFrame.height) * manager.stateConstant
            let diffHeight = superFrame.height - finalHeight
            sheetView.frame = CGRect(x: 0, y: diffHeight, width: superFrame.width, height: superFrame.height)
        } completion: { [weak self] _ in
            guard let self = self
            else { return }
            
            DispatchQueue.main.async {
                self.isTransitioning = false
            }
            
            if self.manager.sheetState == .fullScreen && self.sheetView.layer.cornerRadius > 0 {
                self.animateAllCorners(from: 16.0, to: 0.0, duration: 0.2)
            } else if self.manager.sheetState != .fullScreen {
                if self.sheetView.layer.cornerRadius == 0 {
                    self.animateAllCorners(from: 0.0, to: 16.0, duration: 0.2)
                }
            }
        }
    }
    
    private func animateAllCorners(from: CGFloat, to: CGFloat, duration: CFTimeInterval) {
        self.animateCornerRadius(in: self.sheetView, from: from, to: to, duration: duration)
        self.animateCornerRadius(in: self.blurEffect, from: from, to: to, duration: duration)
    }
    
    private func animateCornerRadius(in view: UIView, from: CGFloat, to: CGFloat, duration: CFTimeInterval) {
        CATransaction.begin()
        let animation = CABasicAnimation(keyPath: "cornerRadius")
        let hiddenAnimation = CABasicAnimation(keyPath: "hidden")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)
        animation.fromValue = from
        animation.toValue = to
        animation.duration = duration
        
        hiddenAnimation.fromValue = from == 16.0 ? 1.0 : 0.0
        hiddenAnimation.toValue = to == 16.0 ? 0.0 : 1.0
        hiddenAnimation.duration = duration
        
        handle.layer.add(hiddenAnimation, forKey: "hidden")
        view.layer.add(animation, forKey: "cornerRadius")
        
        CATransaction.setCompletionBlock { [weak self] in
            guard let self = self
            else { return }
            
            view.layer.cornerRadius = to
            self.handle.layer.isHidden = from == 16.0
        }
        
        CATransaction.commit()
    }
}

// MARK: Constraints and Positioning
extension CoverSheetController {
    
    private func setupHandleBar(in view: UIView) {
        view.addSubview(handlePadding)
        
        handlePadding.addSubview(handle)
        handlePadding.backgroundColor = .clear
        
        setupHandlePaddingConstraints(for: handlePadding, with: view)
        setupHandleConstraints(for: handle, with: handlePadding)
    }
    
    private func setupHandlePaddingConstraints(for handlePadding: UIView, with view: UIView) {
        handlePadding.translatesAutoresizingMaskIntoConstraints = false
        
        let constraints = [
            NSLayoutConstraint(item: handlePadding,
                               attribute: .height,
                               relatedBy: .equal,
                               toItem: nil,
                               attribute: .notAnAttribute,
                               multiplier: 1,
                               constant: 50),
            handlePadding.topAnchor.constraint(equalTo: view.topAnchor),
            handlePadding.leftAnchor.constraint(equalTo: view.leftAnchor),
            handlePadding.rightAnchor.constraint(equalTo: view.rightAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    private func setupHandleConstraints(for handle: UIView, with handlePadding: UIView) {
        handle.translatesAutoresizingMaskIntoConstraints = false
        
        let constraints = [
            NSLayoutConstraint(item: handle,
                               attribute: .height,
                               relatedBy: .equal,
                               toItem: nil,
                               attribute: .notAnAttribute,
                               multiplier: 1,
                               constant: 10),
            NSLayoutConstraint(item: handle,
                               attribute: .width,
                               relatedBy: .equal,
                               toItem: nil,
                               attribute: .notAnAttribute,
                               multiplier: 1,
                               constant: 50),
            handle.centerXAnchor.constraint(equalTo: handlePadding.centerXAnchor),
            handle.topAnchor.constraint(equalTo: handlePadding.topAnchor, constant: 25)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    private func setupSheetControllerConst(for view: UIView) {
        guard let sheetView = sheetContentViewController.view
        else { return }
        
        sheetView.translatesAutoresizingMaskIntoConstraints = false
        
        let constraints = [
            sheetView.topAnchor.constraint(equalTo: self.handlePadding.bottomAnchor, constant: 0),
            sheetView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            sheetView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            sheetView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    private func setupInnerView() {
        self.addChild(innerContentViewController)
        view.addSubview(innerContentViewController.view)
        
        guard let innerView = innerContentViewController.view
        else { return }
        
        innerView.translatesAutoresizingMaskIntoConstraints = false
        
        let constraints = [
            innerView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            innerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            innerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            innerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
        ]
        
        NSLayoutConstraint.activate(constraints)
        
        innerContentViewController.didMove(toParent: self)
    }
    
    private func setupBottomSheet() {
        self.view.addSubview(sheetView)
        animateSheet()
    }
}

// MARK: SwiftUI ViewRepresentable
public struct CoverSheetView<Inner: View, Sheet: View, ViewManager: Manager>: UIViewControllerRepresentable {
    @ObservedObject
    var manager: ViewManager
    
    @ViewBuilder
    public var inner: () -> Inner
    
    @ViewBuilder
    public var sheet: (CGFloat) -> Sheet
    
    public init(_ manager: ViewManager,
                _ inner: @escaping () -> Inner,
                sheet: @escaping (CGFloat) -> Sheet) {
        _manager = ObservedObject(wrappedValue: manager)
        self.inner = inner
        self.sheet = sheet
    }
    
    public func makeUIViewController(context: Context) -> CoverSheetController {
        let vc = CoverSheetController(manager: manager, states: manager.states)
        vc.configure(inner: inner(), sheet: sheet(vc.getAdjustedHeight()))
        return vc
    }
    
    public func updateUIViewController(_ uiViewController: CoverSheetController, context: Context) {
        uiViewController.updateViews(inner: inner(), sheet: sheet(uiViewController.getAdjustedHeight()))
    }
}
