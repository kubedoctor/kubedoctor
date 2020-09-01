//
// Created by 翟怀楼 on 2020/7/22.
// Copyright (c) 2020 翟怀楼. All rights reserved.
//

import Foundation

struct DefaultResources: Codable {
    var apiVersion: String
    var items: [DefaultResource]
}

struct DefaultResource: Codable, Hashable {
    var apiVersion, kind: String
    var metadata: Metadata
}

extension DefaultResource: Identifiable {
    var id: String { self.metadata.uid }
}

extension DefaultResource: SearchFilterable {
    public func isMatch(for searchString: String) -> Bool {
        self.metadata.name.lowercased().contains(searchString)
    }
}
