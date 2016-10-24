//
//  PlaidAccount.swift
//  Plaidster
//
//  Created by Willow Bellemore on 2016-01-13.
//  Copyright © 2016 Plaidster. All rights reserved.
//

import Foundation

public struct PlaidAccount {
    
    // MARK: Properties
    public let id: String
    public let item: String
    public let user: String
    public let institutionType: String
    
    public let current: Double
    public let available: Double?
    public let limit: Double?
    
    public let name: String
    public let number: String?
    public let officialName: String?
    public let owner: String?
    
    public let type: String
    public let subType: String?
    
    // MARK: Initialisation
    public init(account: [String: AnyObject]) throws {
        institutionType = try checkType(account, name: "institution_type")
        id = try checkType(account, name: "_id")
        item = try checkType(account, name: "_item")
        user = try checkType(account, name: "_user")
    
        let balance: [String: AnyObject] = try checkType(account, name: "balance")
        current = balance["current"] as? Double ?? 0.0
        available = balance["available"] as? Double
        
        let meta: [String: AnyObject] = try checkType(account, name: "meta")
        officialName = meta["official_name"] as? String
        type = try checkType(account, name: "type")
        subType = account["subtype"] as? String
        number = meta["number"] as? String
        owner = meta["owner"] as? String
        name = try checkType(meta, name: "name")
        limit = meta["limit"] as? Double
    }
}
