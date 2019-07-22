//
//  PanelMenu.swift
//  CornerPanelMenuButton
//
//  Created by tianren.zhu on 2019/07/21.
//  Copyright © 2019 tianren.zhu. All rights reserved.
//

import UIKit
import Foundation

struct PanelMenuSettings {
    
    enum CornerEnum: String {
        case topLeft
        case topRight
        case bottomLeft
        case bottomRight
    }
    
    struct CircleSettings {
        fileprivate(set) var center: CGPoint
        fileprivate(set) var containerSize: CGSize
        var radius: CGFloat
        var color: UIColor
        
        init(containerSize: CGSize, corner: CornerEnum, color: UIColor) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            
            switch corner {
            case .topLeft:
                x = 0
                y = 0
            case .topRight:
                x = containerSize.width
                y = 0
            case .bottomLeft:
                x = 0
                y = containerSize.height
            case .bottomRight:
                x = containerSize.width
                y = containerSize.height
            }
            
            self.center = CGPoint(x: x, y: y)
            self.containerSize = containerSize
            self.radius = min(containerSize.height, containerSize.width)
            self.color = color
        }
    }
    
    struct DimSettings {
        var enable: Bool
        var color: UIColor
        var duration: TimeInterval
    }
    
    struct TitleSettings {
        var font: UIFont
        var color: UIColor
    }
    
    var cornerSettings: CornerEnum {
        willSet {
            self.circleSettings = CircleSettings(containerSize: self.circleSettings.containerSize, corner: newValue, color: self.circleSettings.color)
        }
    }
    var circleSettings: CircleSettings
    var dimSettings: DimSettings
    var titleSettings: TitleSettings
}

extension PanelMenuSettings {
    static func defaultSettings(in size: CGSize) -> PanelMenuSettings {
        let cornerSettings: CornerEnum = .topRight
        let circleSettings: CircleSettings = CircleSettings(containerSize: size, corner: cornerSettings, color: .lightGray)
        let dimSettings: DimSettings = DimSettings(enable: true, color: UIColor(white: 0, alpha: 0.5), duration: 0.14)
        let titleSettings: TitleSettings = TitleSettings(font: UIFont.systemFont(ofSize: 26), color: .white)
        
        return PanelMenuSettings(cornerSettings: cornerSettings, circleSettings: circleSettings, dimSettings: dimSettings, titleSettings: titleSettings)
    }
}

protocol PanelMenu: MenuAbility, Dimmable, FocusBezierPathDrawable {
    var panelSettings: PanelMenuSettings { get set }
}

private struct AssociatedObjectKey {
    static var highlightedBlockKey: Void?
    static var customFocusedBezierPath: Void?
}

extension PanelMenu {
    var highlightedBlock: ((Int, MenuItem) -> ())? {
        get {
            return objc_getAssociatedObject(self, &AssociatedObjectKey.highlightedBlockKey) as? (Int, MenuItem) -> ()
        }
        
        set {
            objc_setAssociatedObject(self, &AssociatedObjectKey.highlightedBlockKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var customFocusedBezierPath: UIBezierPath? {
        get {
            return objc_getAssociatedObject(self, &AssociatedObjectKey.customFocusedBezierPath) as? UIBezierPath
        }
        
        set {
            objc_setAssociatedObject(self, &AssociatedObjectKey.customFocusedBezierPath, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
