//
//  Deployment.swift
//  KubeDoctor
//
//  Created by 翟怀楼 on 2020/4/1.
//  Copyright © 2020 翟怀楼. All rights reserved.
//

import Foundation
import Combine

// MARK: - Deployments
struct Deployments: Codable {
    let apiVersion: String
    let items: [Deployment]
    let kind: String
}

// MARK: - Deployment
struct Deployment: Codable, Hashable {
    let apiVersion, kind: String
    let metadata: Metadata
    let status: DeploymentStatus
}

extension Deployment: Identifiable {
    var id: String { self.metadata.uid }
}

extension Deployment: SearchFilterable {
    public func isMatch(for searchString: String) -> Bool {
        self.metadata.name.lowercased().contains(searchString)
    }
}

struct DeploymentStatus: Codable, Hashable {
    // 可用的 replica 数
    let availableReplicasint: Int?
    let observedGeneration: Int?
    let readyReplicas: Int?
    let replicas: Int?
    let updatedReplicas: Int?
}
