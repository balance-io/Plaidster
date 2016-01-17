//
//  Typealias.swift
//  Plaidster
//
//  Created by Willow Bumby on 2016-01-17.
//  Copyright © 2016 Willow Bumby. All rights reserved.
//

internal typealias AddUserHandler = (response: NSURLResponse?, accessToken: String, MFAType: String?, MFA: [[String: AnyObject]]?, accounts: [Account]?, transactions: [Transaction]?, error: NSError?) -> (Void)

internal typealias SubmitMFAHandler = (response: NSURLResponse?, accounts: [Account]?, transactions: [Transaction]?, error: NSError?) -> (Void)