//
//  Account.swift
//  Plaidster
//
//  Created by Willow Bumby on 2016-01-13.
//  Copyright © 2016 Willow Bumby. All rights reserved.
//

import Foundation

public struct Account {
    
    // MARK: Properties
    public let id: String
    public let item: String
    public let user: String
    public let institutionType: String
    
    public let available: Double
    public let current: Double
    
    public let name: String
    public let number: String
    public let officialName: String
    public let owner: String
    
    public let subType: String
    public let type: String
    
    // MARK: Initialisation
    public init(account: [String: AnyObject]) {
        institutionType = account["institution_type"] as! String
        id = account["_id"] as! String
        item = account["_item"] as! String
        user = account["_user"] as! String
    
        let balance = account["balance"] as! [String: AnyObject]
        available = balance["available"] as! Double
        current = balance["current"] as! Double
        
        let meta = account["meta"] as! [String: AnyObject]
        officialName = meta["official_name"] as! String
        subType = account["subtype"] as! String
        number = meta["number"] as! String
        owner = meta["owner"] as! String
        type = account["type"] as! String
        name = meta["name"] as! String
    }
    
}