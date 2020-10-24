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
    
    func kubeConfigDataPublisher() -> AnyPublisher<Data, Error> {
        Future<Data, Error> { promise in
            let kubeConfigFile = "\(NSHomeDirectory())/.kube/config"
            do {
                let raw = try NSData(contentsOfFile: kubeConfigFile) as Data
                promise(.success(raw))
            } catch {
                promise(.failure(AppError.readKubeConfig(error)))
            }
        }
        .eraseToAnyPublisher()
    }
}
