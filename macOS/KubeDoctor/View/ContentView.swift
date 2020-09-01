//
//  ContentView.swift
//  KubeDoctor
//
//  Created by 翟怀楼 on 2020/3/16.
//  Copyright © 2020 翟怀楼. All rights reserved.
//

import SwiftUI
import Foundation
import Combine

struct ContentView : View {
    @EnvironmentObject var store: Store
        
    private var kubeConfigBinding: Binding<KubeConfig> { $store.appState.config.kubeConfig }
    private var configBinding: Binding<AppState.Config> { $store.appState.config }
    
    var clusterList: [ContextElement] { store.appState.config.kubeConfig.contexts }
    @State private var showingAlert = false
    
    func currentContextChange(_ tag: String) {
        print("集群 tag: \(tag)")
        self.store.dispatch(.loadKubeAPIResources)
    }
    
    func resourceKindChange(_ tag: String) {
        print("资源 tag: \(tag)")
        self.store.appState.config.selectionKubeAPIResource = tag
        self.store.dispatch(.loadKubeResourceList)
    }

    func currentNamespaceChange(_ tag: String) {
        print("租户 tag: \(tag)")
        self.store.appState.config.selectionKubeNamespace = tag
        self.store.dispatch(.loadKubeResourceList)
    }
    
    var body: some View {
        VStack {
            if store.appState.config.kubeConfig.contexts.count == 0 {
                if store.appState.config.kubeConfigLoadingError != nil {
                    Text("⚠️"+store.appState.config.kubeConfigLoadingError!.localizedDescription).frame(maxWidth: .infinity, maxHeight: .infinity)
                    Button(action: {
                        self.store.dispatch(.loadConfig)
                    }) {
                        Text("刷新")
                    }
                } else {
                    Text("加载中").frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            } else {
                HStack {
                    Picker(selection: kubeConfigBinding.currentContext.onChange(currentContextChange), label: Text("集群")) {
                        ForEach(clusterList, id: \.name) { item in
                            Text(item.name)
                        }
                    }.pickerStyle(PopUpButtonPickerStyle())
                    .padding(.leading, 6.0)
                    
                    // $ 直接调用
                    Picker(selection: $store.appState.config.selectionKubeAPIResource.onChange(resourceKindChange), label: Text("资源")) {
                        ForEach(store.appState.config.kubeAPIResources, id: \.self) {
                            Text($0)
                        }
                    }

                    Picker(selection: $store.appState.config.selectionKubeNamespace.onChange(currentNamespaceChange), label: Text("租户")) {
                        ForEach(store.appState.config.kubeNamespaces, id: \.self) {
                            Text($0)
                        }
                    }
                    
//                    PopupButton(selectedValue: $store.appState.config.selectionKubeNamespace, items: store.appState.config.kubeNamespaces, onChange: {
//                        print($0)
//                    })

                    Button(action: {
                        self.store.dispatch(.loadKubeConfig)
                    }) {
                        Text("刷新")
                    }
                    Spacer()
                }.padding(EdgeInsets(top: 8, leading: 2, bottom: 0, trailing: 2))
                if store.appState.config.loadingKubeError != nil {
                    AnyView(Text(store.appState.config.loadingKubeError!.localizedDescription).frame(maxWidth: .infinity, maxHeight: .infinity))
                } else if store.appState.config.loadingKubeConfig {
                    Text("⌛ 加载 KubeConfig 中...").frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if store.appState.config.loadingKubeNamespaces {
                    Text("⌛ 加载租户中...").frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if store.appState.loadingKubeResourceList {
                    Text("⌛ 加载资源列表中...").frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if store.appState.loadingKubeResourceListError != nil {
                    AnyView(Text(store.appState.loadingKubeResourceListError!.localizedDescription).frame(maxWidth: .infinity, maxHeight: .infinity))
                } else {
                    MainView()
                }
                Spacer()
            }
        }.frame(
            minWidth: 400,
            maxWidth: .infinity,
            minHeight: 600,
            maxHeight: .infinity
        )
        .onAppear {
            self.store.dispatch(.loadConfig)
        }
    }
}

extension ContentView {
    func MainView() -> some View {
        switch store.appState.config.selectionKubeAPIResource {
        case "pods":
            return AnyView(PodListView())
        case "deployments.apps":
            return AnyView(DeploymentListView())
        case "secrets":
            return AnyView(SecretListView())
        case "configmaps":
            return AnyView(ConfigmapListView())
        case "services":
            return AnyView(ServiceListView())
        default:
            return AnyView(DefaultResourcesListView())
        }
    }
}



func 复制到剪切板(_ 内容: String) {
    let pasteBoard = NSPasteboard.general
    pasteBoard.clearContents()
    pasteBoard.setString(内容, forType: .string)
}

extension Binding {
    func onChange(_ handler: @escaping (Value) -> Void) -> Binding<Value> {
        Binding(
            get: { self.wrappedValue },
            set: { selection in
                self.wrappedValue = selection
                handler(selection)
            }
        )
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Text("Hello, World!")
    }
}
