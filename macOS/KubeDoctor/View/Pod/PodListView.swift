//
//  Pod.swift
//  KubeDoctor
//
//  Created by 翟怀楼 on 2020/3/31.
//  Copyright © 2020 翟怀楼. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

struct PodListView: View {
    private var searchFilter = SearchFilter<Pod>()
    @EnvironmentObject var store: Store
    
    func righeMenus() -> [[KDConfig.Menu]] {
        var arr:[[KDConfig.Menu]] = [[]]
        
        if let config = store.appState.config.config {
            arr = [config.rightMenus.common]
            for item in config.rightMenus.kind {
                if item.name == "pods" {
                    arr.append(contentsOf: item.group)
                }
            }
        }
        return arr
    }
    
    private enum Column: String, ResourceCommonColumnProtocol {
        case name, date, status
        var nsColumn: NSTableColumn {
            let column = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(self.rawValue))
            switch self {
            case .name:
                column.title = NSLocalizedString("名称", comment: "")
                column.width = 300
            case .date:
                column.title = NSLocalizedString("时间", comment: "")
                column.width = 140
            case .status:
                column.title = NSLocalizedString("状态", comment: "")
            }
            return column
        }
    }

    func onDoubleTapRow(element: Pod) {
        let view = DetailView(
            context: store.appState.config.kubeConfig.currentContext,
            kind: store.appState.config.selectionKubeAPIResource,
            name: element.metadata.name,
            namespace: element.metadata.namespace
        )
        let controller = DetailWindowController(
            rootView: view,
            toolbar: view.toolbarDelegate
        )
        controller.showWindow(nil)
    }

    var body: some View {
        VStack() {
            if store.appState.pods.count == 0 {
                Text("⛴ 没有数据")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                Group {
                    ResourceCommonTableView(
                        store.appState.config.kubeConfig.currentContext,
                        self.searchFilter.applyFromExternal(
                            searchText: store.appState.searchText,
                            to: store.appState.pods
                        ),
                        Column.self,
                        righeMenus(), onDoubleTapRow
                    ) { element, column, tableView, identifier -> NSView in
                        
                        let text: String
                  
                        switch column {
                        case .name:
                            text = element.metadata.name
                        case .date:
                            if let t = element.status.startTime {
                                text = date2String(t)
                            } else {
                                text = ""
                            }
                        case .status:
                            text = element.status.phase.rawValue
                        }
                  
                        if let textField = tableView.makeView(withIdentifier: identifier, owner: nil) as? NSTextField {
                            textField.stringValue = text
                            return textField
                        } else {
                            let textField = NSTextField(labelWithString: text)
                            textField.identifier = identifier
                            return textField
                        }
                    }
                }
            }
        }
    }
}
