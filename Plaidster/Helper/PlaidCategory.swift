//
//  PlaidCategory.swift
//  Plaidster
//
//  Created by Benjamin Baron on 2/9/16.
//  Copyright © 2016 Plaidster. All rights reserved.
//

import Foundation

public struct PlaidCategory {
    
    // MARK: Properties
    public let id: String
    public let hierarchy: [String]
    public let type: String
    
    // MARK: Initialization
    public init(category: [String: AnyObject]) throws {
        id = try checkType(category, name: "id")
        hierarchy = try checkType(category, name: "hierarchy")
        type = try checkType(category, name: "type")
    }
}