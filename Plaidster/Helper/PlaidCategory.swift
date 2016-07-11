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
    public init(category: [String: AnyObject]) {
        id = category["id"] as! String
        hierarchy = category["hierarchy"] as! [String]
        type = category["type"] as! String
    }
}