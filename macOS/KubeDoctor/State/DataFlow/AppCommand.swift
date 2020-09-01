//
//  AppCommand.swift
//  KubeDoctor
//
//  Created by 翟怀楼 on 2020/7/17.
//  Copyright © 2020 翟怀楼. All rights reserved.
//

import Foundation
import Combine

protocol AppCommand {
    func execute(in store: Store)
}

struct LoadConfigCommand: AppCommand {
    func execute(in store: Store) {
        let token = SubscriptionToken()
        ConfigManager().get()
            .sink(receiveCompletion: { complete in
                if case .failure(let error) = complete {
                    store.dispatch(.loadConfigDone(result: .failure(error)))
               }
               token.unseal()
            }, receiveValue: { value in
                store.dispatch(.loadConfigDone(result: .success(value)))
                store.dispatch(.loadKubeConfig)
            }
        )
        .seal(in: token)
    }
}

struct LoadKubeConfigCommand: AppCommand {
    func execute(in store: Store) {
        let token = SubscriptionToken()
        KubeConfigReader().kubeConfigPublisher()
            .sink(receiveCompletion: { complete in
                if case .failure(let error) = complete {
                    store.dispatch(.loadKubeConfigDone(result: .failure(error as! AppError)))
               }
               token.unseal()
            }, receiveValue: { value in
                store.dispatch(.loadKubeConfigDone(result: .success(value)))
                store.dispatch(.loadKubeAPIResources)
            }
        )
        .seal(in: token)
    }
}

struct LoadKubeAPIResourcesCommand: AppCommand {
    func execute(in store: Store) {
        let token = SubscriptionToken()
        APIResourceRequest().publisher.sink(receiveCompletion: {
            if case .failure(let error) = $0 {
                store.dispatch(.loadKubeAPIResourcesDone(result: .failure(error)))
            }
            token.unseal()
        }, receiveValue: {
            store.dispatch(.loadKubeAPIResourcesDone(result: .success($0)))
            store.dispatch(.loadKubeNamespaces)
        }).seal(in: token)
    }
}

struct ListKubeNamespacesCommand: AppCommand {
    let context: String
    func execute(in store: Store) {
        let token = SubscriptionToken()
        APIResourceRequest().namespaces(context: context).sink(receiveCompletion: {
            if case .failure(let error) = $0 {
                store.dispatch(.loadKubeNamespacesDone(result: .failure(error)))
            }
            token.unseal()
        }, receiveValue: {
            store.dispatch(.loadKubeNamespacesDone(result: .success($0)))
            store.dispatch(.loadKubeResourceList)
        }).seal(in: token)
    }
}

struct ListKubeResourcesCommand: AppCommand {
    let namespace: String
    let resource: String
    func execute(in store: Store) {
        if resource == "" {
            return
        }
        if namespace == "" {
            return
        }

        let token = SubscriptionToken()
        KubeListRequest().getResourceByType(namespace: namespace, resource: resource).sink(receiveCompletion: {
            if case .failure(let error) = $0 {
                store.dispatch(.loadKubeResourceListDone(result: .failure(error)))
            }
            token.unseal()
        }, receiveValue: {
            store.dispatch(.loadKubeResourceListDone(result: .success($0)))
        }).seal(in: token)
    }
}

class SubscriptionToken {
    var cancellable: AnyCancellable?
    func unseal() { cancellable = nil }
}

extension AnyCancellable {
    func seal(in token: SubscriptionToken) {
        token.cancellable = self
    }
}
