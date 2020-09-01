//
//  Metadata.swift
//  KubeDoctor
//
//  Created by 翟怀楼 on 2020/3/28.
//  Copyright © 2020 翟怀楼. All rights reserved.
//

import Foundation

// MARK: - Metadata
struct Metadata: Codable, Hashable {
    var name, namespace, uid: String
    let creationTimestamp: Date?
}
