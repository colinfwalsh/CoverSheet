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

open class CoverSheetController<ViewManager: Manager,
                                EnumValue: RawRepresentable & Equatable>: UIViewController,
                                                                          UIGestureRecognizerDelegate where EnumValue.RawValue == CGFloat {
    
    @ObservedObject
    private var manager: ViewManager = ViewManager()
    
    private var states: [EnumValue] = []
    
    private var isTransitioning: Bool = false
    
    private var blurEffectEnabled: Bool = false
    
    private var sheetColor: UIColor = .clear
    
    private var cancellables: Set<AnyCancellable> = []
    
    private var animationConfig: AnimationConfig = AnimationConfig()
    
    public weak var delegate: CoverSheetDelegate?
    
    public init(states: [EnumValue] = [],
                shouldUseEffect: Bool = false,
                sheetColor: UIColor = .white) {
        self.states = states.sorted(by: { $0.rawValue < $1.rawValue} )
        self.blurEffectEnabled = shouldUseEffect
        self.sheetColor = sheetColor
        super.init(nibName: nil, bundle: nil)
    }
    
    public convenience init(manager: ViewManager,
                            states: [EnumValue],
                            shouldUseEffect: Bool = false,
                            sheetColor: UIColor = .white) {
        self.init(states: states)
        self.manager = manager
        self.blurEffectEnabled = shouldUseEffect
        self.sheetColor = sheetColor
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        self.states = []
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
        return maxHeight - (maxHeight * manager.currentState.rawValue)
    }
    
    private lazy var handlePadding: UIView = {
        return UIView()
    }()
    
    private lazy var handle: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        view.layer.cornerRadius = 2.5
        view.clipsToBounds = true
        
        return view
    }()
    
    private lazy var blurEffect: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .regular)
        let blurView = UIVisualEffectView(effect: blurEffect)
        
        return blurView
    }()
    
    private lazy var sheetView: UIView = {
        let view = UIView(frame: .zero)
        
        setupBlurEffect(in: view)
        
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
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        setupInnerView()
        setupBottomSheet()
        
        setupObservers()
    }
    
    private func setupObservers() {
        cancellables.removeAll()
        
        manager
            .currentStatePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                guard let self = self
                else { return }
                
                let newHeight = self.view.frame.height * $0.rawValue
                self.delegate?.coverSheet(sheetHeight: newHeight)
                
                guard !self.isTransitioning
                else { return }
                
                self.animateSheet()
            }
            .store(in: &cancellables)
    }
    
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
            let maxHeight = abs(frameHeight - (frameHeight * (states.last?.rawValue ?? 0.0)))
            
            guard offset >= maxHeight
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
        guard let current = manager.currentState as? EnumValue
        else { return }
        
        let direction = velocity.y
        
        var position = states.firstIndex(of: current) ?? 0
        
        if direction < 0 {
            position = position == states.count-1 ? position : (position+1)
        } else {
            position = position == 0 ? position : (position-1)
        }
        
        guard let newState = states[position] as? ViewManager.EnumValue
        else { return }
        
        manager.currentState = newState
    }
    
    private func findNearestState(_ point: CGPoint) {
        var min: CGFloat = CGFloat(Int.max)
        
        guard var finalState: EnumValue = manager.currentState as? EnumValue
        else { return }
        
        states.forEach {
            let height = view.frame.height * $0.rawValue
            
            let diff = abs(height - point.y)
            
            if diff < min {
                min = diff
                finalState = $0
            }
        }
        
        guard let final = finalState as? ViewManager.EnumValue
        else { return }
        
        manager.currentState = final
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
    
    /** Update the current state.  If the state is not present in the state array, it'll add the value and sort the new state array. */
    public func updateCurrentState(_ newState: EnumValue) {
        guard let updateValue = newState as? ViewManager.EnumValue
        else { return }
        
        if states.contains(newState) {
            self.manager.currentState = updateValue
        } else {
            states.append(newState)
            states = states.sorted(by: { $0.rawValue < $1.rawValue })
            self.manager.currentState = updateValue
        }
    }
    
    public func overrideManager(_ manager: ViewManager) {
        self.manager = manager
        setupObservers()
    }
    
    public func overrideStates(_ states: [EnumValue]) {
        let sorted = states.sorted(by: { $0.rawValue < $1.rawValue })
        self.states = sorted
    }
    
    public func overrideAnimationConfig(_ config: AnimationConfig) {
        self.animationConfig = config
    }
    
    public func overrideAnimationValues(timing: CGFloat = 0.1,
                                        options: UIView.AnimationOptions = [.curveLinear],
                                        springDamping: CGFloat = 2.0,
                                        springVelocity: CGFloat = 7.0) {
        self.animationConfig = AnimationConfig(timing: timing,
                                               options: options,
                                               springDamping: springDamping,
                                               springVelocity: springVelocity)
    }
    
    public func updateSheet(shouldBlur: Bool, backgroundColor: UIColor) {
        self.blurEffectEnabled = shouldBlur
        
        if shouldBlur {
            addBlur(to: sheetView)
        } else {
            removeBlur()
        }
        
        sheetView.backgroundColor = backgroundColor
    }
}

// MARK: Public helper methods
extension CoverSheetController {
    private func removeBlur() {
        handlePadding.alpha = 1.0
        blurEffect.removeFromSuperview()
    }
    
    private func addBlur(to view: UIView) {
        if !view.subviews.contains(blurEffect) {
            setupBlurEffect(in: view)
        }
    }
}

// MARK: Animations
extension CoverSheetController {
    private func animateSheet() {
        isTransitioning = true
        UIView.animate(withDuration: animationConfig.timing,
                       delay: 0,
                       usingSpringWithDamping: animationConfig.springDamping,
                       initialSpringVelocity: animationConfig.springVelocity,
                       options: animationConfig.options) { [currentState = manager.currentState, sheetView, superFrame = view.frame] in
            let finalHeight = (superFrame.height) * currentState.rawValue
            let diffHeight = superFrame.height - finalHeight
            sheetView.frame = CGRect(x: 0, y: diffHeight, width: superFrame.width, height: superFrame.height)
        } completion: { [weak self, timing = animationConfig.timing] _ in
            guard let self = self
            else { return }
            
            DispatchQueue.main.async {
                self.isTransitioning = false
                if self.manager.currentState.rawValue == 1.0 && self.sheetView.layer.cornerRadius > 0 {
                    self.animateAllCorners(from: 16.0, to: 0.0, duration: timing)
                } else if self.manager.currentState.rawValue != 1.0 {
                    if self.sheetView.layer.cornerRadius == 0 {
                        self.animateAllCorners(from: 0.0, to: 16.0, duration: timing)
                    }
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
    
    private func setupBlurEffect(in view: UIView) {
        view.insertSubview(blurEffect, at: 0)
        
        blurEffect.translatesAutoresizingMaskIntoConstraints = false
        
        handlePadding.alpha = 0.5
        
        let constraints = [
            blurEffect.topAnchor.constraint(equalTo: view.topAnchor),
            blurEffect.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            blurEffect.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            blurEffect.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    private func setupHandleBar(in view: UIView) {
        view.addSubview(handlePadding)
        
        handlePadding.addSubview(handle)
        handlePadding.backgroundColor = .clear
        
        setupHandlePaddingConstraints(for: handlePadding, with: view)
        setupHandleConstraints(for: handle, with: handlePadding)
    }
    
    private func setupHandlePaddingConstraints(for handlePadding: UIView, with view: UIView) {
        handlePadding.translatesAutoresizingMaskIntoConstraints = false
        
        let handleHeight = NSLayoutConstraint(item: handlePadding,
                                              attribute: .height,
                                              relatedBy: .equal,
                                              toItem: nil,
                                              attribute: .notAnAttribute,
                                              multiplier: 1,
                                              constant: 15)
        
        handleHeight.priority = .defaultLow
        
        let constraints = [
            handleHeight,
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
                               constant: 5),
            NSLayoutConstraint(item: handle,
                               attribute: .width,
                               relatedBy: .equal,
                               toItem: nil,
                               attribute: .notAnAttribute,
                               multiplier: 1,
                               constant: 50),
            handle.centerXAnchor.constraint(equalTo: handlePadding.centerXAnchor),
            handle.topAnchor.constraint(equalTo: handlePadding.topAnchor, constant: 10)
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
        let frameHeight = view.frame.height * manager.currentState.rawValue
        sheetView.frame = CGRect(x: 0,
                                 y: view.frame.height - frameHeight,
                                 width: view.frame.width,
                                 height: view.frame.height)
    }
}
