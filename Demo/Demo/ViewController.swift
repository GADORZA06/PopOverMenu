//
//  ViewController.swift
//  Demo
//
//  Created by user1 on 13/03/2018.
//  Copyright © 2018 Smartwave. All rights reserved.
//

import UIKit
import PopOverMenuComponent

class ViewController: UIViewController {
    let button = UIButton()
    var selectedRows: Set<Int> = Set<Int>()
    override func viewDidLoad() {
        super.viewDidLoad()
        button.setTitle("Press Me", for: UIControlState.normal)
        button.setTitleColor(UIColor.black, for: UIControlState.normal)
        button.frame = CGRect(x: 32, y: 32, width: 128, height: 64)
        button.addTarget(self, action: #selector(buttonPressed), for: UIControlEvents.touchDown)
        self.view.addSubview(button)
    }

    @objc func buttonPressed() {
        print("Button Pressed!")
        
        let popup = PopOverViewController.instantiate(withSourceView: button)
        
        popup.setTitles(["Bob", "Ray", "Charlie", "Alpha", "Delta"])
        popup.selectRows(self.selectedRows)
        popup.setImageNames(["location", "location", "location", "location", "location"])
        popup.setSelectedImageNames(["play", "play", "play", "play", "play"])
        popup.setTitleColor(UIColor.blue)
        popup.setSelectedTitleColor(UIColor.red)
        popup.completionHandler = { [unowned self] (selectRow: Int) in
            if self.selectedRows.contains(selectRow) {
                self.selectedRows.remove(selectRow)
            } else {
                self.selectedRows.insert(selectRow)
            }
        }
        
        popup.cornerRadius = 4
        
        present(popup, animated: true, completion: nil)
    }
}

extension ViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}
