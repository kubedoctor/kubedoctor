//
//  Secret.swift
//  KubeDoctor
//
//  Created by 翟怀楼 on 2020/4/1.
//  Copyright © 2020 翟怀楼. All rights reserved.
//

import Foundation
import Combine

// MARK: - Services
struct Secrets: Codable {
    let apiVersion: String
    let items: [Secret]
    let kind: String
}

// MARK: - Item
struct Secret: Codable, Hashable {
    let apiVersion, kind, type: String
    let metadata: Metadata
}

extension Secret: Identifiable {
    var id: String {return self.metadata.uid}
}

extension Secret: SearchFilterable {
    public func isMatch(for searchString: String) -> Bool {
        return self.metadata.name.lowercased().contains(searchString)
    }
}
