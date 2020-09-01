//
//  AppError.swift
//  KubeDoctor
//
//  Created by 翟怀楼 on 2020/7/17.
//  Copyright © 2020 翟怀楼. All rights reserved.
//

import Foundation

enum AppError: Error, Identifiable {
    var id: String { localizedDescription }

    case readKubeConfig(Error)
    case readConfig(Error)
    case shell(Error)
    case networkingFailed(Error)
    case fileError
    case other(Error)
    
    static func map(_ error: Error) -> AppError {
        return (error as? AppError) ?? .other(error)
    }
}

extension AppError: LocalizedError {
    var localizedDescription: String {
        switch self {
        case .readKubeConfig(let error):
            return "读取 KubeConfig 错误：\(error)"
        case .readConfig(let error):
            return "读取配置文件错误：\(error)"
        case .shell(let error):
            return "执行脚本错误：\(error)"
        case .networkingFailed(let error):
            return error.localizedDescription
        case .fileError:
            return "文件操作错误"
        case .other(let error):
            return "未知错误：\(error)"
        }
    }
}
