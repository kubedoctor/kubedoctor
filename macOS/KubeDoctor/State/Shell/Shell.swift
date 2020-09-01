//
//  Shell.swift
//  KubeDoctor
//
//  Created by 翟怀楼 on 2020/7/18.
//  Copyright © 2020 翟怀楼. All rights reserved.
//

import Foundation
import Combine

// MARK: - shell
func shell(_ command: String) -> Data {
    let task = Process()
    task.launchPath = "/bin/zsh"
    task.arguments = ["-c", command]

    let pipe = Pipe()
    task.standardOutput = pipe
    task.launch()
    
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    return data
}

class ShellManager {
    static let shared: ShellManager = {
        let instance = ShellManager()
        // setup code
        return instance
    }()
    
    func shell(_ command: String) -> (String, Int32) {
        let task = Process()
        task.launchPath = "/bin/zsh"
        task.arguments = ["-c", command]

        let pipe = Pipe()
        task.standardOutput = pipe
        task.launch()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        task.waitUntilExit()
        let output = String(data: data, encoding: .utf8)!
       
        return (output, task.terminationStatus)
    }
}
