//
//  PlaidInstitution.swift
//  Plaidster
//
//  Created by Benjamin Baron on 2/16/16.
//  Copyright © 2016 Plaidster. All rights reserved.
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
            currencyCode = try checkType(institution, name: "currencyCode")
        } else {
            // All main institutions are USD so they don't return a currency code
            currencyCode = "USD"
        }
        
        let credentials: [String: AnyObject] = try checkType(institution, name: "credentials")
        usernameLabel = try checkType(credentials, name: "username")
        passwordLabel = try checkType(credentials, name: "password")
        
        hasMfa = try checkType(institution, name: "has_mfa")
        mfa = try checkType(institution, name: "mfa")
        
        name = try checkType(institution, name: "name")
        products = try checkType(institution, name: "products")
        
        type = try checkType(institution, name: "type")
        url = institution["url"] as? String
    }
}