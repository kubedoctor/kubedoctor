//
//  EditorToolBar.swift
//  KubeDoctor
//
//  Created by 翟怀楼 on 2020/8/2.
//  Copyright © 2020 翟怀楼. All rights reserved.
//

import SwiftUI
import Combine

extension NSToolbarItem.Identifier {
    static let apply = NSToolbarItem.Identifier("apply")
    static let delete = NSToolbarItem.Identifier("delete")
}

class EditorToolBarDelegate: NSObject, NSToolbarDelegate {
    let publisher = PassthroughSubject<Void, Never>()
    
    lazy var toolbarItems: [NSToolbarItem.Identifier:NSToolbarItem] = [
        .apply: makeToolbarApply(id: .apply),
        .delete: makeToolbarDelete(id: .delete),
    ]
    
    lazy var toolbar: NSToolbar = {
        let toolbar = NSToolbar(identifier: "KubeDoctorEditorToolbar")
        toolbar.allowsUserCustomization = false
        toolbar.displayMode = .iconOnly
        toolbar.delegate = self
        return toolbar
    }()
    
    func makeToolbarApply(id: NSToolbarItem.Identifier) -> NSToolbarItem {
        let button = NSButton()
        button.target = self
        button.action = #selector(self.apply(_:))
        button.bezelStyle = .texturedRounded
        button.setButtonType(.momentaryPushIn)
        button.title = "应用"
        // button.image = NSImage(named: "apply")
        return NSToolbarItem(itemIdentifier: id, view: button)
    }
    
    func makeToolbarDelete(id: NSToolbarItem.Identifier) -> NSToolbarItem {
        let button = NSButton()
        button.target = self
        button.action = #selector(self.apply(_:))
        button.title = "删除"
        button.bezelStyle = .texturedRounded
        button.setButtonType(.momentaryPushIn)
        return NSToolbarItem(itemIdentifier: id, view: button)
    }
    
    // MARK: - Runtime action
    @objc func apply(_ sender: NSButton) {
        publisher.send()
    }
    
    @objc func applyAndClose(_ sender: NSButton) {
    }
    
    @objc func delete(_ sender: NSButton) {
    }
    
    // MARK: - NSToolbar Delegate
    func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
      return self.toolbarItems[itemIdentifier]
    }
    
    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return [.flexibleSpace, .apply, .delete]
    }
    
    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
      return self.toolbarDefaultItemIdentifiers(toolbar)
    }
}

