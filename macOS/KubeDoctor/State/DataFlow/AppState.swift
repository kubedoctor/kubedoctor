//
//  AppState.swift
//  KubeDoctor
//
//  Created by 翟怀楼 on 2020/7/15.
//  Copyright © 2020 翟怀楼. All rights reserved.
//

import Foundation
import Combine
import SwiftUI

struct AppState {
    var searchText = ""

    var config = Config()

    var loadingKubeResourceListError: AppError?
    var loadingKubeResourceList = false
    
    var pods: [Pod] = []
    var configMaps: [ConfigMap] = []
    var deployments: [Deployment] = []
    var services: [Service] = []
    var secrets: [Secret] = []
    var defaultResources: [DefaultResource] = []
}

extension AppState {
    struct Config {
        // config
        var config: KDConfig?
        
        // KubeConfig
        var loadingKubeConfig = false
        var kubeConfigLoadingError: AppError?
        var kubeConfig = KubeConfig()

        // resourcesKind
        var loadingKubeResourcesKind = false
        var kubeAPIResources:[String] = []
        var selectionKubeAPIResource: String = ""
        
        // namespaces
        var loadingKubeNamespaces = false
        var kubeNamespaces:[String] = []
        var selectionKubeNamespace: String = ""
        
        //
        var loadingKubeError: AppError?
    }
}
