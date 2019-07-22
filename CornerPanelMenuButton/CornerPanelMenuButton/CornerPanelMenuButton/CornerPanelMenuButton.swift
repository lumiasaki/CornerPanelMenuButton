//
//  CornerPanelMenuButton.swift
//  CornerPanelMenuButton
//
//  Created by tianren.zhu on 2019/07/21.
//  Copyright © 2019 tianren.zhu. All rights reserved.
//

import UIKit
import Foundation

@IBDesignable
class CornerPanelMenuButton: UIButton, PanelMenu {
    
    // MARK: IBInspectables
    
    @IBInspectable var corner: String {
        get {
            return panelSettings.cornerSettings.rawValue
        }
        
        set {
            panelSettings.cornerSettings = PanelMenuSettings.CornerEnum(rawValue: newValue) ?? .topRight
        }
    }
    
    @IBInspectable var radius: CGFloat {
        get {
            return panelSettings.circleSettings.radius
        }
        
        set {
            panelSettings.circleSettings.radius = newValue
        }
    }
    
    @IBInspectable var panelColor: UIColor {
        get {
            return panelSettings.circleSettings.color
        }
        
        set {
            panelSettings.circleSettings.color = newValue
        }
    }
    
    @IBInspectable var dimmable: Bool {
        get {
            return panelSettings.dimSettings.enable
        }
        
        set {
            panelSettings.dimSettings.enable = newValue
        }
    }
    
    @IBInspectable var dimColor: UIColor {
        get {
            return panelSettings.dimSettings.color
        }
        
        set {
            panelSettings.dimSettings.color = newValue
        }
    }
    
    @IBInspectable var duration: TimeInterval {
        get {
            return panelSettings.dimSettings.duration
        }
        
        set {
            panelSettings.dimSettings.duration = newValue
        }
    }
    
    @IBInspectable var titleFontSize: CGFloat {
        get {
            return panelSettings.titleSettings.font.pointSize
        }
        
        set {
            panelSettings.titleSettings.font = UIFont.systemFont(ofSize: newValue)
        }
    }
    
    @IBInspectable var titleColor: UIColor {
        get {
            return panelSettings.titleSettings.color
        }
        
        set {
            panelSettings.titleSettings.color = newValue
        }
    }
    
    // MARK: Menu
    
    var isShown: Bool {
        get {
            return dimView != nil
        }
    }
    
    var menuItems: [MenuItem]?
    
    func showMenu(on window: UIWindow?) {
        guard let _ = menuItems, let window = window, isShown == false else {
            return
        }
        
        var dimSettings: DimSettings = .defaultSettings
        
        // if not enable, just makes it looks like disabled with clear color
        dimSettings.color = panelSettings.dimSettings.enable ? panelSettings.dimSettings.color : .clear
        dimSettings.duration = panelSettings.dimSettings.duration
        
        if let path: UIBezierPath = focusedBezierPath() {
            dimSettings.path = path
        }
        
        self.dim(on: window, settings: dimSettings) { (dimView) in
            let view = self.createContainerView(dimView)
            
            dimView.addSubview(view)
        }
    }
    
    
    func dismissMenu() {
        dismissDimView()
        dimView = nil
        internalMenuItemDrawingInfos.removeAll()
    }
    
    // MARK: PanelMenu
    
    var panelSettings: PanelMenuSettings = PanelMenuSettings.defaultSettings(in: UIScreen.main.bounds.size) {
        willSet {
            dismissMenu()
        }
    }
    
    // MARK: FocusBezierPathDrawable
    
    func focusedBezierPath() -> UIBezierPath? {
        if let focusedBezierPath: UIBezierPath = customFocusedBezierPath {
            return focusedBezierPath
        }
        
        if let originInWindow: CGPoint = self.superview?.convert(self.frame.origin, to: nil) {
            return UIBezierPath(rect: CGRect(origin: originInWindow, size: self.bounds.size))
        }
        
        return nil
    }
    
    // MARK: Override UITouch Methods
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // don't call super here for avoiding button's default behavior ( title label fade )
        self.showMenu(on: self.superview?.window)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
        if let touch: UITouch = touches.first, touch.previousLocation(in: nil) != touch.location(in: nil) {
            itemOn(point: touch.location(in: nil)) { (index, menuItem) in
                guard let index = index, let menuItem = menuItem else {
                    for (_, menuItemInfo) in internalMenuItemDrawingInfos.enumerated() {
                        menuItemInfo.layer.fillColor = panelSettings.circleSettings.color.cgColor
                    }
                    
                    return
                }
                
                for (menuItemInfoIndex, menuItemInfo) in internalMenuItemDrawingInfos.enumerated() {
                    menuItemInfo.layer.fillColor = menuItemInfoIndex != index ? panelSettings.circleSettings.color.cgColor : menuItem.backgroundColor.cgColor
                }
                
                if currentHighlightedIndex != index {
                    currentHighlightedIndex = index
                    
                    highlightedBlock?(index, menuItem)
                }
            }
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        
        cancellationBlock?()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let point: CGPoint? = touches.first?.location(in: nil)
        
        if let point = point {
            itemOn(point: point) { (index, menuItem) in
                guard let index = index, let menuItem = menuItem else {
                    cancellationBlock?()
                    
                    return
                }
                
                selectionBlock?(index, menuItem)
            }
            
            self.dismissMenu()
        }
    }
    
    // MARK: Private
    
    private var currentHighlightedIndex: Int?
    
    private struct InternalMenuItemDrawingInfo {
        var layer: CAShapeLayer
        var startAngle: CGFloat
        var endAngle: CGFloat
    }
    
    private var internalMenuItemDrawingInfos: [InternalMenuItemDrawingInfo] = [InternalMenuItemDrawingInfo]()
    
    private func createContainerView(_ containerView: UIView) -> UIView {
        let view: UIView = UIView.init(frame: containerView.bounds)
        view.backgroundColor = panelSettings.circleSettings.color
        
        let maskLayer: CAShapeLayer = CAShapeLayer.init()
        maskLayer.fillRule = .evenOdd
        
        let path: UIBezierPath = UIBezierPath.init(arcCenter: panelSettings.circleSettings.center, radius: panelSettings.circleSettings.radius, startAngle: CGFloat(0), endAngle: CGFloat.pi * 2, clockwise: true)
        
        // if we can make a hole to let the button appear on panel menu, we need append the focusedBezierPath
        if let focusedBezierPath: UIBezierPath = focusedBezierPath() {
            path.append(focusedBezierPath)
        }
        
        maskLayer.path = path.cgPath
        
        view.layer.mask = maskLayer
        
        drawMenuItems(on: view)
        
        return view
    }
    
    private func drawMenuItems(on view: UIView) {
        guard let menuItems = menuItems else {
            return
        }
        
        func angles(for menuItem: MenuItem, at index: Int) -> (startAngle: CGFloat, endAngle: CGFloat) {
            let anglePerItem: CGFloat = (CGFloat.pi / 2) / CGFloat(menuItems.count)
            
            var startAngle: CGFloat = 0
            
            switch panelSettings.cornerSettings {
            case .topLeft:
                startAngle = CGFloat(index) * anglePerItem
            case .topRight:
                startAngle = CGFloat.pi - (CGFloat(index) + 1) * anglePerItem
            case .bottomLeft:
                startAngle = -0.5 * CGFloat.pi + CGFloat(index) * anglePerItem
            case .bottomRight:
                startAngle = -0.5 * CGFloat.pi - (CGFloat(index) + 1) * anglePerItem
            }
            
            let endAngle: CGFloat = startAngle + anglePerItem
            
            return (startAngle, endAngle)
        }
        
        for (index, menuItem) in menuItems.enumerated() {
            let menuItemLayer: CAShapeLayer = CAShapeLayer.init()
            menuItemLayer.fillColor = UIColor.clear.cgColor
            menuItemLayer.strokeColor = UIColor.white.cgColor
            
            let (startAngle, endAngle) = angles(for: menuItem, at: index)
            
            let path: UIBezierPath = UIBezierPath.init()
            path.move(to: panelSettings.circleSettings.center)
            path.addArc(withCenter: panelSettings.circleSettings.center, radius: panelSettings.circleSettings.radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
            path.close()
            
            menuItemLayer.path = path.cgPath
            
            internalMenuItemDrawingInfos.append(InternalMenuItemDrawingInfo(layer: menuItemLayer, startAngle: startAngle, endAngle: endAngle))
            
            view.layer.addSublayer(menuItemLayer)
            
            let originalAnimationsEnabledValue: Bool = UIView.areAnimationsEnabled
            UIView.setAnimationsEnabled(false)
            addTitle(menuItem.title, on: view, index: index, startAngle: startAngle, endAngle: endAngle)
            UIView.setAnimationsEnabled(originalAnimationsEnabledValue)
        }
    }
    
    private func itemOn(point: CGPoint, completionHandler: ((Int?, MenuItem?) -> ())) {
        func itemInfoOn(point: CGPoint) -> (Int, MenuItem)? {
            guard let menuItems = menuItems, internalMenuItemDrawingInfos.count != 0 else {
                return nil
            }
            
            let a: CGFloat = { () -> CGFloat in
                switch panelSettings.cornerSettings {
                case .topLeft, .topRight:
                    return point.y
                case .bottomLeft, .bottomRight:
                    return UIScreen.main.bounds.height - point.y
                }
            }()
            
            let b: CGFloat = { () -> CGFloat in
                switch panelSettings.cornerSettings {
                case .topLeft, .bottomLeft:
                    return point.x
                case .topRight, .bottomRight:
                    return UIScreen.main.bounds.width - point.x
                }
            }()
            
            let c: CGFloat = sqrt(a * a + b * b)
            
            if c > panelSettings.circleSettings.radius {
                return nil
            }
            
            let angle: CGFloat = acos(((a * a) + ( c * c ) - ( b * b )) / (( 2 * a * c)))
            
            for (index, menuItemInfo) in internalMenuItemDrawingInfos.enumerated() {
                var correctedAngleInSpecificAxisSystem: CGFloat = 0
                switch panelSettings.cornerSettings {
                case .topLeft:
                    correctedAngleInSpecificAxisSystem = 0.5 * CGFloat.pi - angle
                case .topRight:
                    correctedAngleInSpecificAxisSystem = CGFloat.pi - (0.5 * CGFloat.pi - angle)
                case .bottomLeft:
                    correctedAngleInSpecificAxisSystem = -0.5 * CGFloat.pi + angle
                case .bottomRight:
                    correctedAngleInSpecificAxisSystem = -0.5 * CGFloat.pi - angle
                }
                
                if (correctedAngleInSpecificAxisSystem <= menuItemInfo.endAngle && correctedAngleInSpecificAxisSystem >= menuItemInfo.startAngle) || (correctedAngleInSpecificAxisSystem >= menuItemInfo.endAngle && correctedAngleInSpecificAxisSystem <= menuItemInfo.startAngle) {
                    return (index, menuItems[index])
                }
            }
            
            return nil
        }
        
        guard let (index, menuItem) = itemInfoOn(point: point) else {
            completionHandler(nil, nil)
            return
        }
        
        completionHandler(index, menuItem)
    }
    
    private func addTitle(_ text: String, on containerView: UIView, index: Int, startAngle: CGFloat, endAngle: CGFloat) {
        func centerOfTitle() -> CGPoint {
            let halfAngleOfPerItem: CGFloat = (max(endAngle, startAngle) - min(endAngle, startAngle)) / CGFloat(2)
            
            var targetAngle: CGFloat = 0
            
            var shouldBeMinusedByWidth: Bool = false
            var shouldBeMinusedByHeight: Bool = false
            
            switch panelSettings.cornerSettings {
            case .topLeft:
                targetAngle = CGFloat(index) * 2 * halfAngleOfPerItem + halfAngleOfPerItem
                
                shouldBeMinusedByWidth = false
                shouldBeMinusedByHeight = false
            case .topRight:
                targetAngle = CGFloat.pi - halfAngleOfPerItem - CGFloat(index) * 2 * halfAngleOfPerItem
                
                shouldBeMinusedByWidth = true
                shouldBeMinusedByHeight = false
            case .bottomLeft:
                targetAngle = -CGFloat.pi / 2 + CGFloat(index) * 2 * halfAngleOfPerItem + halfAngleOfPerItem
                
                shouldBeMinusedByWidth = false
                shouldBeMinusedByHeight = true
            case .bottomRight:
                targetAngle = -CGFloat.pi / 2 - CGFloat(index) * 2 * halfAngleOfPerItem - halfAngleOfPerItem
                
                shouldBeMinusedByWidth = true
                shouldBeMinusedByHeight = true
            }
            
            var x: CGFloat = abs((2 * panelSettings.circleSettings.radius / 3) * cos(targetAngle))
            var y: CGFloat = abs((2 * panelSettings.circleSettings.radius / 3) * sin(targetAngle))
            
            if shouldBeMinusedByWidth {
                x = UIScreen.main.bounds.width - x
            }
            
            if shouldBeMinusedByHeight {
                y = UIScreen.main.bounds.height - y
            }
            
            return CGPoint(x: x, y: y)
        }
        
        
        let titleFont: UIFont = panelSettings.titleSettings.font
        let textSize: CGSize = text.size(withAttributes: [.font : titleFont])
        
        let textLabel: UILabel = UILabel.init()
        
        let center: CGPoint = centerOfTitle()
        
        textLabel.center = center
        textLabel.bounds.size = textSize
        
        textLabel.text = text
        textLabel.textColor = panelSettings.titleSettings.color
        textLabel.font = titleFont
        
        containerView.addSubview(textLabel)
    }
}
