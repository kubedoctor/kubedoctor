//
//  Pod.swift
//  KubeDoctor
//
//  Created by 翟怀楼 on 2020/3/19.
//  Copyright © 2020 翟怀楼. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

// MARK: - Pods
struct Pods: Codable {
    var apiVersion: String
    var items: [Pod]
}

// MARK: - Pod
struct Pod: Codable, Hashable {
    var apiVersion, kind: String
    var metadata: Metadata
    var status: PodStatus
}

extension Pod: Identifiable {
    var id: String {return self.metadata.uid}
}

extension Pod: SearchFilterable {
    public func isMatch(for searchString: String) -> Bool {
        return self.metadata.name.lowercased().contains(searchString)
    }
}

// MARK: - PodStatus
struct PodStatus: Codable, Hashable {
    let hostIP, podIP, qosClass: String?
    let phase: PodStatusPhase
    let startTime: Date?
}

// MARK: - PodStatusPhase Pod 生命周期
enum PodStatusPhase: String, Codable {
    case Pending = "Pending"
    case Running = "Running"
    case Succeeded = "Succeeded"
    case Failed = "Failed"
    case Unknown = "Unknown"
}
