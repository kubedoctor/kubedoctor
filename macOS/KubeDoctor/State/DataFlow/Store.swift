//
//  Store.swift
//  KubeDoctor
//
//  Created by 翟怀楼 on 2020/7/16.
//  Copyright © 2020 翟怀楼. All rights reserved.
//

import Foundation
import Combine

class Store: ObservableObject {
    @Published var appState = AppState()
    
    func dispatch(_ action: AppAction) {
        //print("[ACTION]: \(action)")
        let result = Store.reduce(state: appState, action: action)
        appState = result.0
        if let command = result.1 {
            print("[COMMAND]: \(command)")
            command.execute(in: self)
        }
    }
    
    static func reduce(state: AppState, action: AppAction) -> (AppState, AppCommand?) {
        var appState = state
        var appCommand: AppCommand? = nil

        switch action {
        case .loadConfig:
            appState.config.kubeConfigLoadingError = nil
            appState.config.loadingKubeConfig = true
            appCommand = LoadConfigCommand()
            
        case .loadConfigDone(result: let result):
            switch result {
            case .success(let config):
                appState.config.config = config
                // appState.config.kubeConfig.currentContext = config.currentContext
                // appState.config.kubeConfig.contexts = config.contexts
            case .failure(let error):
                appState.config.kubeConfigLoadingError = error
            }
            appState.config.loadingKubeConfig = false
        
        case .loadKubeConfig:
            appState.config.kubeConfigLoadingError = nil
            appState.config.loadingKubeConfig = true
            appCommand = LoadKubeConfigCommand()
        case .loadKubeConfigDone(result: let result):
            switch result {
            case .success(let config):
                appState.config.kubeConfig = config
                // appState.config.kubeConfig.currentContext = config.currentContext
                // appState.config.kubeConfig.contexts = config.contexts
            case .failure(let error):
                appState.config.kubeConfigLoadingError = error
            }
            appState.config.loadingKubeConfig = false

        case .loadKubeAPIResources:
            appState.config.loadingKubeError = nil
            appState.config.loadingKubeResourcesKind = false
            appCommand = LoadKubeAPIResourcesCommand()
        case .loadKubeAPIResourcesDone(result: let result):
            switch result {
            case .success(let resources):
                appState.config.kubeAPIResources = resources
                if resources.firstIndex(where: { $0 == appState.config.selectionKubeAPIResource }) == nil {
                    appState.config.selectionKubeAPIResource = "pods"
                }
            case .failure(let error):
                appState.config.loadingKubeError = error
            }
            appState.config.loadingKubeResourcesKind = false
        
        case .loadKubeNamespaces:
            appState.config.loadingKubeError = nil
            appState.config.loadingKubeNamespaces = true
            appCommand = ListKubeNamespacesCommand(context: appState.config.kubeConfig.currentContext)
        case .loadKubeNamespacesDone(result: let result):
            switch result {
            case .failure(let error):
                appState.config.loadingKubeError = error
            case .success(let namespaces):
                appState.config.kubeNamespaces = namespaces
                if namespaces.firstIndex(where: { $0 == appState.config.selectionKubeNamespace }) == nil {
                    if namespaces.count > 0 {
                        appState.config.selectionKubeNamespace = namespaces[0]
                    }
                }
            }
            appState.config.loadingKubeNamespaces = false

        case .loadKubeResourceList:
            appState.loadingKubeResourceListError = nil
            appState.loadingKubeResourceList = true
            appCommand = ListKubeResourcesCommand(namespace: appState.config.selectionKubeNamespace, resource: appState.config.selectionKubeAPIResource)
        case .loadKubeResourceListDone(result: let result):
            switch result {
            case .failure(let error):
                appState.loadingKubeResourceListError = error
            case .success(let resource):
                switch resource {
                case .listPods(let pods):
                    appState.pods = pods.items
                case .listDeployments(let deployments):
                    appState.deployments = deployments.items
                case .listConfigMaps(let configMaps):
                    appState.configMaps = configMaps.items
                case .listSecrets(let secrets):
                    appState.secrets = secrets.items
                case .listServices(let services):
                    appState.services = services.items
                case .listDefaultResources(let defaultResources):
                    appState.defaultResources = defaultResources.items
                }
            }
            appState.loadingKubeResourceList = false
        }
        
        return (appState, appCommand)
    }
}
