//
//  Namespace.swift
//  KubeDoctor
//
//  Created by 翟怀楼 on 2020/3/21.
//  Copyright © 2020 翟怀楼. All rights reserved.
//

import Foundation
import Combine

// MARK: - Namespaces
struct Namespaces: Codable {
    let apiVersion: String
    let items: [Namespace]
    let kind: String
}

// MARK: - Namespace
struct Namespace: Codable {
    let apiVersion, kind: String
    let metadata: NamespaceMetadata
}

// MARK: - NamespaceMetadata
struct NamespaceMetadata: Codable {
    var name, uid: String
}
