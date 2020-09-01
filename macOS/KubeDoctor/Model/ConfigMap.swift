//
//  ConfigMap.swift
//  KubeDoctor
//
//  Created by 翟怀楼 on 2020/4/1.
//  Copyright © 2020 翟怀楼. All rights reserved.
//

import Foundation
import Combine

// MARK: - ConfigMaps
struct ConfigMaps: Codable {
    let apiVersion: String
    let items: [ConfigMap]
    let kind: String
}

// MARK: - ConfigMap
struct ConfigMap: Codable, Hashable {
    let apiVersion: String
    let kind: String
    let metadata: Metadata
    var data: [String:String]?
}

extension ConfigMap: Identifiable {
    var id: String {return self.metadata.uid}
}

extension ConfigMap: SearchFilterable {
    public func isMatch(for searchString: String) -> Bool {
        return self.metadata.name.lowercased().contains(searchString)
    }
}
