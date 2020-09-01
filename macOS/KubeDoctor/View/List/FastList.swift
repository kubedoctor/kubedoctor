//
//  FastList.swift
//  KubeDoctor
//
//  Created by 翟怀楼 on 2020/3/26.
//  Copyright © 2020 翟怀楼. All rights reserved.
//

import SwiftUI


private let FastListColumnIdentifier = NSUserInterfaceItemIdentifier("elements")

struct FastList<Element, Content> : NSViewRepresentable where Element : Equatable, Element : Identifiable, Content : View {
    typealias ContentBuilder = (Element) -> Content
  
    init(_ elements: [Element], contentBuilder: @escaping ContentBuilder) {
        self.elements = elements
        self.contentBuilder = contentBuilder
    }
  
    var elements: [Element]
  
    var contentBuilder: ContentBuilder
  
    func makeCoordinator() -> FastList.Coordinator {
        Coordinator(elements: elements, contentBuilder: contentBuilder)
    }
  
    class Coordinator: NSObject, NSTableViewDelegate, NSTableViewDataSource {
        var elements: [Element] {
            didSet {
                print("FastList didSet")
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
                tableView.reloadData(forRowIndexes: indicesToReload, columnIndexes: IndexSet(tableView.tableColumns.indices))
            }
        }
    
        let contentBuilder: ContentBuilder
    
        private(set) lazy var tableView: NSTableView = {
            let tableView = FastListTableView()
            tableView.dataSource = self
            tableView.delegate = self
            tableView.addTableColumn(NSTableColumn(identifier: FastListColumnIdentifier))
            tableView.usesAutomaticRowHeights = true
            tableView.headerView = nil
            tableView.intercellSpacing = NSSize(width: 0, height: 2)
            return tableView
        }()
    
        init(elements: [Element], contentBuilder: @escaping ContentBuilder) {
            self.elements = elements
            self.contentBuilder = contentBuilder
        }
    
        func numberOfRows(in tableView: NSTableView) -> Int {
            elements.count
        }
    
        func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
            guard tableColumn?.identifier == FastListColumnIdentifier else { return nil }
      
            let element = elements[row]
      
            if let view = tableView.makeView(withIdentifier: FastListColumnIdentifier, owner: nil) as? NSHostingView<Content> {
                view.rootView = contentBuilder(element)
                return view
            } else {
                let rootView = contentBuilder(element)
                let view = NSHostingView(rootView: rootView)
                view.identifier = FastListColumnIdentifier
                return view
            }
        }
    
        func tableView(_ tableView: NSTableView, selectionIndexesForProposedSelection proposedSelectionIndexes: IndexSet) -> IndexSet {
            IndexSet()
        }
    }
  
    func makeNSView(context: NSViewRepresentableContext<FastList>) -> NSScrollView {
        let scrollView = NSScrollView()
        scrollView.hasVerticalScroller = true
        scrollView.documentView = context.coordinator.tableView
        scrollView.automaticallyAdjustsContentInsets = false
        return scrollView
    }
  
    func updateNSView(_ nsView: NSScrollView, context: NSViewRepresentableContext<FastList>) {
        context.coordinator.elements = elements
    }
}

private class FastListTableView : NSTableView {
    override func validateProposedFirstResponder(_ responder: NSResponder, for event: NSEvent?) -> Bool {
        // allow mouse events for text fields
        responder is NSTextField || super.validateProposedFirstResponder(responder, for: event)
    }
}

