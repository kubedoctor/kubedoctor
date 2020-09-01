//
//  DetailWindowController.swift
//  KubeDoctor
//
//  Created by 翟怀楼 on 2020/3/28.
//  Copyright © 2020 翟怀楼. All rights reserved.
//

import Cocoa
import SwiftUI
import WebKit
import Combine

class DetailWindowController<RootView : View>: NSWindowController, NSWindowDelegate {
    convenience init(rootView: RootView, toolbar: EditorToolBarDelegate) {
        let hostingController = NSHostingController(rootView: rootView.frame(minWidth: 600, minHeight: 500))
        let window = DetailWindows(contentViewController: hostingController)
        window.titleVisibility = .hidden
        window.toolbar = toolbar.toolbar
        self.init(window: window)
    }
}

class DetailWindows: NSWindow, NSWindowDelegate {
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        print("windowShouldClose")
        return true
    }
    
    func windowWillClose(_ notification: Notification) {
    }
}

struct DetailView: View {
    var toolbarDelegate = EditorToolBarDelegate()
    @State var value: String = ""
    @State var exitCode: Int32 = 0
    
    var context: String
    var kind: String
    var name: String
    var namespace: String
    
    init(context: String, kind : String, name: String, namespace: String) {
        self.context = context
        self.kind = kind
        self.name = name
        self.namespace = namespace
    }
    
    func loadData() {
        (value, exitCode) = ShellManager.shared.shell("\(kubectlPath) get \(kind) \(name) -n \(namespace) --context \(context) -o yaml")
    }

    var body: some View {
        VStack {
            if exitCode != 0 {
                Text("exit code: \(exitCode), \(value)")
            } else if value == "" {
                Text("加载中...")
            } else {
                EditorView(value: value, publisher: toolbarDelegate.publisher)
            }
        }.onAppear() {
            loadData()
        }
    }
}

struct EditorView: NSViewRepresentable {
    var value: String
    var coordinator: Coordinator
    var cancellable: AnyCancellable?
    
    init(value: String, publisher: PassthroughSubject<Void, Never>) {
        let coordinator = Coordinator(value: value)

        let mainResourceURL = Bundle.main.resourceURL
        let monacoEditorPath = "editor"
        let sourceURL = mainResourceURL!.appendingPathComponent("\(monacoEditorPath)/index.html");
        let readAccessURL = mainResourceURL!.appendingPathComponent(monacoEditorPath);

        let webView = WKWebView(frame: .zero)
        webView.configuration.userContentController.add(coordinator, name: coordinator.WebViewMessagePageReady)
        webView.configuration.userContentController.add(coordinator, name: coordinator.WebViewMessageEditorReady)
        webView.setValue(false, forKey: "drawsBackground")
        webView.uiDelegate = coordinator
        webView.navigationDelegate = coordinator
        webView.loadFileURL(sourceURL, allowingReadAccessTo: readAccessURL)

        coordinator.webView = webView

        self.value = value
        cancellable = publisher.sink {
            coordinator.apply()
        }
        self.coordinator = coordinator
        self.value = value
    }
    
    func makeCoordinator() -> Coordinator {
        return coordinator
    }
    
    func makeNSView(context: NSViewRepresentableContext<EditorView>) -> WKWebView {
        return coordinator.webView!
    }
    
    func updateNSView(_ view: WKWebView, context: NSViewRepresentableContext<EditorView>) {
        print("[EditorView]：updateNSView")
        context.coordinator.value = self.value
    }
    
    class Coordinator: NSObject, WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler {
        let WebViewMessagePageReady = "pageReady"
        let WebViewMessageEditorReady = "editorReady"
        
        weak var webView: WKWebView?
        
        var value: String {
            didSet {
                if oldValue == value {
                    return
                }
                let javaScriptString = "window.editorOptions.value = `" + self.value + "`;\nwindow.editorRenewIfNeed();"
                self.webView?.evaluateJavaScript(javaScriptString, completionHandler: nil)
            }
        }

        init(value: String) {
            self.value = value
        }
        
        func apply() {
            print("[EditorView]：======== apply =======")
            self.webView?.evaluateJavaScript("window.editor.getValue()") { (any, error) in
                if error != nil {
                    let alert = NSAlert()
                    alert.messageText = "错误"
                    alert.informativeText = "\(String(describing: error))"
                    alert.alertStyle = .informational
                    alert.addButton(withTitle: "OK")
                    alert.beginSheetModal(for: NSApplication.shared.mainWindow!, completionHandler: nil)
                    return
                }
                
                if let yaml = any as? String {
                    复制到剪切板("echo '\(yaml)' | \(kubectlPath) apply -f -")
                    let result = shell("echo '\(yaml)' | \(kubectlPath) apply -f -")
                    print(String(data: result, encoding: .utf8) ?? "")
                }
            }
        }
        
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            if message.name == WebViewMessagePageReady {
                let javaScriptString = "window.editorOptions.value = `" + self.value + "`;\nwindow.editorRenewIfNeed();"
                self.webView?.evaluateJavaScript(javaScriptString, completionHandler: nil)
            }
            if message.name == WebViewMessageEditorReady {
            }
        }
    }

}
