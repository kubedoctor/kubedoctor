//
//  SearchFilter.swift
//  KubeDoctor
//
//  Created by 翟怀楼 on 2020/3/21.
//  Copyright © 2020 翟怀楼. All rights reserved.
//

import Foundation
import Combine

public protocol SearchFilterable {
    func isMatch(for searchString: String) -> Bool
}

public class SearchFilter<T: SearchFilterable>: ObservableObject {
    
    // 这个注解是一个属性包装器（Property Wrapper），可以方便地为任何属性生成其对应类型的发布者。
    // 这个发布者会在属性值发生变化时发送消息。
    @Published public var searchText: String = ""
    
    public func apply(to values: [T]) -> [T] {
        let matchString = searchText
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
        
        return values.filter {
            if matchString.isEmpty {
                return true
            } else {
                return $0.isMatch(for: matchString)
            }
        }
        
    }
    
    public func applyFromExternal(searchText: String, to values: [T]) -> [T] {
        let matchString = searchText
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
        
        return values.filter {
            if matchString.isEmpty {
                return true
            } else {
                return $0.isMatch(for: matchString)
            }
        }
        
    }
}
