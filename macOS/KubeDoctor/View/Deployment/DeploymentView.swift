//
//  DeploymentView.swift
//  KubeDoctor
//
//  Created by 翟怀楼 on 2020/4/1.
//  Copyright © 2020 翟怀楼. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

struct DeploymentListView: View {
    private var searchFilter = SearchFilter<Deployment>()
    @EnvironmentObject var store: Store
    
    func righeMenus() -> [[KDConfig.Menu]] {
        var arr:[[KDConfig.Menu]] = [[]]
        
        if let config = store.appState.config.config {
            arr = [config.rightMenus.common]
            for item in config.rightMenus.kind {
                if item.name == "deployments.app" {
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
                column.title = NSLocalizedString("就绪", comment: "")
            }
            return column
        }
    }
    
    func onDoubleTapRow(element: Deployment) {
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
                            to: store.appState.deployments
                        ),
                        Column.self,
                        righeMenus(), onDoubleTapRow
                    ) { element, column, tableView, identifier -> NSView in
                        
                        var text: String = ""
                  
                        switch column {
                        case .name:
                            text = element.metadata.name
                        case .date:
                            if let t = element.metadata.creationTimestamp {
                                text = date2String(t)
                            }
                        case .status:
                            if let readyReplica = element.status.readyReplicas, let replicas = element.status.replicas {
                                text = String(format: "%d/%d", readyReplica, replicas)
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
