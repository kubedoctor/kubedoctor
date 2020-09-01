//
//  AppDelegate.swift
//  KubeDoctor
//
//  Created by 翟怀楼 on 2020/3/16.
//  Copyright © 2020 翟怀楼. All rights reserved.
//

import Cocoa
import SwiftUI
import Combine

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var window: NSWindow!
    private var toolbarDelegate: ToolbarDelegate?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Create the SwiftUI view that provides the window contents.
        let store = Store()
        let contentView = ContentView().environmentObject(store)

        // 创建窗口并设置内容视图
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 500, height: 300),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        window.center()
        window.setFrameAutosaveName("Main Window")
        window.contentView = NSHostingView(rootView: contentView)
        
        window.titlebarAppearsTransparent = true
        window.isReleasedWhenClosed = false
        window.tabbingMode = .disallowed
        window.title = "Kube Doctor"
        
        window.styleMask = [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView, .unifiedTitleAndToolbar]
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = false
        window.isReleasedWhenClosed = false
        
        
        // 设置 Toolbar
        let toolbarDelegate = ToolbarDelegate(searchState: Binding(get: {store.appState.searchText}, set: { store.appState.searchText = $0 }), window: window)
        window.toolbar = toolbarDelegate.toolbar
        self.toolbarDelegate = toolbarDelegate

        window.makeKeyAndOrderFront(nil)
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        print("applicationShouldTerminateAfterLastWindowClosed")
        return true
    }

}
