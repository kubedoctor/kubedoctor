//
//  DefaultsPropertyWrapper.swift
//  KubeDoctor
//
//  Created by 翟怀楼 on 2020/3/22.
//  Copyright © 2020 翟怀楼. All rights reserved.
//

import Foundation

public protocol PropertyListType {}

extension Bool: PropertyListType {}
extension UInt32: PropertyListType {}
extension Int: PropertyListType {}

@propertyWrapper
public struct Defaults<T> {
  public typealias Encoder = (T) -> Any
  public typealias Decoder = (Any) -> T?

  public let key: String

  public init(_ key: String, defaults: UserDefaults = .standard, encode: @escaping Encoder, decode: @escaping Decoder) {
    self.key = key
    self.defaults = defaults
    self.encoder = encode
    self.decoder = decode
  }

  public var wrappedValue: T? {
    get {
      defaults.object(forKey: key).flatMap(decoder)
    }
    set {
      defaults.set(newValue.map(encoder), forKey: key)
    }
  }

  private let defaults: UserDefaults
  private let encoder: Encoder
  private let decoder: Decoder
}

public extension Defaults where T: PropertyListType {
  init(_ key: String, defaults: UserDefaults = .standard) {
    self.init(key, defaults: defaults, encode: { $0 }, decode: { $0 as? T })
  }
}

public extension Defaults where T: RawRepresentable, T.RawValue: PropertyListType {
  init(rawValue key: String, defaults: UserDefaults = .standard) {
    self.init(key, defaults: defaults, encode: { $0.rawValue }, decode: { ($0 as? T.RawValue).flatMap { T(rawValue: $0) } })
  }
}

public extension Defaults where T: Codable {
  init(json key: String, defaults: UserDefaults = .standard) {
    self.init(key, defaults: defaults, encode: { value in
      (try? JSONEncoder().encode(value)) as Any
    }, decode: { value in
      (value as? Data).flatMap { try? JSONDecoder().decode(T.self, from: $0) }
    })
  }
}

