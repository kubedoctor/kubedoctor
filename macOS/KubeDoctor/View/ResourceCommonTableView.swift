//
//  ResourceCommonTableView.swift
//  KubeDoctor
//
//  Created by 翟怀楼 on 2020/7/25.
//  Copyright © 2020 翟怀楼. All rights reserved.
//

import Foundation
import SwiftUI
import Stencil
import Combine

public protocol ResourceCommonColumnProtocol: CaseIterable & RawRepresentable {
    var nsColumn: NSTableColumn { get }
}

struct ResourceCommonTableView<Element, Column: ResourceCommonColumnProtocol>: NSViewRepresentable where Element: Equatable, Element: Identifiable {
    typealias ContentBuilder = (Element, Column, NSTableView, NSUserInterfaceItemIdentifier) -> NSView?
    
    init(_ currentContext: String, _ elements: [Element], _ column: Column.Type, _ rightMenus: [[KDConfig.Menu]], _ onDoubleTapRow: @escaping (Element) -> (), contentBuilder: @escaping ContentBuilder) {
        self.currentContext = currentContext
        self.elements = elements
        self.column = column
        self.contentBuilder = contentBuilder
        self.rightMenus = rightMenus
        self.onDoubleTapRow = onDoubleTapRow
    }
        
    var rightMenus: [[KDConfig.Menu]]
    var currentContext: String
    var elements: [Element]
    var column: Column.Type
    var contentBuilder: ContentBuilder
    var onDoubleTapRow: (Element) -> ()
    
    func makeNSView(context: NSViewRepresentableContext<ResourceCommonTableView>) -> NSScrollView {
        let scrollView = NSScrollView()
        scrollView.hasVerticalScroller = true
        scrollView.documentView = context.coordinator.tableView
        scrollView.automaticallyAdjustsContentInsets = false
        return scrollView
    }
  
    func updateNSView(_ nsView: NSScrollView, context: NSViewRepresentableContext<ResourceCommonTableView>) {
        context.coordinator.elements = elements
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(currentContext: currentContext, elements: elements, column: column, contentBuilder: contentBuilder, rightMenus: rightMenus, onDoubleTapRow: onDoubleTapRow)
    }
    
    // MARK - 自定义
    class Coordinator : NSObject, NSMenuDelegate, NSTableViewDataSource, NSTableViewDelegate {
        @EnvironmentObject var store: Store
        
        var elements: [Element] {
            didSet {
                let changes = elements.difference(from: oldValue, by: { $0.id == $1.id })
                if !changes.isEmpty { tableView.beginUpdates() }
                for change in changes {
                    switch change {
                    case .insert(let offset, _, _):
                        tableView.insertRows(at: IndexSet(integer: offset), withAnimation: .slideDown)
                    case .remove(let offset, _, _):
                        tableView.removeRows(at: IndexSet(integer: offset), withAnimation: .slideUp)
                    }
                }
                if !changes.isEmpty { tableView.endUpdates() }
                let partialChanges = oldValue.applying(changes)!
                let indicesToReload = IndexSet(zip(partialChanges, elements).enumerated().compactMap { index, pair -> Int? in
                    (pair.0.id == pair.1.id && pair.0 != pair.1) ? index : nil
                })
                print("[View]: ResourceCommonTableView elements reloadData")
                tableView.reloadData(forRowIndexes: indicesToReload, columnIndexes: IndexSet(tableView.tableColumns.indices))
            }
        }

        lazy var tableView: NSTableView = {
            let tableView = NSTableView(frame: .zero)
            tableView.delegate = self
            tableView.dataSource = self
            tableView.columnAutoresizingStyle = .uniformColumnAutoresizingStyle
            tableView.selectionHighlightStyle = .none
            tableView.allowsColumnReordering = false
            tableView.usesAlternatingRowBackgroundColors = true
            tableView.selectionHighlightStyle = .regular
            // 双击
            tableView.target = self
            tableView.doubleAction = #selector(self.onDoubleTapRow(_:))
            
            let menu = NSMenu()
            menu.delegate = self
            
            var item: NSMenuItem?
            let addMenuItem = { (tag: Int, key: String, action: Selector) in
                item = menu.item(withTag: tag)
                if item == nil {
                    item = NSMenuItem(title: key, action: action, keyEquivalent: "")
                    item?.tag = tag
                    item?.target = self
                    menu.addItem(item!)
                }
            }
            
            var index = 0
            for element in rightMenus {
                for action in element {
                    addMenuItem(index, action.name, #selector(self.rightMenu(_:)))
                    index = index + 1
                }
                menu.addItem(NSMenuItem.separator())
            }

            tableView.menu = menu
                        
            column.allCases.forEach { column in
                // 新列必须追加到表视图中
                tableView.addTableColumn(column.nsColumn)
            }
            return tableView
        }()
        
        let rightMenus: [[KDConfig.Menu]]
        let currentContext: String
        let contentBuilder: ContentBuilder
        let column: Column.Type
        var onDoubleTapRowAction: (Element) -> ()

        init(currentContext: String, elements: [Element], column: Column.Type, contentBuilder: @escaping ContentBuilder, rightMenus: [[KDConfig.Menu]], onDoubleTapRow: @escaping (Element) -> ()) {
            self.currentContext = currentContext
            self.rightMenus = rightMenus
            self.contentBuilder = contentBuilder
            self.column = column
            self.elements = elements
            self.onDoubleTapRowAction = onDoubleTapRow
        }

        // MARK:- NSTableViewDelegate
        // 这个方法返回每行的View(就是我们之前注册的View)
        func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
            guard let identifier = tableColumn?.identifier, let column = Column(rawValue: identifier.rawValue as! Column.RawValue) else { return nil }
            
            let element = elements[row]
            return contentBuilder(element, column, tableView, identifier)
        }
      
        // MARK:- NSTableViewDataSource
        func numberOfRows(in tableView: NSTableView) -> Int {
            elements.count
        }
        
        // 右击事件
        @objc func rightMenu(_ item: NSMenuItem?) {
            let element = elements[tableView.clickedRow]
            
            if let tag = item?.tag {
                var index = 0
                for menus in rightMenus {
                    for action in menus {
                        if index == tag {
                            let template = Template(templateString: action.script)
                            do {
                                let script = try template.render(
                                    [
                                        "kubectl": kubectlPath,
                                        "context": currentContext,
                                        "data": element
                                    ]
                                )
                                switch action.action {
                                case .clipboard:
                                    复制到剪切板(script)
                                case .shell:
                                    _ = shell(script)
                                }
                            } catch {
                                print(error)
                            }
                        }
                        
                        index = index + 1
                    }
                }
            }
        }
        
        // 双击事件
        @objc func onDoubleTapRow(_ sender: AnyObject) {
            self.onDoubleTapRowAction(elements[tableView.selectedRow])
        }
    }
}
