//
//  GogoLogger.swift
//  GogoPoke
//
//  Created by Connie Chang on 2023/12/6.
//

import Foundation
import os

class GogoLogger: NSObject {
    
    static let instance = GogoLogger()
    
    let logger = Logger(subsystem: "connie.GogoPoke", category: "GogoPoke")
}
