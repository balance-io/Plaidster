//
//  HandlerTypealiases.swift
//  Plaidster
//
//  Created by Willow Bumby on 2016-01-17.
//  Copyright © 2016 Willow Bumby. All rights reserved.
//

import Foundation

public typealias AddUserHandler = (response: NSURLResponse?, accessToken: String, MFAType: String?, MFA: [[String: AnyObject]]?, accounts: [PlaidAccount]?, transactions: [PlaidTransaction]?, error: NSError?) -> (Void)

public typealias SubmitMFAHandler = (response: NSURLResponse?, accounts: [PlaidAccount]?, transactions: [PlaidTransaction]?, error: NSError?) -> (Void)
public typealias FetchUserBalanceHandler = (response: NSURLResponse?, accounts:[PlaidAccount], error:NSError?) -> (Void)
public typealias FetchUserTransactionsHandler = (response: NSURLResponse?, transactions:[PlaidTransaction], error:NSError?) -> (Void)