//
//  UIButton+Closure.swift
//  ABOnboarding
//
//  Created by Adam Boyd on 2016-03-21.
//  Copyright © 2016 Under100. All rights reserved.
//

//Modified from http://stackoverflow.com/questions/25919472/adding-a-closure-as-target-to-a-uibutton

import Foundation
import UIKit

extension UIButton {
    
    private func actionHandleBlock(action:(() -> Void)? = nil) {
        struct __ {
            static var action :(() -> Void)?
        }
        if action != nil {
            __.action = action
        } else {
            __.action?()
        }
    }
    
    @objc private func triggerActionHandleBlock() {
        self.actionHandleBlock()
    }
    
    func addAction(forControlEvents controlEvent: UIControlEvents, forAction action:() -> Void) {
        self.actionHandleBlock(action)
        self.addTarget(self, action: #selector(self.triggerActionHandleBlock), forControlEvents: controlEvent)
    }
}