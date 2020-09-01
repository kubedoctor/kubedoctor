//
//  Resources.swift
//  KubeDoctor
//
//  Created by 翟怀楼 on 2020/7/18.
//  Copyright © 2020 翟怀楼. All rights reserved.
//

import Foundation
import Combine

let kubectlPath = Bundle.main.path(forResource: "kubectl", ofType: "")!

struct APIResourceRequest {
    struct Nil: Error {}
    
    var publisher: AnyPublisher<[String], AppError> {
        Future { promise in
            DispatchQueue.global().async {
                let data = shell("\(kubectlPath) api-resources --no-headers --namespaced=true -o name")
                guard let result = String(data: data, encoding: .utf8)?.split(whereSeparator: \.isNewline) else {
                    promise(.failure(AppError.shell(Nil())))
                    return
                }
                promise(
                    .success(
                        result.map {String($0)}
                    )
                )
            }
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }

    func namespaces(context: String) -> AnyPublisher<[String], AppError> {
        Future { promise in
            DispatchQueue.global().async {
                let data = shell("\(kubectlPath) --context \(context) get namespaces --no-headers -o=custom-columns=NAME:.metadata.name")

                print("kubectl --context \(context) get namespaces --no-headers -o=custom-columns=NAME:.metadata.name")

                guard let result = String(data: data, encoding: .utf8)?.split(whereSeparator: \.isNewline) else {
                    promise(.failure(AppError.shell(Nil())))
                    return
                }
                promise(
                    .success(
                        result.map {String($0)}
                    )
                )
            }
        }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

struct KubeListRequest {
    func get(namespace: String, resource: String) -> AnyPublisher<Data, AppError> {
        Future { promise in
            DispatchQueue.global().async {
                print("\(kubectlPath) get \(resource) -n \(namespace) -o json")
                let data = shell("\(kubectlPath) get \(resource) -n \(namespace) -o json")
                promise(.success(data))
            }
        }
        .eraseToAnyPublisher()
    }

    func getResourceByType(namespace: String, resource: String) -> AnyPublisher<KubeListRequestCommand, AppError> {
        let t = get(namespace: namespace, resource: resource)
        switch resource {
        case "pods":
            return build{t.decode(type: Pods.self, decoder: newJSONDecoder()).map{KubeListRequestCommand.listPods($0)}}
        case "deployments.apps":
            return build{t.decode(type: Deployments.self, decoder: newJSONDecoder()).map{KubeListRequestCommand.listDeployments($0)}}
        case "configmaps":
            return build{t.decode(type: ConfigMaps.self, decoder: newJSONDecoder()).map{KubeListRequestCommand.listConfigMaps($0)}}
        case "secrets":
            return build{t.decode(type: Secrets.self, decoder: newJSONDecoder()).map{KubeListRequestCommand.listSecrets($0)}}
        case "services":
            return build{t.decode(type: Services.self, decoder: newJSONDecoder()).map{KubeListRequestCommand.listServices($0)}}
        default:
            return build{t.decode(type: DefaultResources.self, decoder: newJSONDecoder()).map{
                KubeListRequestCommand.listDefaultResources($0)
            }}
        }
    }

    func build<P: Publisher>(publisher: () -> P) -> AnyPublisher<P.Output, AppError> {
        publisher().mapError { AppError.shell($0) }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

enum KubeListRequestCommand {
    case listPods(Pods)
    case listDeployments(Deployments)
    case listConfigMaps(ConfigMaps)
    case listSecrets(Secrets)
    case listServices(Services)
    case listDefaultResources(DefaultResources)
}
