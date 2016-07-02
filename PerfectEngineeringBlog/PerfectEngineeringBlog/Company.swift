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
        Routing.Routes["POST", "/Company"] = { (_: WebResponse) in
            return PostCompanyHandler()
        }
        
        Routing.Routes["GET", "/Company"] = { (_: WebResponse) in
            return GetCompanyHandler()
        }
    }
}

extension Company {
    static func createCompanyTable() throws {
        guard let db = SQLManager.DefaultManager?.sqliteDB else {
            return
        }
        try db.execute(
            "CREATE TABLE IF NOT EXISTS Company(" +
            "CompanyID INT PRIMARY KEY NOT NULL," +
            "Name CHAR(255)," +
            "BaseURL CHAR(255)," +
            "CompanyBlogURL CHAR(255)," +
            "InfoTableID INT);"
        )
    }
}

class PostCompanyHandler: RequestHandler {
    func handleRequest(request: WebRequest, response: WebResponse) {
        let reqData = request.postBodyString
        let jsonDecoder = JSONDecoder()
        do {
            let json = try jsonDecoder.decode(reqData) as! JSONDictionaryType
            print("received request JSON: \(json.dictionary)")
            
            guard let companyName = json.dictionary["name"] as? String else {
                response.setStatus(400, message: "Bad Request")
                response.requestCompletedCallback()
                return
            }
            guard let db = SQLManager.DefaultManager?.sqliteDB else {
                return
            }
            
            try db.execute("INSERT INTO Company (CompanyID, Name, BaseURL, CompanyBlogURL, InfoTableID) VALUES (?, ?, ?, ?, ?);",
                           doBindings: { (statement) in
                // TODO: nil check
                try statement.bind(1, json.dictionary["companyID"] as! Int)
                try statement.bind(2, companyName)
                try statement.bind(3, json.dictionary["baseURL"] as? String ?? "")
                try statement.bind(4, json.dictionary["companyBlogURL"] as? String ?? "")
                try statement.bind(5, json.dictionary["infotableID"] as? Int ?? 0)
            })
            response.setStatus(200, message: "Created")
        } catch {
            print("Error decoding json from data: \(reqData)")
            response.setStatus(400, message: "Bad Request")
        }
        response.requestCompletedCallback()
    }
}

// End Point    : /company
// Method       : GET
// Parameters:
//      - name  : company name
//      - id    : known company id
class GetCompanyHandler: RequestHandler {
    func handleRequest(request: WebRequest, response: WebResponse) {
        do {
            guard let db = SQLManager.DefaultManager?.sqliteDB else {
                response.setStatus(400, message: "NO DB")
                response.requestCompletedCallback()
                return
            }
            var resultsJSON: [JSONValue] = []
            
            try db.forEachRow("SELECT * FROM Company", handleRow: { (statement, i) in
                var currentCompanyDict: [String: JSONValue] = [:]
                currentCompanyDict["companyID"] = statement.columnInt(0)
                currentCompanyDict["name"] = statement.columnText(1)
                currentCompanyDict["baseURL"] = statement.columnText(2)
                currentCompanyDict["companyBlogURL"] = statement.columnText(3)
                currentCompanyDict["infotableID"] = statement.columnInt(4)
                resultsJSON.append(currentCompanyDict)
            })
            let jsonEncoder = JSONEncoder()
            let resultsString = try jsonEncoder.encode(resultsJSON)
            response.appendBodyString(resultsString)
            response.addHeader("Content-Type", value: "application/json")
            response.setStatus(200, message: "OK")
        } catch {
            response.setStatus(400, message: "Bad Request!")
        }
        response.requestCompletedCallback()
    }
}
