//
//  TabManager.swift
//  KubeDoctor
//
//  Created by 翟怀楼 on 2020/8/4.
//  Copyright © 2020 翟怀楼. All rights reserved.
//

import Cocoa

class TabManager {
    var windowControllers: [NSWindowController] = []
    
    static let shared: TabManager = {
        let instance = TabManager()
        // setup code
        return instance
    }()
    
    func addWindowController(_ windowController: NSWindowController){
        windowControllers.append(windowController)
    }
    
    func isEmpty() -> Bool{
        return windowControllers.isEmpty
    }
    
    func removeWindowController(_ windowController: NSWindowController){
        windowControllers.removeAll { (controler) -> Bool in
            return windowController == controler
        }
    }
}
