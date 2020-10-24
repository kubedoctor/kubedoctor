//
//  Config.swift
//  KubeDoctor
//
//  Created by 翟怀楼 on 2020/7/24.
//  Copyright © 2020 翟怀楼. All rights reserved.
//

import Foundation
import SwiftUI
import Combine
import Yams

struct ConfigManager {
    func get() -> AnyPublisher<KDConfig, AppError> {
        Future<Data, Error> { promise in
            let kubeConfigFile = "\(NSHomeDirectory())/.kube/kd.yml"
            do {
                let raw = try NSData(contentsOfFile: kubeConfigFile) as Data
                promise(.success(raw))
            } catch {
                promise(.failure(AppError.readKubeConfig(error)))
            }
        }
        .decode(type: KDConfig.self, decoder: YAMLDecoder())
        .mapError{ AppError.readConfig($0) }
        .eraseToAnyPublisher()
    }
}


// MARK: - Config
struct KDConfig: Codable {
    let version: Int
    let resourcesKind: ResourcesKind
    let rightMenus: RightMenus
    
    // MARK: - ResourcesKind
    struct ResourcesKind: Codable {
        let mode: String
        let list: [String]
    }

    // MARK: - RightMenus
    struct RightMenus: Codable {
        let common: [Menu]
        let kind: [Kind]

        enum CodingKeys: String, CodingKey {
            case common
            case kind = "Kind"
        }
    }

    // MARK: - Common
    struct Menu: Codable {
        let name, script: String
        let action: MenuAction
    }
    
    enum MenuAction: String, Codable {
        case clipboard
        case shell
    }

    // MARK: - Kind
    struct Kind: Codable {
        let name: String
        let group: [[Menu]]
    }
}

