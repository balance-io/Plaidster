//
//  HandlerTypealiases.swift
//  Plaidster
//
//  Created by Willow Bumby on 2016-01-17.
//  Copyright © 2016 Willow Bumby. All rights reserved.
//

import Foundation

public typealias AddUserHandler = (accessToken: String?, MFAType: String?, MFA: [[String: AnyObject]]?, accounts: [PlaidAccount]?, transactions: [PlaidTransaction]?, error: NSError?) -> (Void)

public typealias SubmitMFAHandler = (accounts: [PlaidAccount]?, transactions: [PlaidTransaction]?, error: NSError?) -> (Void)
public typealias FetchUserBalanceHandler = (accounts: [PlaidAccount], error:NSError?) -> (Void)
public typealias FetchUserTransactionsHandler = (transactions: [PlaidTransaction], error:NSError?) -> (Void)
public typealias FetchCategoriesHandler = (categories: [PlaidCategory], error:NSError?) -> (Void)
public typealias FetchInstitutionsHandler = (categories: [PlaidInstitution], error:NSError?) -> (Void)
public typealias SearchInstitutionsHandler = (categories: [PlaidSearchInstitution], error:NSError?) -> (Void)