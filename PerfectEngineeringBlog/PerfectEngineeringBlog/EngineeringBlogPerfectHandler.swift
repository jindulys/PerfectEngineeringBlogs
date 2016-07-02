//
//  EngineeringBlogPerfectHandler.swift
//  PerfectEngineeringBlog
//
//  Created by yansong li on 2016-07-02.
//  Copyright © 2016 YANSONG LI. All rights reserved.
//

import Foundation
import PerfectLib

protocol RoutingCreator {
    static func createRouting()
}

public func PerfectServerModuleInit() {
    Routing.Handler.registerGlobally()
    Company.createRouting()
    SQLManager.DefaultManager
    do {
        try Company.createCompanyTable()
    } catch {
        print("Failed to create DB.")
    }
}