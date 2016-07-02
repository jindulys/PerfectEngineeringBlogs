//
//  Company.swift
//  PerfectEngineeringBlog
//
//  Created by yansong li on 2016-07-02.
//  Copyright © 2016 YANSONG LI. All rights reserved.
//

import Foundation
import PerfectLib

/// Company struct represent a company's info.
public struct Company {
    /// InfoTable value enum.
    public enum CompanyInfoTableValue {
        case Invalid
        case TableID(Int)
    }
    
    /// The name of the company.
    public let name: String
    /// Unique indentifier for the company.
    public let companyID: Int
    /// The related info table id if any.
    public var infoTableID: CompanyInfoTableValue = .Invalid
    /// The base url for a company. e.g http://www.eng.facebook.com/
    public var baseURL: String?
    
    
}

extension Company: RoutingCreator {
    static func createRouting() {
        Routing.Routes["GET", "/company"] = { (_: WebResponse) in
            return GetCompanyHandler()
        }
    }
}

class GetCompanyHandler: RequestHandler {
    func handleRequest(request: WebRequest, response: WebResponse) {
        response.appendBodyString("Hello There")
        response.requestCompletedCallback()
    }
}