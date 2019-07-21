//
//  MenuShowable.swift
//  CornerPanelMenuButton
//
//  Created by tianren.zhu on 2019/07/21.
//  Copyright © 2019 tianren.zhu. All rights reserved.
//

import UIKit
import Foundation

struct MenuItem {
    var title: String    
    var backgroundColor: UIColor
}

private struct AssociatedObjectKey {
    static var selectionBlockKey: Void?
    static var cancellationBlockKey: Void?
}

typealias MenuAbility = Menu & MenuShowable & MenuDismissable

protocol MenuShowable: class {
    func showMenu(on window: UIWindow?)
}

protocol MenuDismissable: class {
    func dismissMenu()
}

protocol Menu: class {
    var isShown: Bool { get }
    var menuItems: [MenuItem]? { get set }
}

extension Menu {
    var selectionBlock: ((Int, MenuItem) -> ())? {
        get {
            return objc_getAssociatedObject(self, &AssociatedObjectKey.selectionBlockKey) as? (Int, MenuItem) -> ()
        }
        
        set {
            objc_setAssociatedObject(self, &AssociatedObjectKey.selectionBlockKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
    var cancellationBlock: (() -> ())? {
        get {
            return objc_getAssociatedObject(self, &AssociatedObjectKey.cancellationBlockKey) as? () -> ()
        }
        
        set {
            objc_setAssociatedObject(self, &AssociatedObjectKey.cancellationBlockKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
}
