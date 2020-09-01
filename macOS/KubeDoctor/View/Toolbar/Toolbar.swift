//
//  Toolbar.swift
//  KubeDoctor
//
//  Created by 翟怀楼 on 2020/3/21.
//  Copyright © 2020 翟怀楼. All rights reserved.
//

import AppKit
import Cocoa
import Combine
import SwiftUI

extension NSToolbarItem.Identifier {
    static let search = NSToolbarItem.Identifier("search")
}

class ToolbarDelegate: NSObject {
    @Binding var searchState: String
    
    init(searchState: Binding<String>, window: NSWindow) {
        _searchState = searchState
    }

    lazy var toolbarItems: [NSToolbarItem.Identifier:NSToolbarItem] = [
        .search: makeToolbarItemSearch(id: .search),
    ]
  
    lazy var toolbar: NSToolbar = {
        let toolbar = NSToolbar(identifier: "KubeDoctorToolbar")
        toolbar.allowsUserCustomization = false
        toolbar.displayMode = .iconOnly
        toolbar.delegate = self
        return toolbar
    }()

    func makeToolbarItemSearch(id: NSToolbarItem.Identifier) -> NSToolbarItem {
        let search = NSSearchField()
        search.sendsSearchStringImmediately = false
        search.target = self
        search.action = #selector(applySearchFilter(_:))
        search.cell?.isScrollable = true
        return NSToolbarItem(itemIdentifier: id, view: search)
    }
    
    @objc func applySearchFilter(_ searchField: NSSearchField) {
        print("applySearchFilter: ",searchField.stringValue)
        searchState = searchField.stringValue
    }
}

extension ToolbarDelegate : NSToolbarDelegate {
    func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
        return self.toolbarItems[itemIdentifier]
    }

    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return [.flexibleSpace, .search]
    }

    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return self.toolbarDefaultItemIdentifiers(toolbar)
    }
}

//extension ToolbarDelegate : NSOpenSavePanelDelegate {
//    func panel(_ sender: Any, shouldEnable url: URL) -> Bool {
//        if url.hasDirectoryPath { return true }
//        guard
//            let resources = try? url.resourceValues(forKeys: [.typeIdentifierKey]),
//            let uti = resources.typeIdentifier
//            else {
//                return false
//        }
//        return UTTypeConformsTo(uti as CFString, kUTTypeApplicationBundle) || UTTypeConformsTo(uti as CFString, kUTTypeExecutable)
//  }
//}

extension NSToolbarItem {
    convenience init(itemIdentifier: NSToolbarItem.Identifier, view: NSView) {
        self.init(itemIdentifier: itemIdentifier)
        self.view = view
    }
}
