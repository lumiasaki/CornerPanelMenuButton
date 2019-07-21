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
        var center: CGPoint
        var radius: CGFloat
        var color: UIColor
        
        init(corner: CornerEnum, color: UIColor) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            
            switch corner {
            case .topLeft:
                x = 0
                y = 0
            case .topRight:
                x = UIScreen.main.bounds.width
                y = 0
            case .bottomLeft:
                x = 0
                y = UIScreen.main.bounds.height
            case .bottomRight:
                x = UIScreen.main.bounds.width
                y = UIScreen.main.bounds.height
            }
            
            self.center = CGPoint(x: x, y: y)
            self.radius = min(UIScreen.main.bounds.height, UIScreen.main.bounds.width)
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
            var x: CGFloat = 0
            var y: CGFloat = 0
            
            switch newValue {
            case .topLeft:
                x = 0
                y = 0
            case .topRight:
                x = UIScreen.main.bounds.width
                y = 0
            case .bottomLeft:
                x = 0
                y = UIScreen.main.bounds.height
            case .bottomRight:
                x = UIScreen.main.bounds.width
                y = UIScreen.main.bounds.height
            }
            
            self.circleSettings.center = CGPoint(x: x, y: y)
        }
    }
    var circleSettings: CircleSettings
    var dimSettings: DimSettings
    var titleSettings: TitleSettings
}

extension PanelMenuSettings {
    static let defaultSettings = { () -> PanelMenuSettings in
        let cornerSettings: CornerEnum = .topRight
        let circleSettings: CircleSettings = CircleSettings(corner: cornerSettings, color: .lightGray)
        let dimSettings: DimSettings = DimSettings(enable: true, color: UIColor(white: 0, alpha: 0.5), duration: 0.14)
        let titleSettings: TitleSettings = TitleSettings(font: UIFont.systemFont(ofSize: 26), color: .white)
        
        return PanelMenuSettings(cornerSettings: cornerSettings, circleSettings: circleSettings, dimSettings: dimSettings, titleSettings: titleSettings)
    }()
}

protocol PanelMenu: MenuAbility, Dimmable, FocusBezierPathDrawable {
    var panelSettings: PanelMenuSettings { get set }
}

private struct AssociatedObjectKey {
    static var highlightedBlockKey: Void?
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
}
