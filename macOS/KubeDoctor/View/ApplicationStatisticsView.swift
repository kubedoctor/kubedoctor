//
//  ApplicationStatisticsView.swift
//  KubeDoctor
//
//  Created by 翟怀楼 on 2020/4/11.
//  Copyright © 2020 翟怀楼. All rights reserved.
//

import SwiftUI
import Combine

struct PodTableView: NSViewRepresentable {
    var pods: [Pod]
    var currentContext: String
    
    class Coordinator : NSObject, NSMenuDelegate, NSTableViewDataSource, NSTableViewDelegate {
        private enum Column: String, CaseIterable {
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
    
        lazy var tableView: NSTableView = {
            let tableView = NSTableView(frame: .zero)
            tableView.delegate = self
            tableView.dataSource = self
            tableView.columnAutoresizingStyle = .uniformColumnAutoresizingStyle
            tableView.selectionHighlightStyle = .none
            tableView.allowsColumnReordering = false
            tableView.usesAlternatingRowBackgroundColors = true
            tableView.selectionHighlightStyle = .regular
            
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
            addMenuItem(1001, "定义", #selector(self.rightMenu(_:)))
            addMenuItem(1002, "日志", #selector(self.rightMenu(_:)))
            addMenuItem(1003, "网络", #selector(self.rightMenu(_:)))
            addMenuItem(1004, "删除", #selector(self.rightMenu(_:)))
            addMenuItem(1005, "bash", #selector(self.rightMenu(_:)))
            addMenuItem(1006, "sh", #selector(self.rightMenu(_:)))

            tableView.menu = menu
            
            Column.allCases.forEach { column in
                tableView.addTableColumn(column.nsColumn)
            }
            return tableView
        }()
    
        var pods: [Pod] {
            didSet {
                tableView.reloadData()
            }
        }
        var currentContext: String

        init(currentContext: String, statistics: [Pod]) {
            self.currentContext = currentContext
            self.pods = statistics
        }

        //MARK:- NSTableViewDelegate
        func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
            guard let identifier = tableColumn?.identifier, let column = Column(rawValue: identifier.rawValue) else { return nil }
      
            let text: String
      
            switch column {
            case .name:
                text = pods[row].metadata.name
            case .date:
                if let t = pods[row].status.startTime {
                    text = date2String(t)
                } else {
                    text = ""
                }
            case .status:
                text = pods[row].status.phase.rawValue
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
      
        //MARK:- NSTableViewDataSource
        func numberOfRows(in tableView: NSTableView) -> Int {
            return pods.count
        }
        
        @objc func rightMenu(_ item: NSMenuItem?) {
            print(tableView.clickedRow)
            let pod = pods[tableView.clickedRow]
            
            switch item?.tag {
            case 1001:
                let command = "/usr/local/bin/kubectl -n \(pod.metadata.namespace) --context \(currentContext) get pod \(pod.metadata.name) -o yaml > ${TMPDIR}\(pod.metadata.name).yaml && /usr/local/bin/code ${TMPDIR}\(pod.metadata.name).yaml"
                复制到剪切板(command)
                _ = shell(command)
            case 1002:
                复制到剪切板("kubectl -n \(pod.metadata.namespace) logs \(pod.metadata.name) -f --tail 100 --context \(currentContext)")
            case 1003:
                复制到剪切板("kubectl sniff \(pod.metadata.name) -n \(pod.metadata.namespace) --context \(currentContext)")
            case 1004:
                复制到剪切板("kubectl -n \(pod.metadata.namespace) delete pod \(pod.metadata.name) --context \(currentContext)")
            case 1005:
                复制到剪切板("kubectl -n \(pod.metadata.namespace) --context \(currentContext) exec \(pod.metadata.name) -it bash")
            case 1006:
                复制到剪切板("kubectl -n \(pod.metadata.namespace) --context \(currentContext) exec \(pod.metadata.name) -it sh")
            default:
                print("未实现")
            }
        }
    }

    init(currentContext: String, statistics: [Pod]) {
        self.currentContext = currentContext
        self.pods = statistics
    }
  
    func makeCoordinator() -> Coordinator {
        return Coordinator(currentContext: currentContext, statistics: pods)
    }
  
    func makeNSView(context: NSViewRepresentableContext<PodTableView>) -> NSView {
        let scrollView = NSScrollView()
        scrollView.hasVerticalScroller = true
        scrollView.documentView = context.coordinator.tableView
        return scrollView
    }

    func updateNSView(_ nsView: NSView, context: NSViewRepresentableContext<PodTableView>) {
        context.coordinator.pods = pods
    }
}

extension Date {
    static func getHourStartDate(for date: Date) -> Date {
        let hourStartInterval = (date.timeIntervalSinceReferenceDate / 3600).rounded(.down) * 3600
        return Date(timeIntervalSinceReferenceDate: hourStartInterval)
    }
}


struct ApplicationStatisticsTableView_Previews: PreviewProvider {
    static let statistics: [Pod] = (1...3).map { (i: Int) -> Pod in
        Pod(
            apiVersion: "",
            kind: "",
            metadata: Metadata(
                name: "ngnix",
                namespace: "default",
                uid: "uuid"),
            status: PodStatus(
                hostIP: "",
                podIP: "",
                qosClass: "",
                phase: .Running,
                startTime: Date())
        )
    }
    
    static var previews: some View {
        PodTableView(currentContext: "default", statistics: statistics)
    }
}

func date2String(_ date:Date, dateFormat:String = "yyyy-MM-dd HH:mm:ss") -> String {
    let formatter = DateFormatter()
    formatter.locale = Locale.init(identifier: "zh_CN")
    formatter.dateFormat = dateFormat
    let date = formatter.string(from: date)
    return date
}
