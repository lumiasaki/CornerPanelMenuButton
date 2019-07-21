//
//  FocusBezierPathDrawable.swift
//  CornerPanelMenuButton
//
//  Created by tianren.zhu on 2019/07/21.
//  Copyright © 2019 tianren.zhu. All rights reserved.
//

import UIKit
import Foundation

protocol FocusBezierPathDrawable: class {
    func focusedBezierPath() -> UIBezierPath?
}

extension FocusBezierPathDrawable where Self: UIView {
    func focusedBezierPath() -> UIBezierPath? {
        if let originInWindow: CGPoint = self.superview?.convert(self.frame.origin, to: nil) {
            return UIBezierPath(rect: CGRect(origin: originInWindow, size: self.bounds.size))
        }
        
        return nil
    }
}
