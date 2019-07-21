//
//  Dimmable.swift
//  CornerPanelMenuButton
//
//  Created by tianren.zhu on 2019/07/21.
//  Copyright © 2019 tianren.zhu. All rights reserved.
//

import UIKit
import Foundation

struct DimSettings {
    var color: UIColor
    var animated: Bool
    var duration: TimeInterval?
    var path: UIBezierPath?
}

private struct AssociatedObjectKey {
    static var dimViewKey: Void?
    static var dimSettingsKey: Void?
}

extension DimSettings {
    static let defaultSettings = DimSettings(color: UIColor.init(white: 0, alpha: 0.5),
                                             animated: true,
                                             duration: 2,
                                             path: nil)
}

protocol Dimmable: class {
    func dim(on window: UIWindow?, completion: ((UIView) -> Void)?)
    func dim(on window: UIWindow?, settings: DimSettings, completion: ((UIView) -> Void)?)
    func dismissDimView()
}

extension Dimmable {
    var dimView: UIView? {
        get {
            return objc_getAssociatedObject(self, &AssociatedObjectKey.dimViewKey) as? UIView
        }
        
        set {
            objc_setAssociatedObject(self, &AssociatedObjectKey.dimViewKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var dimSettings: DimSettings? {
        get {
            return objc_getAssociatedObject(self, &AssociatedObjectKey.dimSettingsKey) as? DimSettings
        }
        
        set {
            objc_setAssociatedObject(self, &AssociatedObjectKey.dimSettingsKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func dim(on window: UIWindow?, completion: ((UIView) -> Void)?) {
        dim(on: window, settings: .defaultSettings, completion: completion)
    }
    
    func dim(on window: UIWindow?, settings: DimSettings, completion: ((UIView) -> Void)?) {
        guard let window = window else {
            return
        }
        
        assert(Thread.current.isMainThread)
        
        dimSettings = settings
        
        let dimView = UIView(frame: UIScreen.main.bounds)
        dimView.backgroundColor = settings.color
        dimView.alpha = 0
        
        if let path: UIBezierPath = settings.path {
            let maskLayer: CAShapeLayer = CAShapeLayer.init()
            maskLayer.fillRule = .evenOdd
            
            let basePath: UIBezierPath = UIBezierPath(rect: window.bounds)
            basePath.append(path)
            
            maskLayer.path = basePath.cgPath
            
            dimView.layer.mask = maskLayer
        }
        
        self.dimView = dimView
        
        window.addSubview(dimView)
        
        UIView.animate(withDuration: settings.duration ?? 0) {
            dimView.alpha = 1
            
            completion?(dimView)
        }
    }
    
    func dismissDimView() {
        guard let dimView = dimView, dimView.superview != nil, let dimSettings = dimSettings else {
            return
        }
        
        UIView.animate(withDuration: dimSettings.duration ?? 0, animations: {
            dimView.alpha = 0
        }) { (finished) in
            dimView.removeFromSuperview()
        }
    }
}
