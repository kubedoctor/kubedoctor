//
//  KubeConfigReader.swift
//  KubeDoctor
//
//  Created by 翟怀楼 on 2020/4/18.
//  Copyright © 2020 翟怀楼. All rights reserved.
//

import Foundation
import Combine
import Yams

struct KubeConfigReader {
    func kubeConfigPublisher() -> AnyPublisher<KubeConfig, Error> {
        self.kubeConfigDataPublisher()
            .decode(type: KubeConfig.self, decoder: YAMLDecoder())
            .eraseToAnyPublisher()
    }
    
    func kubeConfigDataPublisher() -> AnyPublisher<String, Error> {
        Future<String, Error> { promise in
            let kubeConfigFile = "\(NSHomeDirectory())/.kube/config"
            do {
                let raw = try String(contentsOfFile: kubeConfigFile)
                promise(.success(raw))
            } catch {
                promise(.failure(AppError.readKubeConfig(error)))
            }
        }
        .eraseToAnyPublisher()
    }
}

extension YAMLDecoder: TopLevelDecoder {
    public typealias Input = String
    public func decode<T>(_ type: T.Type, from: String) throws -> T where T : Decodable {
        try decode(from: from)
    }
}
