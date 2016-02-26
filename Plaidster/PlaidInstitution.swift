//
//  PlaidInstitution.swift
//  Plaidster
//
//  Created by Benjamin Baron on 2/16/16.
//  Copyright © 2016 Willow Bumby. All rights reserved.
//

import Foundation

// Institution returned from /institutions or /institutions/longtail
public struct PlaidInstitution {
    
    // MARK: Properties
    var currencyCode: String
    var usernameLabel: String
    var passwordLabel: String
    
    var hasMfa: Bool
    var mfa: [String]
    
    var name: String
    var products: [String]
    
    var type: String
    var url: String?
    
    // MARK: Initialization
    public init(institution: [String: AnyObject]) throws {
        if institution["currencyCode"] is String {
            currencyCode = institution["currencyCode"] as! String
        } else {
            // All main institutions are USD so they don't return a currency code
            currencyCode = "USD"
        }
        
        let credentials = institution["credentials"] as! [String: String]
        usernameLabel = credentials["username"] as String!
        passwordLabel = credentials["password"] as String!
        
        hasMfa = institution["has_mfa"] as! Bool
        mfa = institution["mfa"] as! [String]
        
        name = institution["name"] as! String
        products = institution["products"] as! [String]
        
        type = institution["type"] as! String
        url = institution["url"] as? String
    }
}