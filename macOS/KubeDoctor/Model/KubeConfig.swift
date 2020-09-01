//
//  KubeConfig.swift
//  KubeDoctor
//
//  Created by 翟怀楼 on 2020/4/18.
//  Copyright © 2020 翟怀楼. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

// MARK: - KubeConfig
struct KubeConfig: Codable {
    var apiVersion: String = ""
    var clusters: [ClusterElement] = []
    var contexts: [ContextElement] = []
    var currentContext: String = ""
    var kind: String = ""
    var preferences: Preferences = Preferences()
    var users: [UserElement] = []

    enum CodingKeys: String, CodingKey {
        case apiVersion, clusters, contexts
        case currentContext = "current-context"
        case kind, preferences, users
    }
}

// MARK: - ClusterElement
struct ClusterElement: Codable {
    let cluster: ClusterCluster
    let name: String
}

// MARK: - ClusterCluster
struct ClusterCluster: Codable {
    let insecureSkipTLSVerify: Bool?
    let server: String
    let certificateAuthorityData: String?

    enum CodingKeys: String, CodingKey {
        case insecureSkipTLSVerify = "insecure-skip-tls-verify"
        case server
        case certificateAuthorityData = "certificate-authority-data"
    }
}

// MARK: - ContextElement
struct ContextElement: Codable {
    let context: ContextContext
    let name: String
}

// MARK: - ContextContext
struct ContextContext: Codable {
    let cluster, namespace, user: String
}

// MARK: - Preferences
struct Preferences: Codable {
}

// MARK: - UserElement
struct UserElement: Codable {
    let name: String
    let user: UserUser
}

// MARK: - UserUser
struct UserUser: Codable {
    let token, clientCertificateData, clientKeyData: String?

    enum CodingKeys: String, CodingKey {
        case token
        case clientCertificateData = "client-certificate-data"
        case clientKeyData = "client-key-data"
    }
}


//class KubeConfig1 {
//    var yamlContent: [String: Any]
//
//    init(yamlContent: [String: Any]) {
//        self.yamlContent = yamlContent
//    }
//
//    func currentContext() -> String {
//        return (self.yamlContent["current-context"] != nil)
//            ? self.yamlContent["current-context"] as! String : ""
//    }
//
//    func isCurrentContext(otherContextName: String) -> Bool {
//        return otherContextName == self.currentContext()
//    }
//
//    func contexts() -> Array<AnyObject> {
//        return (self.yamlContent["contexts"] != nil)
//            ? self.yamlContent["contexts"] as! [AnyObject] : []
//    }
//
//    func contextNames() -> Array<String> {
//        return self.contexts()
//            .map {
//                $0 as! [String: Any]
//            }
//            .map {
//                $0["name"] as! String
//            }
//    }
//
//    func changeContext(newContext: String) {
//        self.yamlContent["current-context"] = newContext
//    }
//}
