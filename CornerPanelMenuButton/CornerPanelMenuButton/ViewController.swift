//
//  ViewController.swift
//  CornerPanelMenuButton
//
//  Created by tianren.zhu on 2019/07/21.
//  Copyright © 2019 tianren.zhu. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var cornerPanelMenuButton: CornerPanelMenuButton! {
        didSet {
            var menuItems: [MenuItem] = [MenuItem]()
            menuItems.append(MenuItem(title: "Menu 1", backgroundColor: .red))
            menuItems.append(MenuItem(title: "Menu 2", backgroundColor: .blue))
            menuItems.append(MenuItem(title: "Menu 3", backgroundColor: .yellow))
            
            cornerPanelMenuButton.menuItems = menuItems
            
            cornerPanelMenuButton.selectionBlock = { (index: Int, menuItem: MenuItem) in
                print("selected: \(menuItem.title), index: \(index)")
            }
            cornerPanelMenuButton.highlightedBlock = { (index: Int, menuItem: MenuItem) in
                print("\(menuItem.title) highlighted, index: \(index)")
            }
            cornerPanelMenuButton.cancellationBlock = {
                print("canceled")
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func viewDidLayoutSubviews() {
        cornerPanelMenuButton.customFocusedBezierPath = UIBezierPath(arcCenter: cornerPanelMenuButton.center, radius: cornerPanelMenuButton.bounds.width / 2, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true)
    }

}

