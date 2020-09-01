//
//  AppAction.swift
//  KubeDoctor
//
//  Created by 翟怀楼 on 2020/7/16.
//  Copyright © 2020 翟怀楼. All rights reserved.
//

import Foundation

enum AppAction {
    case loadConfig
    case loadConfigDone(result: Result<KDConfig, AppError>)
    
    case loadKubeConfig
    case loadKubeConfigDone(result: Result<KubeConfig, AppError>)

    case loadKubeNamespaces
    case loadKubeNamespacesDone(result: Result<[String], AppError>)
    
    case loadKubeAPIResources
    case loadKubeAPIResourcesDone(result: Result<[String], AppError>)

    case loadKubeResourceList
    case loadKubeResourceListDone(result: Result<KubeListRequestCommand, AppError>)
}
