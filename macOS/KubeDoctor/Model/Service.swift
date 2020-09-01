//
//  Services.swift
//  KubeDoctor
//
//  Created by 翟怀楼 on 2020/4/1.
//  Copyright © 2020 翟怀楼. All rights reserved.
//

import Foundation
import Combine

// MARK: - Services
struct Services: Codable {
    let apiVersion: String
    let items: [Service]
    let kind: String
}

// MARK: - Item
struct Service: Codable, Hashable {
    let apiVersion, kind: String
    let metadata: Metadata
    let spec: ServiceSpec
}

extension Service: Identifiable {
    var id: String {return self.metadata.uid}
}

extension Service: SearchFilterable {
    public func isMatch(for searchString: String) -> Bool {
        return self.metadata.name.lowercased().contains(searchString)
    }
}

struct ServiceSpec: Codable, Hashable {
    let type: String
}
