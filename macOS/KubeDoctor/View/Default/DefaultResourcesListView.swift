//
//  DefaultResourcesListView.swift
//  KubeDoctor
//
//  Created by 翟怀楼 on 2020/7/23.
//  Copyright © 2020 翟怀楼. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

struct DefaultResourcesListView: View {
    private var searchFilter = SearchFilter<DefaultResource>()
    @EnvironmentObject var store: Store
    
    func righeMenus() -> [[KDConfig.Menu]] {
        var arr:[[KDConfig.Menu]] = [[]]
        
        if let config = store.appState.config.config {
            arr = [config.rightMenus.common]
        }
        return arr
    }
    
    private enum Column: String, ResourceCommonColumnProtocol {
        case name, date
        var nsColumn: NSTableColumn {
            let column = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(self.rawValue))
            switch self {
            case .name:
                column.title = NSLocalizedString("名称", comment: "")
                column.minWidth = 300
            case .date:
                column.title = NSLocalizedString("创建时间", comment: "")
                column.minWidth = 220
            }
            return column
        }
    }
    
    func onDoubleTapRow(num: DefaultResource) {
//        let controller = DetailWindowController(
//            rootView: DetailView(
//                context: store.appState.config.kubeConfig.currentContext,
//                kind: store.appState.config.selectionKubeAPIResource,
//                name: store.appState.defaultResources[num].metadata.name,
//                namespace: store.appState.defaultResources[num].metadata.namespace
//            ), toolbar: NSToolbar()
//        )
//        controller.window?.title = "编辑"
//        controller.showWindow(nil)
    }

    var body: some View {
        VStack() {
            if store.appState.defaultResources.count == 0 {
                Text("⛴ 没有数据")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                Group {
                    ResourceCommonTableView(
                        store.appState.config.kubeConfig.currentContext,
                        self.searchFilter.applyFromExternal(
                            searchText: store.appState.searchText,
                            to: store.appState.defaultResources
                        ),
                        Column.self,
                        righeMenus(), onDoubleTapRow
                    ) { element, column, tableView, identifier -> NSView in
                        
                        let text: String
                  
                        switch column {
                        case .name:
                            text = element.metadata.name
                        case .date:
                            if let t = element.metadata.creationTimestamp {
                                text = date2String(t)
                            } else {
                                text = ""
                            }
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

