//
//  HandlerTypealiases.swift
//  Plaidster
//
//  Created by Willow Bumby on 2016-01-17.
//  Copyright © 2016 Willow Bumby. All rights reserved.
//

import Foundation

// TODO: Look into removing response parameters as they should not be needed
public typealias AddUserHandler = (response: NSURLResponse?, accessToken: String?, MFAType: String?, MFA: [[String: AnyObject]]?, accounts: [PlaidAccount]?, transactions: [PlaidTransaction]?, error: NSError?) -> (Void)

public typealias SubmitMFAHandler = (response: NSURLResponse?, accounts: [PlaidAccount]?, transactions: [PlaidTransaction]?, error: NSError?) -> (Void)
public typealias FetchUserBalanceHandler = (response: NSURLResponse?, accounts:[PlaidAccount], error:NSError?) -> (Void)
public typealias FetchUserTransactionsHandler = (response: NSURLResponse?, transactions:[PlaidTransaction], error:NSError?) -> (Void)
public typealias FetchCategoriesHandler = (response: NSURLResponse?, categories:[PlaidCategory], error:NSError?) -> (Void)
public typealias FetchInstitutionsHandler = (response: NSURLResponse?, categories:[PlaidInstitution], error:NSError?) -> (Void)
public typealias SearchInstitutionsHandler = (response: NSURLResponse?, categories:[PlaidSearchInstitution], error:NSError?) -> (Void)